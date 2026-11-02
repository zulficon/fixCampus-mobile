import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixcampus_mobile/core/network/api_client.dart';
import 'package:fixcampus_mobile/models/models.dart';
import 'package:fixcampus_mobile/services/listing_service.dart';

class MockListingAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  int statusCode = 200;
  String responseString = '[]';

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      responseString,
      statusCode,
      headers: {
        'content-type': ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('ListingService CRUD API Testleri', () {
    late MockListingAdapter adapter;
    late Dio dio;
    late ApiClient apiClient;
    late ApiListingService service;

    setUp(() {
      adapter = MockListingAdapter();
      dio = Dio(BaseOptions(baseUrl: 'https://api.fixcampus.com'))
        ..httpClientAdapter = adapter;
      apiClient = ApiClient(dio: dio, tokenProvider: () => 'test-jwt-token');
      service = ApiListingService(apiClient);
    });

    test('getCategories /api/kategoriler uç noktasına GET isteği atar', () async {
      adapter.responseString = jsonEncode([
        {'id': 'cat-1', 'ad': 'Spor', 'tur': 'Sosyal'},
        {'id': 'cat-2', 'ad': 'Ders', 'tur': 'Sosyal'},
      ]);

      final categories = await service.getCategories();
      expect(categories.length, 2);
      expect(categories.first.ad, 'Spor');
      expect(adapter.requests.last.path, '/api/kategoriler');
      expect(adapter.requests.last.headers['Authorization'], 'Bearer test-jwt-token');
    });

    test('getListings filtre ve arama parametrelerini query olarak gönderir', () async {
      adapter.responseString = jsonEncode([
        {
          'id': 'ilan-1',
          'sahipId': 'sahip-1',
          'kategoriId': 'cat-1',
          'baslik': 'Voleybol Maçı',
          'aciklama': 'Açık sahada voleybol',
          'tur': 'Sosyal',
          'yer': 'Kampüs Açık Saha',
          'bulusmaTarihi': '2026-11-10T14:00:00.000Z',
          'durum': 'Aktif',
          'olusturulmaTarihi': '2026-11-02T10:00:00.000Z',
        }
      ]);

      final listings = await service.getListings(
        tur: IlanTuru.sosyal,
        kategoriId: 'cat-1',
        query: 'voleybol',
      );

      expect(listings.length, 1);
      expect(listings.first.baslik, 'Voleybol Maçı');
      final queryParams = adapter.requests.last.queryParameters;
      expect(queryParams['tur'], 'Sosyal');
      expect(queryParams['kategoriId'], 'cat-1');
      expect(queryParams['q'], 'voleybol');
    });

    test('getListingById belirtilen kimlikteki ilanı döndürür', () async {
      adapter.responseString = jsonEncode({
        'id': 'ilan-99',
        'sahipId': 'sahip-1',
        'kategoriId': 'cat-1',
        'baslik': 'Detay İlanı',
        'aciklama': 'Detay içeriği',
        'tur': 'Kayip',
        'yer': 'Kütüphane',
        'bulusmaTarihi': null,
        'durum': 'Aktif',
        'olusturulmaTarihi': '2026-11-02T10:00:00.000Z',
      });

      final ilan = await service.getListingById('ilan-99');
      expect(ilan.id, 'ilan-99');
      expect(ilan.baslik, 'Detay İlanı');
      expect(adapter.requests.last.path, '/api/ilanlar/ilan-99');
    });

    test('createListing /api/ilanlar uç noktasına POST ile JSON gövde gönderir', () async {
      final meetingDate = DateTime.utc(2026, 11, 15, 14, 0);

      adapter.responseString = jsonEncode({
        'id': 'ilan-new',
        'sahipId': 'sahip-1',
        'kategoriId': 'cat-1',
        'baslik': 'Yeni Sosyal İlan',
        'aciklama': 'Yeni ilan açıklaması',
        'tur': 'Sosyal',
        'yer': 'Mühendislik Kantini',
        'bulusmaTarihi': meetingDate.toIso8601String(),
        'durum': 'Aktif',
        'olusturulmaTarihi': '2026-11-02T10:00:00.000Z',
      });

      final created = await service.createListing(
        baslik: 'Yeni Sosyal İlan',
        aciklama: 'Yeni ilan açıklaması',
        kategoriId: 'cat-1',
        tur: IlanTuru.sosyal,
        yer: 'Mühendislik Kantini',
        bulusmaTarihi: meetingDate,
      );

      expect(created.id, 'ilan-new');
      expect(adapter.requests.last.method, 'POST');
      expect(adapter.requests.last.path, '/api/ilanlar');
      final body = adapter.requests.last.data as Map<String, dynamic>;
      expect(body['baslik'], 'Yeni Sosyal İlan');
      expect(body['tur'], 'Sosyal');
      expect(body['bulusmaTarihi'], meetingDate.toIso8601String());
    });

    test('updateListing /api/ilanlar/{id} uç noktasına PUT ile güncelleme gönderir', () async {
      adapter.responseString = jsonEncode({
        'id': 'ilan-1',
        'sahipId': 'sahip-1',
        'kategoriId': 'cat-1',
        'baslik': 'Güncellenen Başlık',
        'aciklama': 'Güncellenen açıklama',
        'tur': 'Kayip',
        'yer': 'Yeni Konum',
        'bulusmaTarihi': null,
        'durum': 'Aktif',
        'olusturulmaTarihi': '2026-11-02T10:00:00.000Z',
      });

      final updated = await service.updateListing(
        'ilan-1',
        baslik: 'Güncellenen Başlık',
        aciklama: 'Güncellenen açıklama',
        kategoriId: 'cat-1',
        tur: IlanTuru.kayip,
        yer: 'Yeni Konum',
        bulusmaTarihi: null,
      );

      expect(updated.baslik, 'Güncellenen Başlık');
      expect(adapter.requests.last.method, 'PUT');
      expect(adapter.requests.last.path, '/api/ilanlar/ilan-1');
    });

    test('deleteListing /api/ilanlar/{id} uç noktasına DELETE isteği atar', () async {
      adapter.statusCode = 204;
      adapter.responseString = '';

      await service.deleteListing('ilan-1');
      expect(adapter.requests.last.method, 'DELETE');
      expect(adapter.requests.last.path, '/api/ilanlar/ilan-1');
    });
  });
}
