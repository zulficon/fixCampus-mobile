# Hafta 3 — Berna Kalkan: API bağlantısı

Mobil plan belgesinin 2–8 Kasım 2026 haftasındaki Berna görevidir.
İlan işlemleri `bernakalkann/fixCampus` içindeki ASP.NET Core API üzerinden
ortak Supabase PostgreSQL verisini kullanır. Bu görev mobil depoda yapılmıştır.

## Bağlanan uçlar

| İşlem | İstek | Başarı yanıtı |
|---|---|---|
| Kategoriler | GET /api/kategoriler | 200, JSON dizisi |
| İlanlar | GET /api/ilanlar | 200, JSON dizisi |
| Detay | GET /api/ilanlar/{id} | 200, ilan |
| Oluşturma | POST /api/ilanlar | 201, sunucu kimlikli ilan |
| Güncelleme | PUT /api/ilanlar/{id} | 200, güncel ilan |
| Silme | DELETE /api/ilanlar/{id} | 204, boş gövde |

`SaveListingRequest`, web projesindeki aynı adlı sözleşmeyle eşleşir:
`baslik`, `aciklama`, `kategoriId`, `tur`, `yer`, `bulusmaTarihi`.
Kimlik, sahip, durum ve oluşturma tarihi istemciden gönderilmez.
Kategori UUID'leri sunucudan gelir; kategori türü ilan türüyle aynı seçilir.
Buluşma tarihi UTC gönderilir ve yerel saatte gösterilir. Sosyal ilan için API'nin
zorunlu tuttuğu gelecek tarih/saat, formdan alınır; kayıp/buluntu için null gönderilir.

## Uygulama davranışı

- `ApiListingsService`, Auth/profil ile aynı `ApiClient` üzerinden her istekte güncel
  erişim belirtecini kullanır. Supabase SDK'nın mevcut oturum saklama/yenileme akışı korunur.
- `ListingsProvider` demo veri üretmez. Girişten sonra liste/kategoriler yüklenir;
  hesap değişiminde önbellek temizlenir ve önceki oturumun gecikmiş yanıtları uygulanmaz.
- Oluşturma/güncelleme/silme yalnızca başarılı API yanıtından sonra listeye yansır.
  Devam eden yazma işlemi sırasında ikinci gönderim engellenir.
- Akışlarda yükleniyor/hata/boş durumları ve çekerek yenileme vardır. API hatası
  boş sonuç gibi gösterilmez. Yenileme başarısızsa önceki kayıtlar korunur.
- Detay ekranı kayıt örneğini göstermekle yetinmez, API'den güncel detayı okur.
  Sahibi düzenleme/silme düğmelerini görür. Silme ayrıca kullanıcı onayı ister.
  Asıl sahiplik denetimi Web API'de kalır; sunucunun 403 yanıtı gösterilir.
- ASP.NET alan doğrulama mesajları ve HTTP 401/403/404/5xx, zaman aşımı,
  bağlantı kesintisi, beklenmeyen JSON için anlaşılır hata mesajları vardır.

Berke'nin ilan ekranları ve Zülfikar'ın doğrulama görevleri ekip planında ayrı
sorumluluklardır. Bu commit, API bağlantısını mevcut ekranlarda kullanılabilir
hale getirir. Katılım servisi, fotoğraf, şikâyet/yönetim, sunucuda arama ve sayfalama
bu haftanın Berna görevine dahil değildir.

## Doğrulama — 3 Kasım 2026

Kontrol edilen mobil uygulama kodu: `8c7acdfd31ea34a2797d5698185b301c2417cef3`.
Kontrol edilen ağ projesi: `90f0f5866515c42c5060b93529b200a660cd67ea`.
Flutter 3.47.8 / Dart 3.13.7 ile aynı kilitli paketler kullanıldı.

