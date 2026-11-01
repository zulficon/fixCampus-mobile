# İlan doğrulama ve sahiplik

## Alan doğrulama

`lib/validation/listing_validator.dart` oluşturma ve düzenleme formlarında
kullanılabilen ortak kuralları içerir:

- Başlık, açıklama ve yer boş veya yalnızca boşluk olamaz.
- Kategori, güncel kategori listesinde bulunmalıdır.
- Sosyal ilan sosyal kategori kullanır. Kayıp ve buluntu ilanları mevcut
  formdaki ortak eşya kategorilerini kullanır.

`CreateListingScreen` bu kuralları `Form` ve `TextFormField` ile uygular.
Tür değişince kategori seçimi temizlenir. Form geçerliyse gönderim anında
oturum ve API'den alınmış profil doğrulanır. Geçersiz form ve oturum
mevcut gönderim işlemine ulaşamaz.

Formun gönderim işlemi hâlen iskelet bildirimidir; API'ye kayıt oluşturmaz.
Sunucunun metin uzunluğu sınırları için bir API sözleşmesi tanımlanmadığından
bu katman bağımsız bir üst uzunluk sınırı dayatmaz. Tarih/saat seçimi ve
süresi geçmiş ilan kuralları bu haftaki doğrulamaya dahil değildir.

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

Oluşturma formu politikayı kullanır. Düzenleme ve silme ekranları/istekleri
henüz uygulanmadığı için bu iki işlemde politika bağlantısı bulunmaz.
Bu istemci kontrolü sunucu yetkilendirmesinin yerine geçmez; API sahipliği
erişim belirtecindeki kullanıcı üzerinden denetlemelidir.

## Doğrulama

`test/listing_validation_test.dart` zorunlu alanları, kategori eşleşmesini,
oturum/profil hatalarını ve öğrenci/yönetici sahiplik durumlarını sınar.
`test/create_listing_validation_test.dart` gerçek tema ve 390×844 ekran
boyutunda boş formu, tür değişimini ve gönderim öncesi oturum kontrolünü sınar.

```sh
flutter test test/listing_validation_test.dart test/create_listing_validation_test.dart
```
