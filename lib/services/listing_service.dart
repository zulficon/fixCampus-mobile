import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/models.dart';
import 'api_exception.dart';

/// İlan CRUD ve Kategori Servis Sözleşmesi
abstract class ListingService {
  Future<List<Kategori>> getCategories({IlanTuru? tur});
  Future<List<Ilan>> getListings({
    IlanTuru? tur,
    String? kategoriId,
    String? query,
  });
  Future<Ilan> getListingById(String id);
  Future<Ilan> createListing({
    required String baslik,
    required String aciklama,
    required String kategoriId,
    required IlanTuru tur,
    required String yer,
    DateTime? bulusmaTarihi,
  });
  Future<Ilan> updateListing(
    String id, {
    required String baslik,
    required String aciklama,
    required String kategoriId,
    required IlanTuru tur,
    required String yer,
    DateTime? bulusmaTarihi,
  });
  Future<void> deleteListing(String id);
}

/// ASP.NET Core Web API ile haberleşen İlan CRUD İstemcisi
class ApiListingService implements ListingService {
  ApiListingService(this._api);

  final ApiClient _api;

  @override
  Future<List<Kategori>> getCategories({IlanTuru? tur}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (tur != null) {
        queryParams['tur'] = tur.apiValue;
      }

      final response = await _api.dio.get<List<dynamic>>(
        '/api/kategoriler',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final data = response.data;
      if (data == null) return [];
      return data
          .map((item) => Kategori.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<Ilan>> getListings({
    IlanTuru? tur,
    String? kategoriId,
    String? query,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (tur != null) queryParams['tur'] = tur.apiValue;
      if (kategoriId != null && kategoriId.isNotEmpty) {
        queryParams['kategoriId'] = kategoriId;
      }
      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }

      final response = await _api.dio.get<dynamic>(
        '/api/ilanlar',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final data = response.data;
      if (data is List) {
        return data
            .map((item) => Ilan.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<Ilan> getListingById(String id) async {
    try {
      final response =
          await _api.dio.get<Map<String, dynamic>>('/api/ilanlar/$id');
      final data = response.data;
      if (data == null) {
        throw const ApiException(
          ApiFailure.invalidResponse,
          'İlan verisi bulunamadı.',
        );
      }
      return Ilan.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<Ilan> createListing({
    required String baslik,
    required String aciklama,
    required String kategoriId,
    required IlanTuru tur,
    required String yer,
    DateTime? bulusmaTarihi,
  }) async {
    try {
      final body = {
        'baslik': baslik.trim(),
        'aciklama': aciklama.trim(),
        'kategoriId': kategoriId,
        'tur': tur.apiValue,
        'yer': yer.trim(),
        'bulusmaTarihi': bulusmaTarihi?.toUtc().toIso8601String(),
      };

      final response = await _api.dio.post<Map<String, dynamic>>(
        '/api/ilanlar',
        data: body,
      );

      final data = response.data;
      if (data == null) {
        throw const ApiException(
          ApiFailure.invalidResponse,
          'Oluşturulan ilan verisi sunucudan alınamadı.',
        );
      }
      return Ilan.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<Ilan> updateListing(
    String id, {
    required String baslik,
    required String aciklama,
    required String kategoriId,
    required IlanTuru tur,
    required String yer,
    DateTime? bulusmaTarihi,
  }) async {
    try {
      final body = {
        'baslik': baslik.trim(),
        'aciklama': aciklama.trim(),
        'kategoriId': kategoriId,
        'tur': tur.apiValue,
        'yer': yer.trim(),
        'bulusmaTarihi': bulusmaTarihi?.toUtc().toIso8601String(),
      };

      final response = await _api.dio.put<Map<String, dynamic>>(
        '/api/ilanlar/$id',
        data: body,
      );

      final data = response.data;
      if (data == null) {
        throw const ApiException(
          ApiFailure.invalidResponse,
          'Güncellenen ilan verisi sunucudan alınamadı.',
        );
      }
      return Ilan.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> deleteListing(String id) async {
    try {
      await _api.dio.delete<void>('/api/ilanlar/$id');
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  ApiException _mapDioError(DioException error) {
    final status = error.response?.statusCode;
    if (status == 401) {
      return const ApiException(
        ApiFailure.http,
        'Oturum süresi dolmuş veya geçersiz. Lütfen tekrar giriş yapın.',
        statusCode: 401,
      );
    }
    if (status == 403) {
      return const ApiException(
        ApiFailure.http,
        'Bu ilan üzerinde işlem yapma yetkiniz bulunmuyor.',
        statusCode: 403,
      );
    }
    if (status == 404) {
      return const ApiException(
        ApiFailure.http,
        'İlan bulunamadı veya silinmiş olabilir.',
        statusCode: 404,
      );
    }
    if (status == 400) {
      return const ApiException(
        ApiFailure.http,
        'Gönderilen ilan bilgileri geçerli değil.',
        statusCode: 400,
      );
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const ApiException(
        ApiFailure.timeout,
        'Sunucuya ulaşılamadı. Zaman aşımı oluştu.',
      );
    }
    return ApiException(
      ApiFailure.connection,
      'İlan servisine bağlanılamadı. İnternet bağlantınızı kontrol edin.',
      statusCode: status,
    );
  }
}

