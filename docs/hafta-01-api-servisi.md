# Hafta 1 Zülfikar Durak API servis yapısı

Birinci hafta görevim Flutter uygulamasının ortak ASP.NET Core API ile
haberleşeceği servis katmanını hazırlamaktır. Bu katkıda Dio istemcisi,
ayarlanabilir API adresi, üç yanıt sözleşmesi, hata yönetimi ve bağlantı kontrolü
hazırlandı. Berna'nın lib/models dosyaları ve doğrulama programı değiştirilmedi.

## Dosyalar ve görevleri

| Dosya | Görevi |
|---|---|
| lib/services/api_config.dart | API adresi ve zaman aşımı ayarı |
| lib/services/api_service.dart | Üç salt okunur API isteği |
| lib/services/api_responses.dart | Durum, örnek liste ve veritabanı demosu yanıtları |
| lib/services/api_exception.dart | Bağlantı, zaman aşımı, HTTP ve yanıt biçimi hataları |
| tool/check_api.dart | Terminalden gerçek API bağlantısını gösterme |
| test/api_service_test.dart | Başarılı ve hatalı HTTP senaryolarının 18 testi |

24 Ekim’de Berke’nin Flutter iskeletiyle birlikte doğrulanan dosyalar, 26 Ekim’de
Berna’nın ikinci hafta katkısı korunarak Git geçmişine eklenmiştir. Testler mevcut
flutter_test bağımlılığını kullanır; paket sürümleri geri alınmamıştır. Servis
ekranlardan bağımsız sınanabilir; ilan ekranları henüz bu servise bağlanmadı.
Ekran ve Android kaynakları bu katkıda değiştirilmedi. Yerel ortam Flutter
3.47.7 ve Dart 3.13.5 kullanıyor.

## Kullanılan uç noktalar

| Metot | Adres | Sonuç türü |
|---|---|---|
| getStatus | GET /api/durum | ApiStatus |
| getSampleListings | GET /api/ornek/ilanlar | SampleListingsResponse |
| getDatabaseDemoListing | GET /api/veritabani/ornek-ilan | DatabaseDemoListing |

Örnek ilanlar sabit veridir ve isPersisted=false döner. Tam veritabanı varlığı
değildir: type/title/location alanları Berna'nın Ilan modelindeki
tur/baslik/yer alanlarından farklıdır. Bu nedenle örnek yanıt Ilan.fromJson
ile okunmaz. getSampleListings().items içindeki SampleListing nesneleri
ekranda title, description, location ve startsAtUtc alanlarıyla kullanılabilir.

Veritabanı demo yanıtı da kategori kimliği yerine kategori adını içeren ayrı
bir gösterim sözleşmesidir. Nihai CRUD yanıtı hazır olduğunda Berna'nın varlık
modelleri için ayrıca servis metotları hazırlanacaktır. Bu katkıda Auth, kayıt,
giriş, ilan yazma, fotoğraf yükleme veya yetki denetimi tamamlandı denmez.

## Yerel çalıştırma

Önce web deposunda güncel API derlenip başlatılır. Eski bir DLL çalıştırılması,
yeni veritabanı demo adresinin 404 dönmesine neden olabilir.

```powershell
dotnet build src/FixCampus.Web/FixCampus.Web.csproj
dotnet run --no-build --no-launch-profile --project src/FixCampus.Web -- --urls http://127.0.0.1:5168 --environment Development --Demo:Seed=false
```

Ardından mobil depo kökünde:

```powershell
$env:PUB_CACHE = "$PWD\.pub-cache"
flutter pub get
dart analyze lib/services test/api_service_test.dart tool/check_api.dart
flutter test --reporter expanded test/api_service_test.dart
dart run tool/check_api.dart http://127.0.0.1:5168
```

PUB_CACHE ayarı paketleri proje içindeki .pub-cache klasörüne indirir. Böylece
farklı PowerShell/test ortamlarının kullanıcı önbelleği yolları karışmaz.
Bu klasör .gitignore tarafından yok sayılır; Git'e eklenmez. Yeni bir terminalde
bağımlılıkları yeniden kurarken yukarıdaki ayar tekrar uygulanabilir.

Kontrol komutu yalnızca GET istekleri gönderir; demo kaydı oluşturmaz, migration
uygulamaz ve veritabanı ayarı değiştirmez. Veritabanı demosu 404 veya 503 dönerse
bunu ayrı bildirir; çalışan API ve örnek veri bağlantısını veritabanı başarısı
olarak göstermez.

## Cihaz adresleri ve Berke ile birleştirme

| Ortam | API adresi |
|---|---|
| Bu bilgisayarda terminal kontrolü | http://127.0.0.1:5168 |
| Standart Android emülatörü | http://10.0.2.2:5168 |
| Aynı yerel ağdaki gerçek Android cihaz | http://BILGISAYARIN_YEREL_IP_ADRESI:5168 |

