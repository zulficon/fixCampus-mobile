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

## Mevcut ekranlarla ilişki

Berke'nin arama/Radar/Kayıp-Buluntu ekranlarının mevcut cihaz üzerinde filtreleme
akışı korunmuştur. Bu katkı Berna'nın servis ve sorgu görevini sağlar; yeni
sayfalı servis henüz bu ekranlara bağlanmamıştır. Mevcut `getListings()` ve CRUD
çağrılarının yanıt biçimi değişmez. Yeni servis, web reposundaki aynı hafta
`/api/ilanlar/sayfali` değişikliği ile birlikte kullanılmalıdır.

## Doğrulama

- `flutter analyze --no-pub`: başarılı, sorun yok.
- `test/listing_query_service_test.dart`: filtrelerin/Bearer'ın iletilmesi,
  sayfa yanıtı, boş ve hatalı yanıtlar, 401 ve hesap değişimi testleri eklendi.
- Yerelde `flutter test`, test çalıştırıcısının 127.0.0.1 üzerinde soket açması
  ortam tarafından engellendiği için başlayamadı. Bu sonuç test başarısı değildir.
  Repodaki GitHub Actions analiz ve testleri ayrıca çalıştırır.
- İki hesapla emülatör/Supabase demosu bu katkıda yeniden yapılmadı.

Veritabanı şeması veya gizli anahtar değişikliği gerekmez.
