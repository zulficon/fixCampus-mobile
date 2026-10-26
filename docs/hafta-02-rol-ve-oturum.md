# Hafta 2 rol ve oturum kontrolü

API'den okunan profil ve kullanıcı rolüne göre Flutter ekran erişimini
denetleyen katman eklendi. Mevcut giriş ve profil akışı `AuthProvider`
üzerinden kullanılır; korunan rotalar `AuthGuard` ile bu katmana bağlanır.

## Eklenen davranışlar

- Oturumu olmayan kullanıcı korunan sayfada giriş ekranını görür.
- API profili okunmadan korunan içerik açılmaz.
- Öğrenci genel korunan sayfalara erişebilir; yönetici sayfasına erişemez.
- Yönetici erişimi API profilindeki `Yonetici` rolüyle belirlenir.
- Profil ve rol yeniden okunurken içerik gizlenir; doğrulama sonrasında
  mevcut sekme ve form durumu korunur.
- Profil okuma hatasında tekrar deneme ve çıkış seçenekleri gösterilir.
- Uygulama arka plandan döndüğünde profil ve rol yeniden okunur.
- Oturum veya yetki kaybında korunan içerik kaldırılır.

## Dosyalar

| Dosya | Görevi |
|---|---|
| `lib/security/role_session_policy.dart` | Oturum, profil ve role göre erişim kararı |
| `lib/widgets/role_session_guard.dart` | Erişim ekranları, yeniden deneme ve uygulamaya dönüş kontrolü |
| `lib/widgets/auth_guard.dart` | Mevcut rotaların rol/oturum katmanına bağlantısı |
| `test/role_session_guard_test.dart` | 12 rol, oturum ve rota testi |

`RoleSessionPolicy.evaluate` giriş, doğrulama, profil gereksinimi, yetkisiz
erişim ve izin durumlarını belirler. `RoleSessionGuard` bu kararı ekrana
uygular. Doğrulama sırasında `Offstage` ve `TickerMode` ile mevcut içerik
gizlenir; geçerli erişim sürdüğünde sayfa durumu korunur.

## Doğrulama

12 yeni test; girişsiz erişimi, öğrenci ve yönetici rollerini, eksik profili,
profil API hatasını, rol değişimini, oturum kaybını ve uygulamaya dönüşü kapsar.
Gerçek yönetici rotasında profil hatasıyla erişimin kapanması ve ana kabukta
Profil sekmesinin korunması da sınanır.

26 Ekim 2026 tarihinde toplam 69 test geçti ve Android debug APK derlendi.

```sh
flutter test --reporter expanded
flutter build apk --debug
```
