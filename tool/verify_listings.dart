// Bağlantı noktası açmadan gerçek servis + Provider akışını doğrular.
// flutter build bundle --debug --target tool/verify_listings.dart
// Flutter SDK flutter_tester ile build/flutter_assets/kernel_blob.bin çalıştırılır.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:fixcampus_mobile/core/network/api_client.dart';
import 'package:fixcampus_mobile/models/models.dart';
import 'package:fixcampus_mobile/providers/listings_provider.dart';
import 'package:fixcampus_mobile/services/api_exception.dart';
import 'package:fixcampus_mobile/services/listings_service.dart';

const _id = '20000000-0000-0000-0000-000000000001';
const _category = '10000000-0000-0000-0000-000000000001';
const _owner = '00000000-0000-0000-0000-000000000001';
Map<String, dynamic> _listing({String id = _id}) => {
  'id': id,
  'sahipId': _owner,
  'kategoriId': _category,
  'kategori': 'Spor',
  'baslik': 'API ilanı',
  'aciklama': 'Açıklama',
  'tur': 'Sosyal',
  'yer': 'Kampüs',
  'bulusmaTarihi': '2030-11-05T12:00:00Z',
  'durum': 'Aktif',
  'olusturulmaTarihi': '2026-11-03T10:00:00Z',
};

