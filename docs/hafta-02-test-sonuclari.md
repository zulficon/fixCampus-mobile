# Berna Kalkan — 2. hafta test sonuçları

Doğrulama: 25.10.2026 21:45 (Türkiye). Flutter 3.47.8, Dart 3.13.7, macOS ARM64.

## Sonuç

| Kontrol | Sonuç | Doğrulama biçimi |
|---|---|---|
| Flutter kod analizi | Hata ve uyarı yok | `flutter analyze` |
| Otomatik testler | 39/39 geçti | `flutter test --reporter expanded` |
| Gerçek Supabase + ortak web API | 16/16 geçti | Mobil uygulamanın gerçek `SupabaseAuthService` ve `ApiClient` sınıfları |
| Veri modeli terminal programı | Geçti | 6 model, JSON, saat dilimi ve hatalı veri kontrolleri |
| Flutter web release derlemesi | Başarılı | `flutter build web --release` |

## Gerçek sunucuda doğrulanan senaryolar

| Senaryo | Sonuç |
|---|---|
| Swagger/OpenAPI profil ve Auth uçlarını sunuyor | PASS |
| Girişsiz profil isteği 401 | PASS |
| Sahte erişim belirteci 401 | PASS |
| Mobil SDK ile kayıt ve API profil oluşturma | PASS |
| Mobilde çıkış sonrası oturum temizleniyor | PASS |
| Yanlış parola gerçek Supabase tarafından reddediliyor | PASS |
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

## Otomatik testlerin kapsamı

- Kayıt/giriş/çıkış ve profil düzenleme ekranları, boş form ve servis hataları.
- Oturum kaybında korumalı ekranın kapanması; öğrenci/yönetici arayüz erişimi.
- SDK değişiklikleri, yinelenen giriş isteğini önleme, profil API hatasından sonra tekrar deneme.
- Yenilenen Bearer tokenın kullanılması ve çıkışta eski başlığın kaldırılması.
- Gerçek `supabase_flutter` SDK ile oturumun saklanması, yeniden SDK başlatıldığında geri yüklenmesi ve çıkışta silinmesi. Bu testte HTTP ve cihaz tercih deposu taklit edilmiştir; gerçek cihaz yeniden başlatma testi değildir.
- Mevcut veri modeli ve ilan sağlayıcı testleri de korunarak çalıştırılmıştır. İlanlar hâlen demo verisi kullanır; 3. hafta API bağlantısı bu değişikliğin kapsamı değildir.

## Testlerde düzeltilen hatalar

1. API token sağlayıcısındaki eksik null kontrolü.
2. Web ve mobil kayıt metadata alanı uyumsuzluğu (`ad_soyad` ortak alanı).
3. Dar ekranlarda giriş/kayıt alt bağlantılarının taşması.
4. Profil düzenleme penceresinde kapanış sırasında controller'ın erken temizlenmesi.
5. SDK oturum yenileme hatalarının uygulamada yakalanması.

## Sınırlar ve kalan doğrulamalar

- Android SDK/emülatör ve fiziksel Android cihaz bu ortamda yoktur. Android APK derlemesi, Android'e kurulum ve gerçek cihazda oturumun yeniden açılış testi yapılmadı.
- Swagger kontrolü OpenAPI sözleşmesini okuyup aynı uçlara gerçek HTTP istekleri gönderilerek yapıldı. Swagger UI düğmelerine basılarak manuel prova yapılmadı.
- Web–mobil ortak hesap ve veri tutarlılığı aynı ASP.NET Core API üzerinden doğrulandı. Web uygulamasının görsel ekran testi bu çalışma kapsamında yapılmadı.
- Yönetici rolünü API'den okuma ve öğrenci hesabının kendine yönetici rolü verememesi doğrulandı. Gerçek yönetici hesabıyla bütün yönetim uçları denenmedi; 2. hafta rol kontrolü Zülfikar'ın görevidir.
- GitHub yazma erişimi önceki denemede 403 döndürdüğü için değişiklikler repoya gönderilmedi. Bu rapor push/merge yapıldığı anlamına gelmez.

Her canlı test çalıştırması iki benzersiz test hesabı oluşturur ve yalnızca bu hesapların profillerini düzenler. Hesaplar otomatik silinmez. Mevcut kullanıcı profilleri değiştirilmez. Raporlar ve paket gerçek parolaları, erişim/yenileme tokenlarını veya veritabanı bağlantı şifresini içermez.
