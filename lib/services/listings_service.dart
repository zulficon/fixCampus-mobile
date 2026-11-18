import 'package:dio/dio.dart';

import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/models.dart';
import 'api_exception.dart';
import 'listing_query.dart';

export 'listing_query.dart';

/// fixCampus.Web SaveListingRequest. Kimlik, sahiplik ve durum sunucuya aittir.
class SaveListingRequest {
  const SaveListingRequest({
    required this.baslik,
    required this.aciklama,
    required this.kategoriId,
    required this.tur,
    required this.yer,
    this.bulusmaTarihi,
  });

  final String baslik;
  final String aciklama;
  final String kategoriId;
  final IlanTuru tur;
  final String yer;
  final DateTime? bulusmaTarihi;

  Map<String, dynamic> toJson() => {
    'baslik': baslik.trim(),
    'aciklama': aciklama.trim(),
    'kategoriId': kategoriId,
    'tur': tur.apiValue,
    'yer': yer.trim(),
    'bulusmaTarihi': bulusmaTarihi?.toUtc().toIso8601String(),
  };
}

typedef ListingParticipant = ({String adSoyad, String? bolum, String? sinif});

abstract class ListingsService {
  Future<List<ListingParticipant>> getParticipants(String id);
  Future<List<Kategori>> getCategories();
  Future<List<Ilan>> getListings();
  Future<List<Ilan>> getMyListings();

  Future<ListingPage> searchListings(ListingQuery query);
  Future<Ilan> getListing(String id);
  Future<Ilan> createListing(SaveListingRequest request);
  Future<Ilan> updateListing(String id, SaveListingRequest request);
  Future<void> deleteListing(String id);
  Future<Ilan> setParticipation(String id, {required bool attending});
}

class ListingApiException extends ApiException {
  const ListingApiException(
    super.kind,
    super.message, {
    super.statusCode,
    this.fieldErrors = const {},
  });

  final Map<String, List<String>> fieldErrors;
}

/// Tüm istekler Auth ile aynı ApiClient ve güncel Bearer belirtecini kullanır.
class ApiListingsService implements ListingsService {
  ApiListingsService(this.api);
  final ApiClient api;

  @override
  Future<List<Kategori>> getCategories() => _request(
    () => api.dio.get<Object>(ApiEndpoints.categories),
    (data) => _list(data, Kategori.fromJson),
    200,
  );

  @override
  Future<List<Ilan>> getListings() => _request(
    () => api.dio.get<Object>(ApiEndpoints.listings),
    (data) => _list(data, Ilan.fromJson),
    200,
  );

  @override
  Future<List<Ilan>> getMyListings() => _request(
    () => api.dio.get<Object>('${ApiEndpoints.listings}/benim'),
    (data) => _list(data, Ilan.fromJson),
    200,
  );

  @override
  Future<ListingPage> searchListings(ListingQuery query) => _request(
    () => api.dio.get<Object>(
      '${ApiEndpoints.listings}/sayfali',
      queryParameters: query.toQueryParameters(),
    ),
    (data) => ListingPage.fromJson(_object(data)),
    200,
  );

  @override
  Future<Ilan> getListing(String id) => _request(
    () => api.dio.get<Object>(_path(id)),
    (data) => Ilan.fromJson(_object(data)),
    200,
  );

  @override
  Future<Ilan> createListing(SaveListingRequest request) => _request(
    () => api.dio.post<Object>(ApiEndpoints.listings, data: request.toJson()),
    (data) => Ilan.fromJson(_object(data)),
    201,
  );

  @override
  Future<Ilan> updateListing(String id, SaveListingRequest request) => _request(
    () => api.dio.put<Object>(_path(id), data: request.toJson()),
    (data) => Ilan.fromJson(_object(data)),
    200,
  );

  @override
  Future<void> deleteListing(String id) =>
      _request<void>(() => api.dio.delete<Object>(_path(id)), (_) {}, 204);

