# Hafta 4 — Berna Kalkan: API sorgu servisi

Web projesi: https://github.com/bernakalkann/fixCampus

## Eklenen servis sözleşmesi

`ListingQuery` tür, kategori, metin ve sayfalama parametrelerini oluşturur.
Metin ve kategori boşlukları temizlenir; boş filtreler gönderilmez.
Sayfa alt sınırı 1, boyut varsayılanı 12 ve üst sınırı 50'dir; bunlar web/API
ile aynıdır. Parametreler Dio `queryParameters` üzerinden kodlanır.

`ListingsService.searchListings` ve `ApiListingsService.searchListings`,
`GET /api/ilanlar/sayfali` ucundan yalnız istenen sayfayı getirir. Ortak
`ApiClient` güncel oturum belirtecini ekler. `ListingPage`, ilanlarla birlikte
toplam kayıt/sayfa bilgilerini okur; eksik veya tutarsız yanıtı hata olarak verir.
Ağ ve yetki hataları mevcut hata yönetiminden geçer, boş listeye çevrilmez.

`ListingsProvider.searchListings` sonuç dönerken oturum sürümünü denetler;
hesap değiştiyse eski hesabın yanıtını reddeder. Filtreli yanıt ortak akış
listesinin yerine yazılmaz.

```dart
final result = await provider.searchListings(const ListingQuery(
  tur: IlanTuru.kayip,
  text: 'kulaklık',
  page: 1,
  pageSize: 12,
));
// result.items, result.totalCount, result.totalPages, result.hasNext
```

`ListingQuery`, `listings_service.dart` üzerinden dışa aktarılır.
Filtre değişince ekranın `page: 1` ile sorgu yapması gerekir.

## Ekran entegrasyonu

İlan Arama, Sosyal Radar ve Kayıp–Buluntu ekranları `ServerListingResults`
üzerinden `ListingsProvider.searchListings` çağırır. Tür, kategori, metin ve
sayfa sunucuya gönderilir; toplam kayıt/sayfa bilgisi API yanıtından alınır.
Filtre değişince sayfa 1'e döner. Eski istek yanıtları yeni filtre veya hesabın
sonuçlarını ezmez; ağ hatası boş liste olarak gösterilmez. Yenileme ve ilan
mutasyonları sorguyu tekrar çalıştırır. Mevcut kategori çipleri/kartlar korunur.

`kayipBuluntu=true` birleşik Kayıp–Buluntu akışını sosyal ilanlardan ayırır.
`aktifSosyal=true` tamamlanan sosyal ilanları aktif akıştan çıkarır. Bu alanlar
web API güncellemesiyle birlikte kullanılır. Türkçe harf, çok kelime ve kategori
adında arama ortak API sorgularında da uygulanır.

## Doğrulama

- `flutter analyze --no-pub`: başarılı, sorun yok.
- `test/listing_query_service_test.dart`: filtrelerin/Bearer'ın iletilmesi,
  sayfa yanıtı, boş ve hatalı yanıtlar, 401 ve hesap değişimi testleri eklendi.
- Yerelde `flutter test`, test çalıştırıcısının 127.0.0.1 üzerinde soket açması
  ortam tarafından engellendiği için başlayamadı. Bu sonuç test başarısı değildir.
  Repodaki GitHub Actions analiz ve testleri ayrıca çalıştırır.
- İki hesapla emülatör/Supabase demosu bu katkıda yeniden yapılmadı.

Veritabanı şeması veya gizli anahtar değişikliği gerekmez.

## Ek doğrulamalar

`server_listing_results_test.dart` eski yanıtların yeni aramayı ezmediğini ve
ağ hatalarının boş sonuç olmadığını denetler. Mevcut üç ekran testleri artık
sunucuya giden tür/sayfa/arama parametrelerini de doğrular. Web reposundaki
PostgreSQL kontrolü aynı ilanın MVC servisi ve mobil API sayfalı sorgusundan
okunduğunu gerçek, geçici PostgreSQL veritabanında test eder. Canlı Supabase
üzerinde şema/migration/ilişki ve SQL sorgu kontrolleri salt okunur çalıştırıldı;
canlı uygulamada iki şifreli hesapla cihaz demosu ayrı bir kontroldür.

## İnceleme düzeltmeleri — sayfa taşması

Silme sonrası istenen sayfa son sayfanın dışına çıkmışsa ve toplam kayıt sıfır
değilse `ServerListingResults` son geçerli sayfayı yeniden sorgular. Bu sırada
filtreler/sayfa boyutu korunur. Ekranın sayfa durumu `onPageCorrected` ile
güncellenir; yenileme eski sayfayı tekrar istemez. Her düzeltmede sayfa
numarası küçülür; gerçek boş listede tekrar sorgu yapılmaz. Önceki arama veya
hesap için başlayan düzeltmenin geciken yanıtı güncel sonucu değiştiremez.

Regresyon testleri: son sayfa silinmesi, yenilemede düzeltilen sayfanın
korunması, gerçek boş liste ve düzeltme sırasında tekrar küçülen sayfa sayısı.
