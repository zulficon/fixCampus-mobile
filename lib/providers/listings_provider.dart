import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/listing_service.dart';

/// İlanlar, Filtreleme, CRUD ve Katılım Yönetimi Sağlayıcısı
class ListingsProvider extends ChangeNotifier {
  ListingsProvider({ListingService? service}) : _service = service {
    _initSampleData();
  }

  final ListingService? _service;
  final List<Kategori> _kategoriler = [];
  final List<Ilan> _ilanlar = [];
  final List<Katilim> _katilimlar = [];

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Kategori> get kategoriler => List.unmodifiable(_kategoriler);
  List<Ilan> get ilanlar => List.unmodifiable(_ilanlar);
  List<Katilim> get katilimlar => List.unmodifiable(_katilimlar);

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Sosyal Radar ilanları (yalnızca Sosyal türündeki aktif buluşmalar)
  List<Ilan> get radarListings {
    return _ilanlar
        .where((i) => i.tur == IlanTuru.sosyal && i.durum == IlanDurumu.aktif)
        .toList();
  }

  /// Kayıp & Buluntu ilanları
  List<Ilan> getLostFoundListings({IlanTuru? turFilter}) {
    return _ilanlar.where((i) {
      final isLostOrFound =
          i.tur == IlanTuru.kayip || i.tur == IlanTuru.buluntu;
      if (!isLostOrFound) return false;
      if (turFilter != null && i.tur != turFilter) return false;
      return true;
    }).toList();
  }

  /// Belirli bir kullanıcının ilanları
  List<Ilan> getUserListings(String userId) {
    return _ilanlar.where((i) => i.sahipId == userId).toList();
  }