  @override
  Future<Ilan> setParticipation(String id, {required bool attending}) {
    final path = '${_path(id)}/katilim';
    return _request(
      () =>
          attending ? api.dio.put<Object>(path) : api.dio.delete<Object>(path),
      (data) => Ilan.fromJson(_object(data)),
      200,
    );
  }

  @override
  Future<List<ListingParticipant>> getParticipants(String id) => _request(
    () => api.dio.get<Object>('${_path(id)}/katilimcilar'),
    (data) => _list(data, (json) {
      final name = json['adSoyad'];
      final department = json['bolum'];
      final year = json['sinif'];
      if (name is! String ||
          (department != null && department is! String) ||
          (year != null && year is! String)) {
        throw const FormatException('Geçersiz katılımcı bilgisi.');
      }
      return (
        adSoyad: name,
        bolum: department as String?,
        sinif: year as String?,
      );
    }),
    200,
    forbiddenMessage:
        'Katılımcı listesini yalnızca ilan sahibi görüntüleyebilir.',
  );

  String _path(String id) =>
      '${ApiEndpoints.listings}/${Uri.encodeComponent(id)}';

  Future<T> _request<T>(
    Future<Response<Object>> Function() send,
    T Function(Object?) decode,
    int expectedStatus, {
    String forbiddenMessage = 'Bu işlem için yetkiniz yok.',
  }) async {
    try {
      final response = await send();
      if (response.statusCode != expectedStatus) {
        throw const FormatException('Beklenmeyen HTTP yanıtı.');
      }
      return decode(response.data);
    } on FormatException {
      throw const ListingApiException(
        ApiFailure.invalidResponse,
        'API yanıtı beklenen biçimde değil.',
      );
    } on DioException catch (error) {
      if (error.error is FormatException) {
        throw const ListingApiException(
          ApiFailure.invalidResponse,
          'API yanıtı geçerli JSON değil.',
        );
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        throw const ListingApiException(
          ApiFailure.timeout,
          'API yanıtı zamanında gelmedi. Tekrar deneyin.',
        );
      }
      final status = error.response?.statusCode;
      if (status == null) {
        throw const ListingApiException(
          ApiFailure.connection,
          'API’ye bağlanılamadı. API adresini ve bağlantıyı kontrol edin.',
        );
      }
      final errors = <String, List<String>>{};
      final data = error.response?.data;
      if (status == 400 && data is Map && data['errors'] is Map) {
        for (final entry in (data['errors'] as Map).entries) {
          if (entry.value is List) {
            errors[entry.key.toString()] = (entry.value as List)
                .whereType<String>()
                .toList();
          }
        }
      }
      final messages = errors.values.expand((value) => value).toSet();
      final message = switch (status) {
        400 =>
          messages.isEmpty
              ? 'İlan bilgilerini kontrol edin.'
              : messages.join('\n'),
        401 => 'Oturumunuz geçersiz veya süresi dolmuş. Yeniden giriş yapın.',
        403 => forbiddenMessage,
        404 => 'İlan bulunamadı veya artık erişilemiyor.',
        409 => 'Bu ilan katılıma açık değil.',
        _ => 'İlan servisi şu anda kullanılamıyor. Tekrar deneyin.',
      };
      throw ListingApiException(
        ApiFailure.http,
        message,
        statusCode: status,
        fieldErrors: Map.unmodifiable(errors),
      );
    }
  }

  static Map<String, dynamic> _object(Object? data) {
    if (data is! Map<String, dynamic>) {
      throw const FormatException('JSON nesnesi bekleniyor.');
    }
    return data;
  }

  static List<T> _list<T>(
    Object? data,
    T Function(Map<String, dynamic>) decode,
  ) {
    if (data is! List) throw const FormatException('JSON listesi bekleniyor.');
    return List.unmodifiable(data.map((item) => decode(_object(item))));
  }
}