[GitHub doğrulama çalıştırması](https://github.com/zulficon/fixCampus-mobile/actions/runs/41627725194)
üç ayrı işi çalıştırır: tüm Flutter testleri, Android APK derlemesi ve ortak .NET
API kontrolleri. Gerçek Supabase şifreleri/erişim belirteçleri GitHub'a gönderilmez.

| Kontrol | Sonuç |
|---|---|
| Flutter analiz | Sorun yok |
| Tüm birim, servis, Provider, oturum ve ekran testleri | **106 test geçti** |
| İlan formu/detay/sahiplik/silme/hata ekran testleri | 106 teste dahil **10 yeni ekran testi geçti** |
| .NET AuthChecks | Geçti |
| .NET AuthorizationChecks | **90 HTTP yetki/OpenAPI kontrolü geçti**; alan/tarih sınır kontrolleri de geçti |
| .NET ListingChecks | Alan doğrulama, sosyal tarih ve sahiplik kontrolleri geçti |
| Android debug APK | **Derleme başarılı**; APK, başarılı CI çalıştırmasında artifact olarak üretildi |
| Yerel Flutter bundle ve port gerektirmeyen servis/Provider kontrolü | Derleme başarılı, **25 kontrol geçti** |
| Supabase veri/sözleşme kontrolü | Üç türün kategorisi mevcut; sahipsiz ilan, kategori-tür uyumsuzluğu ve tarihi eksik sosyal ilan sayısı 0 |

İlk tam test çalıştırması, başarılı yayınlama sonrasında ilan türünün yanlış
sıfırlandığını yakaladı. `Form.reset` eski Dropdown `onChanged` değerini geri
çağırdığı için sıfırlama sırası düzeltildi; aynı regresyon testi sonraki tam
çalıştırmada geçti.

Yerel ortamda standart Flutter test sunucusuna port açılamaması, GitHub Actions
üzerinde **standart `flutter test --no-pub --reporter expanded` komutunun tamamı
çalıştırılarak** aşıldı. Sonuçlar yalnızca 25 kontrollük özel araca dayanmıyor.

Servis/Provider testleri `test/listings_service_test.dart`, `test/providers_test.dart`;
ekran akışı testleri `test/listings_flow_widget_test.dart` içindedir.
`.github/workflows/mobile-validation.yml` sonraki main/PR değişikliklerinde aynı
kontrollerin tekrarlanmasını sağlar. README kurulum bilgisi, mevcut `pubspec.lock`
içindeki Flutter >=3.47 / Dart >=3.13 gereksinimini ve test edilen 3.47.8 sürümünü açıklar.

## Haftalık kapsam ve canlı gösterim sınırı

Bu kontroller 3. haftadaki **Berna: API bağlantısı** görevini doğrular. Mevcut
.NET ilan/kategori DTO'ları ve profilin `bolum`/`sinif` alanları mobil isteklerle
uyumludur; bu görev için ağ projesinde ek kod veya migration gerekmedi.

Rapordaki **4. hafta**, giriş/ilan işlemlerinin emülatörde iki hesapla denenmesini
ve ilk gösterime hazırlanmasını ayrıca içerir. Bu oturumda yerel API ve ADB
sunucusu port kısıtı nedeniyle başlatılamadı. Gerçek Supabase hesaplarıyla mobil
emülatör -> .NET API -> Supabase zinciri üzerinde canlı CRUD testi **yapılmış
sayılmıyor**. Otomatik HTTP ve ekran testleri bu canlı cihaz gösteriminin yerine
geçmez. Supabase'te yalnızca salt okunur kontrol yapıldı; şema/veri değiştirilmedi.

Standart yerel kontroller:

```sh
flutter pub get
flutter analyze
flutter test --reporter expanded
flutter build apk --debug
```

Port gerektirmeyen kontrolün çalıştırılması (Flutter SDK yolu örnektir):

```sh
flutter build bundle --debug --target tool/verify_listings.dart
$FLUTTER_ROOT/bin/cache/artifacts/engine/darwin-x64/flutter_tester \
  --disable-vm-service --non-interactive --enable-software-rendering \
  --packages=.dart_tool/package_config.json \
  --flutter-assets-dir=build/flutter_assets \
  build/flutter_assets/kernel_blob.bin
```

Sonrasında normal uygulama için tekrar `flutter build bundle --debug` çalıştırılır.
Flutter sürümü/işletim sistemine göre motor klasörü değişebilir.

## Canlı gösterim kontrolü

1. Ağ projesinde güncel migration ve API'yi çalıştır; mobilde aynı Supabase projesinin
   açık anahtarı/URL'si ve cihazdan erişilebilen `API_BASE_URL` kullan.
2. Öğrenci A ile giriş yap. Kategori ve ilanların ortak veritabanından geldiğini doğrula.
3. Kayıp ilan oluştur; webde aynı kaydı aç. Mobilde düzenle, webde değişikliği doğrula.
4. Öğrenci B ile aynı detayı aç; düzenleme/silme düğmeleri görünmemeli.
   Yetkisiz PUT/DELETE ayrıca Web API'de 403 dönmeli.
5. A ile sil; akıştan kaybolmalı ve tekrar GET 404 dönmeli.
6. Sosyal ilanda gelecek tarih/saat, türle uyumlu kategori ve API kapalıyken hata/tekrar
   deneme akışlarını kontrol et.
