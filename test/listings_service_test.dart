import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixcampus_mobile/core/network/api_client.dart';
import 'package:fixcampus_mobile/services/api_exception.dart';
import 'package:fixcampus_mobile/services/listings_service.dart';
import 'support/listings_fakes.dart';

class ListingsAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  int status = 200;
  Object? body;
  DioExceptionType? failure;
  String? raw;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancel,
  ) async {
    requests.add(options);
    if (failure != null) {
      throw DioException(requestOptions: options, type: failure!);
    }
    return ResponseBody.fromString(
      raw ?? (status == 204 ? '' : jsonEncode(body)),
      status,
      headers: {
        'content-type': ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late ListingsAdapter adapter;
  late Dio dio;
  late ApiListingsService service;
  String? token;
  setUp(() {
    token = 'first-token';
    adapter = ListingsAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'))
      ..httpClientAdapter = adapter;
    service = ApiListingsService(
      ApiClient(dio: dio, tokenProvider: () => token),
    );
  });
  tearDown(() => dio.close());

  test(
    'Kişisel liste geçmiş buluşmayı giriş belirteciyle ayrı uçtan alır',
    () async {
      adapter.body = [
        {...listingJson(), 'bulusmaTarihi': '2020-01-01T00:00:00Z'},
      ];
      final items = await service.getMyListings();
      expect(items.single.bulusmaTarihi, DateTime.utc(2020));
      expect(adapter.requests.single.path, '/api/ilanlar/benim');
      expect(adapter.requests.single.method, 'GET');
      expect(adapter.requests.single.queryParameters, isEmpty);
      expect(
        adapter.requests.single.headers['Authorization'],
        'Bearer first-token',
      );
    },
  );

  test(
    'Kategori ve liste yanıtları Web API nin JSON dizisinden okunur',
    () async {
      adapter.body = [
        {'id': categoryId, 'ad': 'Spor', 'tur': 'Sosyal'},
      ];
      expect((await service.getCategories()).single.id, categoryId);
      expect(adapter.requests.last.path, '/api/kategoriler');
      adapter.body = [listingJson()];
      final list = await service.getListings();
      expect(list.single.baslik, 'API ilanı');
      expect(list.single.bulusmaTarihi!.isUtc, true);
      expect(adapter.requests.last.path, '/api/ilanlar');
    },
  );

  test(
    'CRUD yolları, HTTP durumları ve yalnız yazılabilir alanlar gönderilir',
    () async {
      adapter.body = listingJson();
      expect((await service.getListing(listingId)).id, listingId);
      expect(adapter.requests.last.method, 'GET');
      expect(adapter.requests.last.path, '/api/ilanlar/$listingId');
      adapter.status = 201;
      await service.createListing(request(title: '  Başlık  '));
      expect(adapter.requests.last.method, 'POST');
      expect(adapter.requests.last.data, {
        'baslik': 'Başlık',
        'aciklama': 'Açıklama',
        'kategoriId': categoryId,
        'tur': 'Sosyal',
        'yer': 'Kampüs',
        'bulusmaTarihi': '2030-11-05T12:00:00.000Z',
      });
      expect((adapter.requests.last.data as Map).containsKey('sahipId'), false);
      expect((adapter.requests.last.data as Map).containsKey('durum'), false);
      adapter.status = 200;
      await service.updateListing(listingId, request());
      expect(adapter.requests.last.method, 'PUT');
      expect(adapter.requests.last.path, '/api/ilanlar/$listingId');
      adapter.status = 204;
      await service.deleteListing(listingId);
      expect(adapter.requests.last.method, 'DELETE');
      expect(adapter.requests.last.path, '/api/ilanlar/$listingId');
    },
  );

  test(
    'Token yenilenince yeni belirteç, çıkışta başlıksız istek kullanılır',
    () async {
      adapter.body = [];
      await service.getListings();
      expect(
        adapter.requests.last.headers['Authorization'],
        'Bearer first-token',
      );
      token = 'new-token';
      await service.getCategories();
      expect(
        adapter.requests.last.headers['Authorization'],
        'Bearer new-token',
      );
      token = null;
      await service.getListings();
      expect(adapter.requests.last.headers.containsKey('Authorization'), false);
    },
  );

  test(
    'Katılım aynı kimlikle ve güncel Bearer belirteciyle değiştirilir',
    () async {
      adapter.body = {
        ...listingJson(),
        'katilimciSayisi': 3,
        'katiliyor': true,
      };
      final joined = await service.setParticipation(listingId, attending: true);
      expect(joined.katilimciSayisi, 3);
      expect(joined.katiliyor, isTrue);
      expect(adapter.requests.last.method, 'PUT');
      expect(adapter.requests.last.path, '/api/ilanlar/$listingId/katilim');
      expect(adapter.requests.last.data, isNull);
      token = 'new-token';
      adapter.body = {
        ...listingJson(),
        'katilimciSayisi': 2,
        'katiliyor': false,
      };
      final left = await service.setParticipation(listingId, attending: false);
      expect(left.katilimciSayisi, 2);
      expect(left.katiliyor, isFalse);
      expect(adapter.requests.last.method, 'DELETE');
      expect(
        adapter.requests.last.headers['Authorization'],
        'Bearer new-token',
      );
      adapter.status = 409;
      await expectLater(
        service.setParticipation(listingId, attending: true),
        throwsA(
          isA<ListingApiException>().having((e) => e.statusCode, 'status', 409),
        ),
      );
    },
  );

  test('Katılımcılar Bearer ile alınır ve boş profil alanları korunur', () async {
    adapter.body = [
      {'adSoyad': 'Örnek Öğrenci', 'bolum': 'Tıp', 'sinif': null},
    ];
    final result = await service.getParticipants(listingId);
    expect(result.single, (adSoyad: 'Örnek Öğrenci', bolum: 'Tıp', sinif: null));
    expect(adapter.requests.last.method, 'GET');
    expect(adapter.requests.last.path, '/api/ilanlar/$listingId/katilimcilar');
    expect(adapter.requests.last.headers['Authorization'], 'Bearer first-token');
    adapter.status = 403;
    await expectLater(
      service.getParticipants(listingId),
      throwsA(isA<ListingApiException>().having((e) => e.statusCode, 'status', 403)),
    );
  });

  test('ASP.NET ValidationProblemDetails alan hataları korunur', () async {
    adapter.status = 400;
    adapter.body = {
      'title': 'Validation failed',
      'errors': {
        'Baslik': ['Başlık zorunludur.'],
        'KategoriId': ['Kategori türü ilan türüyle aynı olmalıdır.'],
      },
    };
    await expectLater(
      service.createListing(request()),
      throwsA(
        isA<ListingApiException>()
            .having((e) => e.statusCode, 'status', 400)
            .having((e) => e.fieldErrors['Baslik'], 'alan', [
              'Başlık zorunludur.',
            ])
            .having((e) => e.message, 'mesaj', contains('Kategori türü')),
      ),
    );
  });

  for (final status in [401, 403, 404, 500, 503]) {
    test('HTTP $status anlaşılır API hatası olarak iletilir', () async {
      adapter.status = status;
      adapter.body = {'message': 'internal detail'};
      await expectLater(
        service.deleteListing(listingId),
        throwsA(
          isA<ListingApiException>()
              .having((e) => e.statusCode, 'status', status)
              .having(
                (e) => e.message,
                'güvenli mesaj',
                isNot(contains('internal detail')),
              ),
        ),
      );
    });
  }

  test('Zaman aşımı ve bağlantı kesintisi ayrı ele alınır', () async {
    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.sendTimeout,
    ]) {
      adapter.failure = type;
      await expectLater(
        service.getListings(),
        throwsA(
          isA<ListingApiException>().having(
            (e) => e.kind,
            'kind',
            ApiFailure.timeout,
          ),
        ),
      );
    }
    adapter.failure = DioExceptionType.connectionError;
    await expectLater(
      service.getListings(),
      throwsA(
        isA<ListingApiException>().having(
          (e) => e.kind,
          'kind',
          ApiFailure.connection,
        ),
      ),
    );
  });

  test(
    'Boş liste geçerli; sarmalayıcı, eksik alan ve geçersiz JSON reddedilir',
    () async {
      adapter.body = [];
      expect(await service.getListings(), isEmpty);
      for (final bad in [
        {'items': []},
        [<String, dynamic>{}],
        [42],
      ]) {
        adapter.body = bad;
        await expectLater(
          service.getListings(),
          throwsA(
            isA<ListingApiException>().having(
              (e) => e.kind,
              'kind',
              ApiFailure.invalidResponse,
            ),
          ),
        );
      }
      adapter.raw = '{invalid';
      await expectLater(
        service.getListings(),
        throwsA(
          isA<ListingApiException>().having(
            (e) => e.kind,
            'kind',
            ApiFailure.invalidResponse,
          ),
        ),
      );
    },
  );
}
