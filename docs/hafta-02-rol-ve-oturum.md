# Hafta 2 Zülfikar Durak rol ve oturum kontrolü

26 Ekim 2026. Berna'nın `d533dfd` Auth/profil katkısı ve Zülfikar'ın
birinci hafta API katkısı `8e5fa9b` üzerine hazırlanmıştır.

## Uygulanan davranış

- SDK oturumu bulunmayan kullanıcı korunan sayfada giriş ekranını görür.
- Oturum olsa bile API profili okunmadan korunan içerik açılmaz.
- Öğrenci genel korunan sayfalara erişebilir; yönetici sayfasına erişemez.
- Yönetici erişimi yalnız API profilindeki `Yonetici` rolünden gelir.
- Profil/rol yeniden okunurken önceki içerik gizlenir. Daha önce açılmış
  sayfanın sekme ve form durumu, doğrulama başarılı olursa korunur.
- API profil okuması başarısızsa önceki yönetici bilgisi erişim açmaz.
  Kullanıcı tekrar deneyebilir veya çıkış yapabilir.
- Uygulama arka plandan döndüğünde profil ve rol yeniden okunur.
- Oturum kaybı veya yetki kaybında korunan içerik kaldırılır.

## Dosyalar ve görev paylaşımı

| Dosya | Katkı |
|---|---|
| `lib/security/role_session_policy.dart` | Oturum, profil, hata ve role göre ekran erişimi kararı |
| `lib/widgets/role_session_guard.dart` | Kararı uygular; yeniden deneme, çıkış ve uygulamaya dönüş kontrolü |
| `lib/widgets/auth_guard.dart` | Kullanıcının açık onayıyla yeni katmana yönlendirilen ortak bağlantı |
| `test/role_session_guard_test.dart` | 12 rol/oturum ve gerçek rota senaryosu |

Berna'nın `AuthProvider`, `SupabaseAuthService`, giriş/kayıt/profil ekranları,
modelleri, testleri ve SDK oturum saklama kodu değiştirilmemiştir. Mevcut
`AppRoutes` korunan rotalarda `AuthGuard` kullanmayı sürdürür. Ekran tasarımı ve
ilan Provider'ı değiştirilmemiştir.

## Doğrulama

Yerel ortam: Flutter 3.47.7, Dart 3.13.5, Windows.

- Yeni rol katmanının analizi temizdir.
- 12 yeni test ve önceden mevcut 57 test birlikte **69/69** geçmiştir.
- Gerçek `AppRoutes.adminPanel` rotası üzerinden profil API hatasında ekranın
  kapanması sınanmıştır.
- Gerçek ana kabuk rotasında rol kontrolü sonrasında Profil sekmesinin
  korunması sınanmıştır.
- Android debug APK başarıyla derlenmiştir. Gradle mevcut Kotlin/SDK XML
  uyumluluk uyarıları vermiştir; derleme başarısız olmamıştır. Bu sonuç,
  gerçek yönetici hesabıyla cihazda canlı rol denemesi yapıldığı anlamına gelmez.

```powershell
$env:PUB_CACHE = "$PWD\.pub-cache"
flutter pub get
flutter test --no-pub --reporter expanded
flutter build apk --debug --no-pub
```

Genel `flutter analyze`, Berna'nın mevcut `ApiClient` dosyasında gereksiz `!`
uyarısı verir; bu satır bu katkıda değiştirilmemiştir. İnceleme ayrıntıları:
[berna-hafta-02-inceleme.md](berna-hafta-02-inceleme.md).

## Kapsam sınırı

Bu katman Flutter ekran erişimini denetler. Sunucunun gerçek yönetim
uçlarında rol politikası ve veri sahipliğini ayrıca denetlemesi gerekir;
mobil ekranda düğme gizlemek tek başına sunucu yetkilendirmesi değildir.
Yönetici paneli ve ilanlar halen önceki iskelet/demo verileri kullanır.

Testler dış Supabase'e yeni hesap veya yönetici kaydı eklemez. Gerçek yönetici
hesabıyla canlı uçtan uca rol denemesi bu testlerin yerine geçmiş sayılmaz.
Berna'nın mevcut giriş akışı doğrudan Supabase SDK kullanır; hocanın kendi
Web API'si üzerinden giriş şartı için ayrıca düzeltilmelidir. Bu katkı o
servisi değiştirmez.

## Videoda kendi bölümüm

“Bu hafta Berna'nın giriş ve profil altyapısının üzerine rol ve oturum
kontrolünü ekledim. Öğrenci yönetici ekranını açamıyor. Profil API'den
okunmadan veya yeniden doğrulanırken korunan içerik görünmüyor. API hata
verirse eski yönetici rolüne güvenmek yerine tekrar deneme ekranı gösteriyorum.
Uygulama arka plandan döndüğünde rolü yeniden okuyorum. Oturum kapandığında
korunan içerik kalkıyor. Bu Flutter kontrolüdür; sunucunun yetki politikaları
ayrıca uygulanmalıdır.”

Kodu anlatırken önce `RoleSessionPolicy.evaluate`, sonra
`RoleSessionGuard.didChangeAppLifecycleState` ve `_accessView` gösterilebilir.
Gerçek kişi hesabı veya gizli anahtar ekran kaydına alınmamalıdır.
