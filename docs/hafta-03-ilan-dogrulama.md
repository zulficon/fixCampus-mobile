# İlan doğrulama ve sahiplik

## Alan doğrulama

`lib/validation/listing_validator.dart` oluşturma ve düzenleme formlarında
kullanılabilen ortak kuralları içerir:

- Başlık, açıklama ve yer boş veya yalnızca boşluk olamaz.
- Başlık 2–150, açıklama 1–3000, yer 1–200 karakter olmalıdır.
  Uzunluklar kenar boşlukları temizlendikten sonra değerlendirilir.
- Kategori, güncel kategori listesinde bulunmalıdır.
- Kategori türü ilan türüyle birebir eşleşmelidir.
- Sosyal ilan için buluşma tarihi gelecekte olmalıdır.

`CreateListingScreen` bu kuralları `Form` ve `TextFormField` ile uygular.
Tür değişince kategori seçimi temizlenir. Form geçerliyse gönderim anında
oturum ve API'den alınmış profil doğrulanır. Geçersiz form ve oturum
API gönderimine ulaşamaz. Aynı kurallar mevcut düzenleme formunda da kullanılır.
Kayıp/buluntu ilanlarında mevcut API bağlantısı tarihi null gönderir.

## Sahiplik politikası

`lib/security/listing_mutation_policy.dart` içindeki `ListingMutationPolicy`,
`RoleSessionPolicy` üzerinden oturum ve profil durumunu değerlendirir.

| İşlem | Koşul |
|---|---|
| Oluşturma | Doğrulanmış oturum ve boş olmayan profil kimliği |
| Düzenleme | Oluşturma koşulları ve `listing.sahipId == profile.id` |
| Silme | Oluşturma koşulları ve `listing.sahipId == profile.id` |

Profil yüklenirken, oturum doğrulaması başarısızken veya ilan bulunamazken
düzenleme/silme izni verilmez. Yönetici rolü normal ilan düzenleme/silme
akışında sahiplik kontrolünü atlatmaz. Moderasyon ayrı bir işlemdir.

`listing_access.dart`, politikaya AuthProvider'ın güncel durumunu aktarır.
Oluşturma ve düzenleme formu erişimi ve gönderim işlemi bu politikayı kullanır.
Detay ekranında düzenleme/silme düğmeleri yalnız doğrulanmış sahibine gösterilir.
Silme onay penceresi açılmadan ve onaylandıktan sonra yetki yeniden değerlendirilir;
arada hesap değişirse veya profil doğrulaması bozulursa API isteği gönderilmez.
Bu istemci kontrolü sunucu yetkilendirmesinin yerine geçmez; API sahipliği
erişim belirtecindeki kullanıcı üzerinden denetlemelidir.

## Doğrulama

`test/listing_validation_test.dart` zorunlu alanları, kategori eşleşmesini,
oturum/profil hatalarını ve öğrenci/yönetici sahiplik durumlarını sınar.
`test/create_listing_validation_test.dart` gerçek tema ve 390×844 ekran
boyutunda boş formu, tür değişimini, gerçek servis arayüzüne gönderimi,
başkasının düzenleme ekranına doğrudan erişimini, açık formda hesap değişimini
ve silme onayı sırasında hesap/profil değişimini sınar. Bu testlerde sahte servis
kullanılır; gerçek hesaplarla cihaz üzerinden canlı CRUD kontrolü yapılmış sayılmaz.

```sh
flutter test test/listing_validation_test.dart test/create_listing_validation_test.dart
```