ApiConfig varsayılan olarak Android emülatörü adresini kullanır. Flutter
iskeleti hazır olduğunda farklı adres derleme ayarıyla verilebilir:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5168
```

Gerçek cihazda bilgisayarın yerel IPv4 adresi kullanılır; cihaz ve bilgisayar
aynı ağda olmalı, API ilgili ağ arayüzünden erişilebilir olmalıdır. Bu durumda
web başlatma komutunun --urls değeri http://0.0.0.0:5168 yapılabilir. 0.0.0.0
uygulamanın API adresine yazılmaz; yalnızca sunucunun dinleme adresidir.
Güvenlik duvarı bağlantıya izin vermelidir.

Berke Android proje dosyalarını oluşturduğunda yerel HTTP demosu için yalnızca
debug manifestinde INTERNET izni ve HTTP erişimi bulunmalıdır. Mevcut dosyayla
birleştirilecek örnek android/app/src/debug/AndroidManifest.xml içeriği:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <application android:usesCleartextTraffic="true" />
</manifest>
```

Bu HTTP ayarı yerel geliştirme içindir. HTTPS sunucusu kullanıldığında sertifika
denetimi kapatılmaz. Servise veritabanı parolası veya Supabase secret/service_role
anahtarı verilmez; servis yalnızca .NET API adresine ihtiyaç duyar.

Ekran tarafındaki kullanım bir async fonksiyon içinde şöyledir:

```dart
final api = ApiService();
try {
  final response = await api.getSampleListings();
  for (final ilan in response.items) {
    print(ilan.title);
  }
} on ApiException catch (error) {
  print(error.message);
} finally {
  api.close();
}
```

Flutter ekranı servis nesnesini initState sırasında oluşturup veri isteğini
başlatabilir. FutureBuilder ile yükleniyor, hata, boş liste ve veri durumları
gösterilir. Her build çağrısında yeni istek başlatılmaz; tekrar deneme düğmesi
yeniden istek yapar. Ekran servisi artık kullanmayacağında close çağırır.

## 23 Ekim 2026 doğrulama sonucu

- Yeni servis, yanıt ve test dosyalarının Dart analizi temiz.
- Yerel HTTP sunucusu kullanan 18 test geçti: üç yanıt biçimi, HTTP 401/404/503,
  hatalı JSON/alanlar, geçersiz tarihler, zaman aşımı, kapalı sunucu ve API adresi.
- Güncel .NET API üzerinde getStatus başarılı; getSampleListings üç örnek ilan döndürdü.
- Güncel veritabanı demo adresi HTTP 503 döndürdü. Canlı Supabase veri okuması bu
  kontrolde doğrulanamadı; bu durum sunucu yapılandırması/veritabanı erişimi
  hazır olduğunda ayrıca denenmelidir.
- Web derlemesi başarılı; bağımlılık denetimi mevcut System.Security.Cryptography.Pkcs
  9.0.0 paketi için NU1902 ve NU1903 uyarıları verdi. Web kaynakları veya paket
  sürümleri bu mobil servis çalışmasında değiştirilmedi.
- İlk Android derlemesindeki Gradle sorunu Berke tarafından giderildi.
  24 Ekim’de debug APK derlendi, Samsung SM-S911B ve Android emülatöründe açıldı.
  Bu servis dosyaları Android yapılandırmasını değiştirmez.

## Raporda ve videoda kendi bölümüm

“Bu hafta Flutter uygulamasının ortak .NET API ile haberleşmesi için Dio tabanlı
servis yapısını hazırladım. API adresini ayarlanabilir yaptım; durum, örnek ilan
listesi ve veritabanı demo yanıtlarını ayrı sözleşmelerle ele aldım. Bağlantı,
zaman aşımı ve hatalı yanıt senaryoları için hata yönetimi ekledim. Dart analizi
ve 18 servis testi başarılı oldu. Yerel API’den üç örnek ilanı okudum. Veritabanı
demosunun HTTP 503 yanıtını ayrıca raporladım. Ekran bağlantısını Flutter
iskeleti hazır olduğunda Berke ile birlikte deneyeceğiz.”

Videoda kendi bölümümde api_config.dart ve api_service.dart dosyalarını kısaca
gösterebilir, ardından dart run tool/check_api.dart komutuyla gerçek API
bağlantısını çalıştırabilirim. Bu terminal gösterimi çalışan Android ekranı
veya başarılı Supabase okuması olarak sunulmamalıdır.

## Teknik kaynaklar

- [Dio paket belgesi](https://pub.dev/packages/dio)
- [Dart test paket belgesi](https://pub.dev/packages/test)
- [Android emülatör adresleri](https://developer.android.com/studio/run/emulator-networking-address)
- [Flutter ağ bağlantısı ve INTERNET izni](https://docs.flutter.dev/data-and-backend/networking)
- [Flutter veri yükleme ve FutureBuilder](https://docs.flutter.dev/cookbook/networking/fetch-data)
