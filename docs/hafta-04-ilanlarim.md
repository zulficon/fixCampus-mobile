# İlanlarım

`lib/screens/listings/my_listings_screen.dart` giriş yapan kullanıcının
ilanlarını gösterir. Ana ekranın üst çubuğundaki İlanlarım simgesi,
`/my-listings` rotasını açar. Profildeki mevcut liste korunur.

- Sayfa `RoleSessionGuard` ile korunur; oturum ve profil doğrulanmadan içerik açılmaz.
- Liste, mevcut `ListingsProvider.getUserListings` ile güncel profil kimliğine
  göre süzülür. Yönetici de bu sayfada yalnız kendi ilanlarını görür.
- API'nin döndürdüğü kendi kayıtları durumuna göre elenmez ve oluşturma
  tarihine göre yeniden eskiye sıralanır.
- Açılışta ve yenilemede mevcut `load` işlemi kullanılır. Üst çubuktaki yenileme
  düğmesi ve çekerek yenileme, boş listede de çalışır.
- Yükleniyor, ilk istek hatası, yenileme hatası ve gerçekten boş sonuç ayrıdır.
  Yenileme hatasında önceki kayıtlar hata mesajıyla birlikte korunur.
- Boş sayfada İlan oluştur düğmesi vardır. Kartlar mevcut detay rotasına gider;
  düzenleme/silme işlemleri mevcut API ve sahiplik kontrollerinden geçer.
  Ortak Provider bildirimleri başarıyla değiştirilen kayıtları bu listeye yansıtır.

Bu ekran mevcut API'den yüklenen ortak ilan listesini kullanır. Sunucuda kullanıcı
sorgusu veya sayfalama eklemez. Ortak liste sorgusu ileride sayfalanırsa bu ekranın
tüm kişisel ilanları kapsaması için kullanıcıya özel sorguyla birlikte uyarlanması gerekir.

`test/my_listings_screen_test.dart`; sahiplik filtresini, yönetici hesabını,
sıralamayı, yenilemeyi, hata/boş durumlarını, detay/oluşturma rotalarını,
güncelleme/silmeyi ve oturum/profil değişimlerini sınar. Testler sahte servis
kullanır; gerçek iki hesapla cihaz üzerinde canlı gösterim kontrolünün yerine geçmez.
