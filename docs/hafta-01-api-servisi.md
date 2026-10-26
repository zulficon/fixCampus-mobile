# Hafta 1 API servisleri

Flutter uygulamasının ASP.NET Core Web API ile haberleşmesi için Dio tabanlı
salt okunur servis katmanı eklendi. API adresi ve zaman aşımı yapılandırması,
yanıt dönüşümleri ve hata türleri ayrı dosyalarda tanımlandı.

## Eklenen dosyalar

| Dosya | Görevi |
|---|---|
| `lib/services/api_config.dart` | API adresi, uç nokta çözümleme ve zaman aşımı |
| `lib/services/api_service.dart` | Durum, örnek ilan ve veritabanı demosu istekleri |
| `lib/services/api_responses.dart` | JSON yanıtlarını Dart nesnelerine dönüştürme |
| `lib/services/api_exception.dart` | Bağlantı, zaman aşımı, HTTP ve yanıt biçimi hataları |
| `tool/check_api.dart` | Terminalden API bağlantı kontrolü |
| `test/api_service_test.dart` | 18 HTTP servis testi |

## API metotları

| Metot | Uç nokta | Yanıt türü |
|---|---|---|
| `getStatus()` | `GET /api/durum` | `ApiStatus` |
| `getSampleListings()` | `GET /api/ornek/ilanlar` | `SampleListingsResponse` |
| `getDatabaseDemoListing()` | `GET /api/veritabani/ornek-ilan` | `DatabaseDemoListing` |

Örnek ilan yanıtı `dataSource`, `isPersisted` ve `items` alanlarını içerir.
`SampleListing` sınıfı `title`, `type`, `description`, `location` ve
`startsAtUtc` alanlarını okur. Bu yanıt için ayrı bir gösterim modeli kullanılır.
`dataSource: sample` ve `isPersisted: false` sabit örnek veriyi belirtir.

Servis, JSON nesnesini ve alan türlerini denetler. Tarihler saat dilimiyle
okunur ve UTC'ye dönüştürülür. Bağlantı hatası, zaman aşımı, HTTP hatası ve
geçersiz yanıt `ApiFailure` türleriyle ayrılır.

## Yapılandırma ve kullanım

Varsayılan emülatör API adresi `http://10.0.2.2:5168`, zaman aşımı 10 saniyedir.
API adresi `API_BASE_URL` derleme ayarıyla veya `ApiConfig` üzerinden verilir.

```dart
final api = ApiService();
try {
  final response = await api.getSampleListings();
  for (final item in response.items) {
    print(item.title);
  }
} on ApiException catch (error) {
  print(error.message);
} finally {
  api.close();
}
```

API çalışırken mobil depo kökünden bağlantı kontrolü ve servis testleri:

```sh
dart run tool/check_api.dart http://127.0.0.1:5168
flutter test test/api_service_test.dart
```

18 servis testi; yanıt dönüşümlerini, HTTP 401/404/503 durumlarını, geçersiz
JSON ve tarih alanlarını, zaman aşımını, kapalı bağlantıyı ve adres çözümlemeyi
doğrular. Kontrol programı API durumunu, örnek ilanları ve veritabanı demo
yanıtını ayrı çıktılarla gösterir.
