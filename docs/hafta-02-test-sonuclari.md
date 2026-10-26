# Berna Kalkan — 2. hafta Auth/profil doğrulaması

Son doğrulama: 26.10.2026 14:53 (Türkiye). Flutter 3.47.8, Dart 3.13.7.

Hocanın geri bildirimi uygulandı: mobil Auth işlemleri doğrudan Supabase'e gitmez; kendi ASP.NET Core Web API'miz üzerinden yürür.

## Sonuçlar

| Kontrol | Sonuç |
|---|---|
| `flutter analyze` | Hata ve uyarı yok |
| `flutter test --reporter expanded` | 77/77 geçti; mevcut takım testleri dahil |
| Gerçek Web API Auth/profil terminal testi | 17/17 geçti |
| Android APK derleme ve kurulum | Başarılı |
| Android 16 / API 36 / ARM64 cihaz testi | 3/3 aşama geçti |

## Auth isteklerinin hedefi

| İşlem | Mobilin kullandığı kendi API ucu |
|---|---|
| Kayıt | `POST /api/auth/kayit` |
| Giriş | `POST /api/auth/giris` |
| Otomatik veya elle token yenileme | `POST /api/auth/yenile` |
| Çıkış | `POST /api/auth/cikis` |

`ApiAuthService` kayıt/giriş DTO'larını kendi API'mize gönderir. Dönen oturum SDK'ya aktarılır. SDK'nın otomatik yenileme ve çıkış HTTP istekleri de `WebApiAuthClient` üzerinden kendi API'mize yönlendirilir. Desteklenmeyen SDK Auth uçları doğrudan Supabase'e gönderilmez. SDK'nın saklama ve uygulama yaşam döngüsü desteği korunmuştur. SDK zamanlayıcısının da `/api/auth/yenile` kullandığı otomatik testle ayrıca doğrulandı.

Canlı terminal testinde kaydedilen Auth hedefleri:

- `/api/auth/kayit`: 2 istek
- `/api/auth/cikis`: 2 istek
- `/api/auth/giris`: 2 istek
- `/api/auth/yenile`: 2 istek

Bu sayımlar yalnızca uç adlarını içerir; parola ve token kaydedilmez.

## Android cihazında geçen aşamalar

1. Gerçek hesap oluşturma, boş giriş formu, yanlış/doğru parola, profil adı doğrulaması ve kaydetme, aynı Android hesabıyla web giriş API'si, token yenileme, çıkış ve iki farklı hesabın profil ayrımı.
2. Uygulama süreci kapatılıp yeniden başlatıldığında gerçek Android deposundaki oturumun geri gelmesi; API'den güncel profilin okunması ve çıkış.
3. Çıkıştan sonraki yeni uygulama sürecinde giriş ekranının gelmesi ve kayıtlı oturumun geri dönmemesi.

Aşamalar ayrı APK çalıştırmalarıyla ve `--no-uninstall` ile yürütüldü; uygulama verisi aralarında korunmuştur. Android aşamalarında HTTP, Supabase veya cihaz depolaması taklit edilmedi.

## Canlı terminal senaryoları

| Senaryo | Sonuç |
|---|---|
| Swagger/OpenAPI profil ve Auth uçlarını sunuyor | PASS |
| Girişsiz profil isteği 401 | PASS |
| Sahte erişim belirteci 401 | PASS |
| Web API ile mobil kayıt ve profil oluşturma | PASS |
| Mobilde çıkış sonrası oturum temizleniyor | PASS |
| Yanlış parola kendi Web API üzerinden reddediliyor | PASS |
| Doğru parola ile mobil giriş | PASS |
| Profil değişikliği yeni API isteğinde kalıcı | PASS |
| Geçersiz profil adı API tarafından 400 ile reddediliyor | PASS |
| SDK refresh sonrası API güncel tokenla çalışıyor | PASS |
| Kaydedilmiş oturum yeni SDK istemcisinde geri yükleniyor | PASS |
| Web Auth API aynı mobil hesabıyla giriş yapıyor | PASS |
| İkinci hesap farklı profil ve öğrenci rolü alıyor | PASS |
| Başkasının ID’si ve yönetici rolü gönderilse de yalnızca kendi profilini düzenliyor | PASS |
| Webde yapılan profil değişikliği mobil SDK servisinde görünüyor | PASS |
| Çıkıştan sonra refresh token yeniden kullanılamıyor | PASS |
| Dört Auth işlemi de yalnızca kendi Web API uçlarından geçti | PASS |

## Korunan davranışlar

- Kalıcı SDK oturumu, yenileme, güncel Bearer tokenı, profil okuma/düzenleme ve çıkış.
- Zülfikar'ın API'den doğrulanmış rol gerektiren ekran koruması ve uygulamaya dönüşte rolü yeniden okuma.
- Profil/rol doğrulaması başarısız olduğunda korunan ekranın kapanması.
- Basit profil form hatalarının geçerli oturumu bloke etmemesi; 401/403 ve oturum doğrulama hataları hâlâ erişimi kapatır.

## Sınırlar

Doğrulama Android emülatöründe yapılmıştır; fiziksel telefon ve iOS cihaz testi değildir. Yerel demo e-posta onayı kapalıdır; e-posta bağlantılı OAuth/şifre sıfırlama bu haftanın kapsamı değildir. İlan akışları 3. hafta kapsamındadır. Android debug derlemesinde mevcut Kotlin yapılandırması için gelecek Flutter sürümlerine yönelik geçiş uyarısı vardır; mevcut derleme ve testler başarılıdır.

Gerçek yapılandırma ve test parolaları git dışında tutulur. Bu testler yalnızca iki benzersiz test hesabını/profilini kullanır; hesaplar otomatik silinmez.