  /// Kimliğe göre tek ilan bulma
  Ilan? getListingById(String id) {
    try {
      return _ilanlar.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Kullanıcının bu buluşmaya katılıp katılmadığı
  bool isUserAttending(String ilanId, String userId) {
    return _katilimlar.any((k) => k.ilanId == ilanId && k.profilId == userId);
  }

  /// Bir ilanın katılımcı sayısı
  int getAttendanceCount(String ilanId) {
    return _katilimlar.where((k) => k.ilanId == ilanId).length;
  }

  /// Sunucudan ilanları çekme
  Future<void> fetchListings({
    IlanTuru? tur,
    String? kategoriId,
    String? query,
  }) async {
    if (_service == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final remoteListings = await _service.getListings(
        tur: tur,
        kategoriId: kategoriId,
        query: query,
      );
      if (remoteListings.isNotEmpty) {
        _ilanlar.clear();
        _ilanlar.addAll(remoteListings);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sunucudan kategorileri çekme
  Future<void> fetchCategories({IlanTuru? tur}) async {
    if (_service == null) return;
    try {
      final remoteCategories = await _service.getCategories(tur: tur);
      if (remoteCategories.isNotEmpty) {
        _kategoriler.clear();
        _kategoriler.addAll(remoteCategories);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Yeni İlan Ekleme (Hafta 1 uyumluluğu için senkron ekleme)
  void addListing(Ilan yeniIlan) {
    _ilanlar.removeWhere((i) => i.id == yeniIlan.id);
    _ilanlar.insert(0, yeniIlan);
    notifyListeners();
  }

  /// Yeni İlan Oluşturma (CRUD API ve Yerel Durum Entegrasyonu)
  Future<Ilan?> createListing({
    required String baslik,
    required String aciklama,
    required String kategoriId,
    required IlanTuru tur,
    required String yer,
    DateTime? bulusmaTarihi,
    required String sahipId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Ilan created;
      if (_service != null) {
        created = await _service.createListing(
          baslik: baslik,
          aciklama: aciklama,
          kategoriId: kategoriId,
          tur: tur,
          yer: yer,
          bulusmaTarihi: bulusmaTarihi,
        );
      } else {
        // Çevrimdışı / Mock Modu
        final now = DateTime.now().toUtc();
        created = Ilan(
          id: 'ilan-${DateTime.now().millisecondsSinceEpoch}',
          sahipId: sahipId,
          kategoriId: kategoriId,
          baslik: baslik.trim(),
          aciklama: aciklama.trim(),
          tur: tur,
          yer: yer.trim(),
          bulusmaTarihi: bulusmaTarihi?.toUtc(),
          durum: IlanDurumu.aktif,
          olusturulmaTarihi: now,
        );
      }

      _ilanlar.insert(0, created);
      return created;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// İlan Güncelleme (CRUD API ve Yerel Durum Entegrasyonu)
  Future<Ilan?> updateListing({
    required String id,
    required String baslik,
    required String aciklama,
    required String kategoriId,
    required IlanTuru tur,
    required String yer,
    DateTime? bulusmaTarihi,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Ilan updated;
      if (_service != null) {
        updated = await _service.updateListing(
          id,
          baslik: baslik,
          aciklama: aciklama,
          kategoriId: kategoriId,
          tur: tur,
          yer: yer,
          bulusmaTarihi: bulusmaTarihi,
        );
      } else {
        final existingIndex = _ilanlar.indexWhere((i) => i.id == id);
        if (existingIndex == -1) {
          throw Exception('Güncellenecek ilan bulunamadı.');
        }
        final old = _ilanlar[existingIndex];
        updated = old.copyWith(
          baslik: baslik.trim(),
          aciklama: aciklama.trim(),
          kategoriId: kategoriId,
          tur: tur,
          yer: yer.trim(),
          bulusmaTarihi: bulusmaTarihi?.toUtc(),
          clearBulusmaTarihi: bulusmaTarihi == null,
        );
      }

      final index = _ilanlar.indexWhere((i) => i.id == id);
      if (index != -1) {
        _ilanlar[index] = updated;
      }
      return updated;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// İlan Silme (CRUD API ve Yerel Durum Entegrasyonu)
  Future<bool> deleteListing(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_service != null) {
        await _service.deleteListing(id);
      }
      _ilanlar.removeWhere((i) => i.id == id);
      _katilimlar.removeWhere((k) => k.ilanId == id);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sosyal Buluşmaya Katılma / Katılımı Geri Alma ("Geliyorum")
  void toggleAttendance(String ilanId, String userId) {
    final existingIndex = _katilimlar.indexWhere(
      (k) => k.ilanId == ilanId && k.profilId == userId,
    );

    if (existingIndex >= 0) {
      // Katılımı geri al
      _katilimlar.removeAt(existingIndex);
    } else {
      // Katıl
      _katilimlar.add(
        Katilim(
          id: 'katilim-${DateTime.now().millisecondsSinceEpoch}',
          ilanId: ilanId,
          profilId: userId,
          katilimTarihi: DateTime.now().toUtc(),
        ),
      );
    }
    notifyListeners();
  }

  /// İlanı Çözüldü Olarak İşaretle
  void markAsResolved(String ilanId) {
    final index = _ilanlar.indexWhere((i) => i.id == ilanId);
    if (index != -1) {
      final old = _ilanlar[index];
      _ilanlar[index] = old.copyWith(durum: IlanDurumu.cozuldu);
      notifyListeners();
    }
  }

  void _initSampleData() {
    _kategoriler.addAll([
      const Kategori(id: 'kat-1', ad: 'Spor', tur: IlanTuru.sosyal),
      const Kategori(id: 'kat-2', ad: 'Ders & Çalışma', tur: IlanTuru.sosyal),
      const Kategori(id: 'kat-3', ad: 'Kahve & Sohbet', tur: IlanTuru.sosyal),
      const Kategori(id: 'kat-4', ad: 'Elektronik Eşya', tur: IlanTuru.kayip),
      const Kategori(id: 'kat-5', ad: 'Kart & Cüzdan', tur: IlanTuru.kayip),
      const Kategori(id: 'kat-6', ad: 'Kırtasiye & Kitap', tur: IlanTuru.buluntu),
    ]);

    final now = DateTime.now().toUtc();

    _ilanlar.addAll([
      // Sosyal Radar İlanları
      Ilan(
        id: 'ilan-1',
        sahipId: '00000000-0000-0000-0000-000000000001',
        kategoriId: 'kat-2',
        baslik: 'Merkez Kütüphanede Algoritma Vize Çalışması',
        aciklama:
            'BLM4587 ve algoritma dersi için kütüphane B blok 2. katta birlikte soru çözeceğiz.',
        tur: IlanTuru.sosyal,
        yer: 'Merkez Kütüphane B Blok 2. Kat',
        bulusmaTarihi: now.add(const Duration(days: 1, hours: 2)),
        durum: IlanDurumu.aktif,
        olusturulmaTarihi: now.subtract(const Duration(hours: 3)),
      ),
      Ilan(
        id: 'ilan-2',
        sahipId: '00000000-0000-0000-0000-000000000003',
        kategoriId: 'kat-1',
        baslik: 'Kampüs Açık Sahada Voleybol Maçı',
        aciklama:
            'Saat 17.00 sahada 2 kişi eksiğimiz var, katılmak isteyen herkes gelebilir!',
        tur: IlanTuru.sosyal,
        yer: 'Spor Tesisleri Açık Voleybol Sahası',
        bulusmaTarihi: now.add(const Duration(hours: 18)),
        durum: IlanDurumu.aktif,
        olusturulmaTarihi: now.subtract(const Duration(hours: 5)),
      ),
      Ilan(
        id: 'ilan-3',
        sahipId: '00000000-0000-0000-0000-000000000004',
        kategoriId: 'kat-3',
        baslik: 'Mühendislik Kantininde Kahve & Sohbet',
        aciklama:
            'Ders arası kahve içip mobil proje fikirleri tartışıyoruz.',
        tur: IlanTuru.sosyal,
        yer: 'Mühendislik Fakültesi Zemin Kat Kantin',
        bulusmaTarihi: now.add(const Duration(hours: 4)),
        durum: IlanDurumu.aktif,
        olusturulmaTarihi: now.subtract(const Duration(hours: 1)),
      ),

      // Kayıp & Buluntu İlanları
      Ilan(
        id: 'ilan-4',
        sahipId: '00000000-0000-0000-0000-000000000005',
        kategoriId: 'kat-4',
        baslik: 'Siyah Kablosuz Kulaklık Kutusu Kayıp',
        aciklama:
            'D204 nolu amfide masada unuttum, üzerinde gri çıkartma var. Görenlerin yazmasını rica ederim.',
        tur: IlanTuru.kayip,
        yer: 'Mühendislik D204 Amfisi',
        bulusmaTarihi: null,
        durum: IlanDurumu.aktif,
        olusturulmaTarihi: now.subtract(const Duration(days: 1)),
      ),
      Ilan(
        id: 'ilan-5',
        sahipId: '00000000-0000-0000-0000-000000000001',
        kategoriId: 'kat-5',
        baslik: 'Yemekhanede Bulunan Öğrenci Kimlik Kartı',
        aciklama:
            '1. kat turnikelerin hemen yanında bulundu, yemekhane danışmasına teslim edildi.',
        tur: IlanTuru.buluntu,
        yer: 'Merkez Yemekhane Turnikeleri',
        bulusmaTarihi: null,
        durum: IlanDurumu.cozuldu,
        olusturulmaTarihi: now.subtract(const Duration(days: 2)),
      ),
      Ilan(
        id: 'ilan-6',
        sahipId: '00000000-0000-0000-0000-000000000006',
        kategoriId: 'kat-6',
        baslik: 'Mavi Spiral Defter ve Kalemlik Kayıp',
        aciklama:
            'Kütüphane girişindeki dinlenme koltuklarında unutulmuştur.',
        tur: IlanTuru.kayip,
        yer: 'Merkez Kütüphane Giriş Holü',
        bulusmaTarihi: null,
        durum: IlanDurumu.aktif,
        olusturulmaTarihi: now.subtract(const Duration(hours: 8)),
      ),
    ]);

    // Örnek Katılımlar
    _katilimlar.addAll([
      Katilim(
        id: 'kat-1',
        ilanId: 'ilan-1',
        profilId: '00000000-0000-0000-0000-000000000001',
        katilimTarihi: now.subtract(const Duration(hours: 2)),
      ),
      Katilim(
        id: 'kat-2',
        ilanId: 'ilan-1',
        profilId: '00000000-0000-0000-0000-000000000003',
        katilimTarihi: now.subtract(const Duration(hours: 1)),
      ),
      Katilim(
        id: 'kat-3',
        ilanId: 'ilan-2',
        profilId: '00000000-0000-0000-0000-000000000001',
        katilimTarihi: now.subtract(const Duration(hours: 4)),
      ),
    ]);
  }
}