class _Adapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  int status = 200;
  Object? body;
  DioExceptionType? failure;
  String? raw;
  Completer<void>? pending;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancel,
  ) async {
    requests.add(options);
    if (pending != null) await pending!.future;
    if (failure != null) {
      throw DioException(requestOptions: options, type: failure!);
    }
    final payload =
        body ??
        (options.path.endsWith('kategoriler')
            ? [
                {'id': _category, 'ad': 'Spor', 'tur': 'Sosyal'},
              ]
            : [_listing()]);
    return ResponseBody.fromString(
      raw ?? (status == 204 ? '' : jsonEncode(payload)),
      status,
      headers: {
        'content-type': ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

int _checks = 0;
void _check(bool condition, String label) {
  if (!condition) throw StateError(label);
  _checks++;
  stdout.writeln('PASS $label');
}

Future<ListingApiException> _expectError(
  Future<Object?> Function() action,
) async {
  try {
    await action();
  } on ListingApiException catch (e) {
    return e;
  }
  throw StateError('API hatası bekleniyordu.');
}

Future<void> main() async {
  final adapter = _Adapter();
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'))
    ..httpClientAdapter = adapter;
  String? token = 'first-token';
  final service = ApiListingsService(
    ApiClient(dio: dio, tokenProvider: () => token),
  );
  final provider = ListingsProvider(service: service);
  final request = SaveListingRequest(
    baslik: '  Yeni ilan  ',
    aciklama: 'Açıklama',
    kategoriId: _category,
    tur: IlanTuru.sosyal,
    yer: 'Kampüs',
    bulusmaTarihi: DateTime.utc(2030, 11, 5, 12),
  );
  try {
    _check(provider.ilanlar.isEmpty, 'Başlangıçta demo ilan yok');
    _check(await provider.load(), 'Liste ve kategori API üzerinden yüklenir');
    _check(
      provider.ilanlar.single.id == _id &&
          provider.kategoriler.single.id == _category,
      'UUID ve JSON dizisi sözleşmesi',
    );
    _check(
      adapter.requests.every(
        (r) => r.headers['Authorization'] == 'Bearer first-token',
      ),
      'Bearer erişim belirteci',
    );
    token = 'renewed-token';
    adapter.body = _listing();
    await provider.getListing(_id);
    _check(
      adapter.requests.last.path == '/api/ilanlar/$_id' &&
          adapter.requests.last.method == 'GET',
      'Detay GET uç noktası',
    );
    _check(
      adapter.requests.last.headers['Authorization'] == 'Bearer renewed-token',
      'Yenilenen belirteç',
    );
    adapter.status = 201;
    adapter.body = {..._listing(id: 'server-id'), 'baslik': 'Yeni ilan'};
    await provider.createListing(request);
    final sent = adapter.requests.last.data as Map;
    _check(
      adapter.requests.last.method == 'POST' &&
          provider.ilanlar.first.id == 'server-id',
      '201 sonrası sunucu kimliğiyle ekleme',
    );
    _check(
      sent['baslik'] == 'Yeni ilan' &&
          sent['bulusmaTarihi'] == '2030-11-05T12:00:00.000Z',
      'Kırpılmış alanlar ve UTC tarih',
    );
    _check(
      !sent.containsKey('id') &&
          !sent.containsKey('sahipId') &&
          !sent.containsKey('durum'),
      'Sahip ve durum istemciden gönderilmez',
    );
    adapter.status = 200;
    adapter.body = {..._listing(), 'baslik': 'Güncel başlık'};
    await provider.updateListing(_id, request);
    _check(
      adapter.requests.last.method == 'PUT' &&
          provider.ilanlar.last.baslik == 'Güncel başlık',
      '200 PUT sonrası liste güncelleme',
    );
    adapter.status = 400;
    adapter.body = {
      'errors': {
        'Baslik': ['Başlık zorunludur.'],
      },
    };
    final validation = await _expectError(
      () => provider.createListing(request),
    );
    _check(
      validation.fieldErrors['Baslik']!.single == 'Başlık zorunludur.',
      'ValidationProblemDetails alan hataları',
    );
    _check(
      provider.ilanlar.length == 2 && !provider.isSaving,
      'Başarısız oluşturma listeyi değiştirmez',
    );
    for (final status in [401, 403, 404, 500, 503]) {
      adapter.status = status;
      adapter.body = {'message': 'internal details'};
      final error = await _expectError(() async {
        await provider.deleteListing(_id);
        return null;
      });
      _check(
        error.statusCode == status &&
            !error.message.contains('internal details') &&
            provider.ilanlar.length == 2,
        'HTTP $status hata yönetimi, kayıt korunması',
      );
    }
    adapter.status = 204;
    await provider.deleteListing(_id);
    _check(
      adapter.requests.last.method == 'DELETE' && provider.ilanlar.length == 1,
      '204 boş gövde sonrası silme',
    );
    adapter.failure = DioExceptionType.receiveTimeout;
    final timeout = await _expectError(() => service.getListings());
    _check(timeout.kind == ApiFailure.timeout, 'Zaman aşımı');
    adapter.failure = DioExceptionType.connectionError;
    _check(
      !await provider.load() &&
          provider.error != null &&
          provider.ilanlar.length == 1,
      'Bağlantı hatası eski listeyi korur',
    );
    adapter.failure = null;
    adapter.status = 200;
    adapter.body = {'items': []};
    _check(
      (await _expectError(() => service.getListings())).kind ==
          ApiFailure.invalidResponse,
      'Yanlış JSON biçimi reddedilir',
    );
    adapter.raw = '{invalid';
    _check(
      (await _expectError(() => service.getListings())).kind ==
          ApiFailure.invalidResponse,
      'Bozuk JSON reddedilir',
    );
    adapter.raw = null;
    adapter.body = null;
    _check(
      await provider.load() && provider.error == null,
      'Tekrar denemeyle toparlanma',
    );
    token = null;
    await service.getListings();
    _check(
      !adapter.requests.last.headers.containsKey('Authorization'),
      'Çıkış sonrası eski belirteç gönderilmez',
    );
    adapter.pending = Completer<void>();
    final loading = provider.load();
    provider.setSession(_owner);
    await Future<void>.delayed(Duration.zero);
    provider.setSession(null);
    adapter.pending!.complete();
    await loading;
    await Future<void>.delayed(Duration.zero);
    _check(
      provider.ilanlar.isEmpty &&
          provider.kategoriler.isEmpty &&
          !provider.isLoading,
      'Geç gelen yanıt hesaplar arasında taşınmaz',
    );
    stdout.writeln('SUCCESS: $_checks kontrol geçti.');
    exit(0);
  } catch (e, stack) {
    stderr.writeln('FAIL $e\n$stack');
    exit(1);
  } finally {
    provider.dispose();
    dio.close();
  }
}
