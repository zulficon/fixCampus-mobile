import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_exception.dart';
import '../services/listings_service.dart';

/// Ortak Web API'den okunan ilanlar ve yalnızca onaylanan değişiklikler.
class ListingsProvider extends ChangeNotifier {
  ListingsProvider({ListingsService? service}) : _service = service;

  final ListingsService? _service;
  List<Kategori> _kategoriler = [];
  List<Ilan> _ilanlar = [];
  List<Ilan> _myListings = [];
  bool _isLoadingMyListings = false;
  String? _myListingsError;
  int _myListingsRevision = 0;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _disposed = false;
  String? _error;
  String? _userId;
  int _sessionVersion = 0;
  int _dataVersion = 0;
  int _loadVersion = 0;

  List<Kategori> get kategoriler => List.unmodifiable(_kategoriler);
  List<Ilan> get ilanlar => List.unmodifiable(_ilanlar);
  int get dataRevision => _dataVersion;
  int get sessionRevision => _sessionVersion;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  bool get isLoadingMyListings => _isLoadingMyListings;
  String? get myListingsError => _myListingsError;

  /// ProxyProvider güncellemesi sırasında eski hesap verisi hemen temizlenir.
  /// Bildirim ve yükleme build bittikten sonra yapılır.
  void setSession(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    final version = ++_sessionVersion;
    ++_loadVersion;
    _ilanlar = [];
    _myListings = [];
    _myListingsError = null;
    _isLoadingMyListings = false;
    _kategoriler = [];
    _error = null;
    _isSaving = false;
    _isLoading = userId != null;
    Future.microtask(() async {
      if (!_isCurrent(version)) return;
      _notify();
      if (userId != null) await Future.wait([load(), loadMyListings()]);
    });
  }

  List<Ilan> get radarListings => _ilanlar
      .where((i) => i.tur == IlanTuru.sosyal && i.durum == IlanDurumu.aktif)
      .toList();

  List<Ilan> getLostFoundListings({IlanTuru? turFilter}) => _ilanlar.where((i) {
    final lostFound = i.tur == IlanTuru.kayip || i.tur == IlanTuru.buluntu;
    return lostFound && (turFilter == null || i.tur == turFilter);
  }).toList();

  List<Ilan> getUserListings(String? userId) =>
      userId != null && userId == _userId ? List.of(_myListings) : const [];

  Future<void> loadMyListings() async {
    final userId = _userId;
    if (userId == null || _isLoadingMyListings || _disposed) return;
    final session = _sessionVersion;
    _isLoadingMyListings = true;
    _myListingsError = null;
    _notify();
    try {
      final service = _requireService();
      while (_isCurrent(session)) {
        final revision = _myListingsRevision;
        final items = await service.getMyListings();
        if (!_isCurrent(session)) return;
        // İstek sürerken yapılan değişikliği eski yanıtla ezme.
        if (revision != _myListingsRevision) continue;
        _myListings = items
            .where(
              (item) =>
                  item.sahipId == userId && item.durum != IlanDurumu.gizli,
            )
            .toList();
        break;
      }
    } catch (error) {
      if (_isCurrent(session)) _myListingsError = _message(error);
    } finally {
      if (_isCurrent(session)) {
        _isLoadingMyListings = false;
        _notify();
      }
    }
  }

  Future<bool> load() async {
    final session = _sessionVersion;
    final load = ++_loadVersion;
    final data = _dataVersion;
    _isLoading = true;
    _error = null;
    _notify();
    try {
      final service = _requireService();
      // İkisi de başarılı olmadan eski listeyi kısmen değiştirme.
      final results = await Future.wait<Object>([
        service.getCategories(),
        service.getListings(),
      ]);
      if (!_isCurrent(session) || load != _loadVersion) return false;
      _kategoriler = results[0] as List<Kategori>;
      if (data == _dataVersion) {
        _ilanlar = List.of(results[1] as List<Ilan>);
        ++_dataVersion;
      }
      return true;
    } catch (e) {
      if (_isCurrent(session) && load == _loadVersion) _error = _message(e);
      return false;
    } finally {
      if (_isCurrent(session) && load == _loadVersion) {
        _isLoading = false;
        _notify();
      }
    }
  }

