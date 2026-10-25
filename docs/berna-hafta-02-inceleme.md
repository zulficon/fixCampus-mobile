# Berna ikinci hafta Flutter katkısı incelemesi

İnceleyen: Zülfikar Durak. Tarih: 26 Ekim 2026.
Mobil kaynak: `d533dfd`. Backend kaynak: `e6ad405`.
İki commit de kendi depolarının uzak `main` geçmişinde bulunmaktadır.

## Doğrulanan katkı

Berna gerçek Supabase SDK giriş/kayıt/çıkışını, oturum saklama ve yenilemeyi,
kendi Web API'sinden profil/rol okumayı ve profil adı güncellemeyi eklemiş.
API istemcisi her istekte SDK'nın güncel tokenını okuyor; oturum kapanınca
önceki Authorization başlığını kaldırıyor. İstemci profil yazma isteğinde
rol veya kullanıcı kimliği göndermiyor.

Bu bilgisayarda mevcut 39 test ile geri alınan 18 API testi birlikte geçti.
Yeni rol katmanı ve gerçek rota senaryoları eklendikten sonra toplam 69 test
geçti. Canlı Supabase test raporu Berna'nın kendi çalışmasının kanıtıdır;
bu incelemede onun canlı hesabı veya test hesapları yeniden kullanılmadı.

## Düzeltilmesi gereken noktalar

### Giriş yolu öğretim elemanının API şartıyla karşılaştırılmalı

`lib/services/auth_service.dart` içindeki `signIn` ve `signUp`, Supabase SDK'yı
doğrudan çağırıyor. Profil işlemleri kendi `/api/profil` uçlarına gidiyor.
Kabul edilen planda ve öğretim elemanı kurallarında giriş de kendi Web API'si
üzerinden yapılmalıdır. Backend'de `/api/auth/giris`, `/api/auth/kayit`,
`/api/auth/yenile`, `/api/auth/cikis` uçları mevcut. İlgili Auth sahibiyle
entegrasyon yolu bu kurala uygun tamamlanmalıdır. Zülfikar'ın rol katmanı
bu servisin kaynak kodunu değiştirmez.

### Yerel SDK'da analiz uyarısı

Flutter 3.47.7 / Dart 3.13.5 ile `flutter analyze`,
`lib/core/network/api_client.dart` satır 40 için
`unnecessary_non_null_assertion` uyarısı veriyor. `_tokenProvider` null
kontrolünden sonra `!` kullanımı gereksiz görülüyor. Davranış testleri geçiyor;
bu uyarı Berna'nın kaynak dosyasına dokunmama talimatı nedeniyle bırakıldı.

### Eski raporun push bilgisi güncel değil

`docs/hafta-02-test-sonuclari.md` sonunda önceki push denemesinin 403 aldığı
yazıyor. Güncel uzak depoda `d533dfd` bulunduğundan bu eski durum kaydı artık
son durumu anlatmıyor. Bu inceleme asıl raporu yeniden yazmaz.

## Rol göreviyle tamamlanan koruma

Başarılı bir oturum, profil doğrulaması tamamlanmış anlamına gelmez. Önceki
rolü ekranda tutan bir profil okuma hatası da yeni yetki doğrulaması sayılmaz.
Zülfikar'ın ayrı `RoleSessionPolicy` ve `RoleSessionGuard` katmanı bu
durumlarda erişimi durdurur. Kullanıcının onayıyla ortak `auth_guard.dart`
yalnız bu katmana yönlendirilmiştir; Berna'nın servis/Provider kodu korunur.

## Henüz tamamlandı denmeyecek işler

- Gerçek yönetici hesabıyla canlı Android rol denemesi.
- Sunucunun yönetim uçlarında rol ve sahiplik politikaları.
- İlan ekranlarının gerçek CRUD API'ye bağlanması.
- API ve mobil kaynaklarının öğretim elemanının istediği aynı depo yapısına
  taşınması.

Bu incelemede backend kaynağı, Supabase kullanıcıları, veritabanı şeması veya
mevcut kişilerin profilleri değiştirilmemiştir.
