# İlanlarım

`lib/screens/listings/my_listings_screen.dart` giriş yapan kullanıcının
ilanlarını gösterir. Ana ekranın üst çubuğundaki İlanlarım simgesi,
`/my-listings` rotasını açar. Profildeki İlanlarım başlığının yanındaki
Tümünü gör bağlantısı da aynı tam sayfaya gider; mevcut profil listesi korunur.

- Sayfa `RoleSessionGuard` ile korunur; oturum ve profil doğrulanmadan içerik açılmaz.
- Liste, mevcut `ListingsProvider.getUserListings` ile güncel profil kimliğine
  göre süzülür. Yönetici de bu sayfada yalnız kendi ilanlarını görür.
- API'nin döndürdüğü kendi kayıtları durumuna göre elenmez ve oluşturma
  tarihine göre yeniden eskiye sıralanır.
- Tümü, Sosyal, Kayıp ve Buluntu seçenekleri yalnız kullanıcının kendi ilanları
  içinde filtreleme yapar. Görünen sayı seçili türün sayısıdır. Yenilemede tür
  seçimi korunur; hesap değiştiğinde Tümü seçeneğine dönülür.
- Seçili türde kayıt yoksa bu durum hesabın tamamen boş olmasından ayrı gösterilir.
- Açılışta ve yenilemede `loadMyListings` kullanılır. Üst çubuktaki yenileme
  düğmesi ve çekerek yenileme, boş listede de çalışır.
- Yükleniyor, ilk istek hatası, yenileme hatası ve gerçekten boş sonuç ayrıdır.
  Yenileme hatasında önceki kayıtlar hata mesajıyla birlikte korunur.
- Boş sayfada İlan oluştur düğmesi vardır. Kartlar mevcut detay rotasına gider;
  düzenleme/silme işlemleri mevcut API ve sahiplik kontrollerinden geçer.
  Ortak Provider bildirimleri başarıyla değiştirilen kayıtları bu listeye yansıtır.

İlanlarım ve Profildeki önizleme, oturum belirteciyle `GET /api/ilanlar/benim`
ucunu kullanır. Kişisel liste ortak akıştan ayrı tutulduğu için geçmiş sosyal
buluşmalar da sahibine görünür. Hesap değişince kişisel liste temizlenir ve
önceki hesaptan gecikmiş yanıtlar uygulanmaz.

`test/my_listings_screen_test.dart`; sahiplik filtresini, yönetici hesabını,
sıralamayı, yenilemeyi, hata/boş durumlarını, detay/oluşturma rotalarını,
güncelleme/silmeyi ve oturum/profil değişimlerini sınar. Testler sahte servis
kullanır; gerçek iki hesapla cihaz üzerinde canlı gösterim kontrolünün yerine geçmez.
