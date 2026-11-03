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

- `flutter analyze --no-pub`: sorun yok.
- `flutter build bundle --debug --no-pub`: uygulamanın Dart/Flutter derlemesi başarılı.
- `tool/verify_listings.dart`: Flutter motorunda yerel port açmadan çalışan **25 kontrol geçti**.
  Gerçek `ApiClient` + `ApiListingsService` + `ListingsProvider`, bellekteki HTTP
  adaptörüyle birlikte çalıştırıldı. CRUD yolları ve 201/200/204 yanıtları, UTC,
  Bearer yenileme, alan hataları, 401/403/404/500/503, ağ/zaman aşımı,
  bozuk JSON, tekrar deneme ve oturum değişiminde geç yanıt kontrol edildi.
- Supabase bağlantısından tablo sütunları ve tür başına kategori varlığı salt okunur
  sorgularla doğrulandı. Veritabanında şema/veri değişikliği yapılmadı.
- Servis ve Provider regresyon testleri `test/listings_service_test.dart` ve
  `test/providers_test.dart` içinde. Eski demo veri beklentileri kontrollü test
  verileriyle güncellendi. Standart `flutter test` çalıştırıcısı bu oturumda
  `127.0.0.1` üzerinde test sunucusu açamadığı için test paketinin tamamı
  çalıştırılamadı; tamamı geçti iddiasında bulunulmuyor.
- Canlı .NET API üzerinden iki hesapla emülatör CRUD testi ve Android APK derlemesi
  bu oturumda yapılmadı. Bellekteki HTTP kontrolleri canlı Supabase uçtan uca test değildir.

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