  /// Filtreli sonuçları ortak akış listesinin yerine yazmaz.
  /// Ekran, filtre değişince ListingQuery(page: 1, ...) ile tekrar sorgular.
  Future<ListingPage> searchListings(ListingQuery query) async {
    final session = _sessionVersion;
    final result = await _requireService().searchListings(query);
    _checkSession(session);
    return result;
  }

  Future<Ilan> getListing(String id) async {
    final session = _sessionVersion;
    final data = _dataVersion;
    try {
      final ilan = await _requireService().getListing(id);
      _checkSession(session);
      // Önceden başlayan detay isteği yeni güncellemeyi ezmesin.
      if (data == _dataVersion) {
        _upsert(ilan);
        _notify();
      }
      return ilan;
    } on ListingApiException catch (e) {
      if (_isCurrent(session) && data == _dataVersion && e.statusCode == 404) {
        _removeListing(id);
        _notify();
      }
      rethrow;
    }
  }

  Future<Ilan> createListing(SaveListingRequest request) =>
      _save(() => _requireService().createListing(request), _applyListing);

  Future<Ilan> updateListing(String id, SaveListingRequest request) =>
      _save(() => _requireService().updateListing(id, request), _applyListing);

  Future<void> deleteListing(String id) => _save<void>(
    () => _requireService().deleteListing(id),
    (_) => _removeListing(id),
  );

  Future<T> _save<T>(
    Future<T> Function() action,
    void Function(T) apply,
  ) async {
    if (_isSaving) {
      throw const ApiException(ApiFailure.http, 'Devam eden işlemi bekleyin.');
    }
    final session = _sessionVersion;
    _isSaving = true;
    _notify();
    try {
      final result = await action();
      _checkSession(session);
      ++_dataVersion;
      apply(result);
      return result;
    } finally {
      if (_isCurrent(session)) {
        _isSaving = false;
        _notify();
      }
    }
  }

  void _upsert(Ilan ilan) {
    final index = _ilanlar.indexWhere((i) => i.id == ilan.id);
    if (index < 0) {
      _ilanlar = [ilan, ..._ilanlar];
    } else {
      _ilanlar[index] = ilan;
    }
  }

  void _applyListing(Ilan listing) {
    _upsert(listing);
    if (listing.sahipId != _userId) return;
    ++_myListingsRevision;
    _myListings.removeWhere((item) => item.id == listing.id);
    if (listing.durum != IlanDurumu.gizli) _myListings.insert(0, listing);
  }

  void _removeListing(String id) {
    _ilanlar.removeWhere((item) => item.id == id);
    ++_myListingsRevision;
    _myListings.removeWhere((item) => item.id == id);
  }

  ListingsService _requireService() =>
      _service ??
      (throw const ApiException(
        ApiFailure.connection,
        'İlan servisi yapılandırılmamış.',
      ));

  bool _isCurrent(int version) => !_disposed && version == _sessionVersion;

  void _checkSession(int version) {
    if (!_isCurrent(version)) {
      throw const ApiException(
        ApiFailure.http,
        'Oturum değişti. Yeniden deneyin.',
      );
    }
  }

  static String _message(Object error) => error is ApiException
      ? error.message
      : 'İlanlar yüklenemedi. Tekrar deneyin.';

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<List<ListingParticipant>> getParticipants(String id) async {
    final session = _sessionVersion;
    final result = await _requireService().getParticipants(id);
    _checkSession(session);
    return result;
  }

  Future<Ilan> setParticipation(String id, {required bool attending}) => _save(
    () => _requireService().setParticipation(id, attending: attending),
    _applyListing,
  );

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
