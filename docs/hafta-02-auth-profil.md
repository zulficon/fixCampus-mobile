# Hafta 2 — Berna Kalkan: Auth ve profil

## Yapılanlar

- Kayıt ve giriş kendi ASP.NET Core Web API'mizdeki `/api/auth/kayit` ve `/api/auth/giris` uçlarına gider.
- SDK oturumu saklar; otomatik yenileme `/api/auth/yenile`, çıkış `/api/auth/cikis` üzerinden yapılır. Flutter'dan Supabase Auth'a doğrudan ağ çağrısı yapılmaz.
- `SUPABASE_URL` ve public key SDK proje/oturum kimliği için korunur; Auth ağ hedefi `API_BASE_URL` adresidir. Backend Supabase ile kendi yapılandırmasıyla konuşur.
- API'den `GET /api/profil` ile profil/rol okuma ve `PUT /api/profil` ile ad soyad güncelleme.
- Her istekte SDK'nın güncel erişim belirtecini kullanan ortak API istemcisi.
- Profil düzenleme, tekrar deneme ve çıkış; girişsiz erişim ve oturum kaybı kontrolleri.
- Kullanıcı kayıt ve profil isteklerinde rol belirleyemez. Rol yalnızca API'den okunur.
- Web projesiyle ortak `ad_soyad` Auth metadata alanı; eski `adSoyad` verisi için okuma uyumluluğu.

## Kurulum

Flutter >= 3.35, Dart >= 3.9 gereklidir. Doğrulamada Flutter 3.47.8 kullanıldı.
Aynı Supabase projesini kullanan ASP.NET Core web API çalışmalıdır.
Yerel demoda Supabase e-posta onayı kapalıdır. Mobilde yalnızca public publishable/anon key kullanılır; service_role veya veritabanı şifresi kullanılmaz.

```sh
flutter pub get
flutter run --dart-define=SUPABASE_URL=https://PROJE.supabase.co --dart-define=SUPABASE_ANON_KEY=PUBLIC_KEY --dart-define=API_BASE_URL=http://10.0.2.2:5168
```

Android emülatörde API bilgisayarı için `10.0.2.2`; gerçek telefonda API bilgisayarının yerel IP adresi kullanılır. Web önizlemesinde API için ayrıca CORS veya aynı origin altında geliştirme proxy'si gerekir. Sunucunun AllowedHosts ayarı da cihazdan kullanılan API adresine uygun olmalıdır.

## Testleri tekrar çalıştırma

```sh
flutter analyze
flutter test --reporter expanded
dart run tool/verify_models.dart
```

Canlı test için git dışında bir JSON dosyası hazırlayın:

```json
{
  "SUPABASE_URL": "https://PROJE.supabase.co",
  "SUPABASE_ANON_KEY": "PUBLIC_KEY",
  "API_BASE_URL": "http://127.0.0.1:5168"
}
```

```sh
dart run tool/live_auth_check.dart /git-disindaki/config.json /git-disindaki/sonuc.json
```

Bu komut gerçek Supabase'de iki test hesabı açar; mevcut hesapları değiştirmez. Her çalıştırmada yeni hesaplar oluşturulur ve otomatik silinmez. Yerel API Development ortamında ve Swagger/OpenAPI açık olmalıdır.

**Çalıştırılmış güncel sonuçlar (Android emülatörü dahil):** [hafta-02-test-sonuclari.md](hafta-02-test-sonuclari.md).

Android cihaz testlerini tekrarlamak için [Android kurulum ve test adımları](hafta-02-android-test-kurulumu.md).
