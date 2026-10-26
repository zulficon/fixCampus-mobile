# Android Auth/profil cihaz testlerini tekrar çalıştırma

## Gerekenler

- Flutter ve Android SDK (platform-tools, emulator, API 36, build-tools ve Flutter'ın istediği NDK/CMake).
- Açık bir Android test emülatörü; bu çalışmada Android 16 / API 36 / ARM64 ve Pixel 7 profili kullanıldı.
- Aynı Supabase projesini kullanan çalışan ASP.NET Core API.
- Teste başlarken uygulama çıkış yapılmış durumda olmalı.

Emülatör host bilgisayarın yerel API'sine `http://10.0.2.2:5168` üzerinden ulaşır. API'nin AllowedHosts ayarı `10.0.2.2` adresine izin vermelidir. Bu çalışmada API sadece bilgisayarın yerel arayüzünde çalıştırıldı; geliştirme ortamına `AllowedHosts=localhost;127.0.0.1;10.0.2.2` verildi. Mobil istemcide public Supabase publishable/anon key kullanılır.

## Test yapılandırması

Aşağıdaki JSON dosyasını **git dışında** saklayın. Her yeni kayıt denemesinde iki benzersiz test e-postası kullanın. Yeni hesap oluşturma testinin çalışabilmesi için yerel demoda e-posta onayı kapalı olmalıdır.

```json
{
  "SUPABASE_URL": "https://PROJE.supabase.co",
  "SUPABASE_ANON_KEY": "PUBLIC_KEY",
  "API_BASE_URL": "http://10.0.2.2:5168",
  "ANDROID_TEST_EMAIL_A": "benzersiz-android-a@example.com",
  "ANDROID_TEST_EMAIL_B": "benzersiz-android-b@example.com",
  "ANDROID_TEST_PASSWORD": "YalnizcaTestIcinGucluParola123!",
  "ANDROID_TEST_NAME_A": "Android Test Berna",
  "ANDROID_TEST_NAME_B": "Android Test İkinci",
  "ANDROID_TEST_UPDATED_NAME": "Android Profil Güncel"
}
```

```sh
flutter pub get
flutter analyze
flutter test --reporter expanded
bash tool/run_android_auth_tests.sh /git-disindaki/config.json emulator-5554
```

Testler sırasıyla çalışmalıdır. `--no-uninstall` önemlidir: ilk testin gerçek Android oturum verisi korunur; ikinci test yeni uygulama sürecinde bu oturumu okur, çıkış yapar; üçüncü test tekrar yeni süreç açarak oturumun geri gelmediğini doğrular. Süreçler arasında HTTP/SDK veya cihaz depolaması taklit edilmez.

Testler iki gerçek test hesabı oluşturur; yalnızca onların profillerini düzenler. Hesaplar otomatik silinmez. Herkese açık depoya gerçek test parolasını, tokenları veya yerel yapılandırma dosyanızı yüklemeyin.

Testler bittiğinde normal uygulamayı açmak için, test hesabı alanları olmadan yalnızca üç bağlantı ayarını içeren ayrı bir JSON kullanın:

```sh
flutter run -d emulator-5554 --dart-define-from-file=/git-disindaki/uygulama-config.json
```
