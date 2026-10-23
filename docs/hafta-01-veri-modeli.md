# Hafta 1 — Berna Kalkan: Flutter veri modeli

Altı değişmez Dart sınıfı lib/models altında tanımlandı. Her model fromJson
ve toJson içerir. Ek paket gerektirmez; Flutter iskeletine bağımlı değildir.
Toplu import: import 'package:fixcampus_mobile/models/models.dart';

| Model | Web tablosu | İlişki alanları |
|---|---|---|
| Profil | Profiller | id, Supabase Auth UUID değeri |
| Kategori | Kategoriler | id |
| Ilan | Ilanlar | sahipId, kategoriId |
| Katilim | Katilimlar | ilanId, profilId |
| IlanFotografi | IlanFotograflari | ilanId |
| Sikayet | Sikayetler | ilanId, bildirenId |

## JSON sözleşmesi

Alan adları ASP.NET Core varsayılan camelCase biçimindedir; örneğin SahipId
mobilde sahipId olur. UUID değerleri String, tarihler DateTime olarak taşınır.
Tarih metni UTC Z veya açık saat dilimi içermelidir; yazarken UTC kullanılır.
BulusmaTarihi JSON alanı bulusmaTarihi olup null olabilir.
Rol, tür ve durum değerleri web modellerindeki metinlerle eşleşir:
Ogrenci/Yonetici, Sosyal/Kayip/Buluntu, Aktif/Cozuldu/Gizli ve Bekliyor/Incelendi.
Bilinmeyen enum, eksik zorunlu alan veya yanlış veri tipi FormatException üretir.

Bu sözleşme ilk hafta için web veri modeliyle eşleştirilmiştir. CRUD API henüz
hazır olmadığından gerçek API yanıtlarıyla entegrasyon kontrolü daha sonra yapılır.
Mevcut /api/ornek/ilanlar örnek uç noktası farklı bir sunum sözleşmesidir;
buradaki tam varlık modellerinin yanıtını henüz sağlamaz.

Modeller ilişkili nesneleri iç içe taşımaz; yalnız kimliklerini saklar.
Tekrar katılım, tek fotoğraf, sahiplik ve rol denetimleri sunucu/veritabanında
uygulanır. Profil rol alanı veri okumak içindir; istemciye rol değiştirme yetkisi
vermez. toJson tam veri dönüşümüdür; API yazma istekleri için yetkili alanları
seçen ayrı istek nesneleri servis görevinde hazırlanmalıdır.

## Kapsam ve kontrol

Yalnızca Berna'nın veri modeli görevi uygulanmıştır. Ekran, Auth, API servisi,
Supabase bağlantısı ve yeni veritabanı bu katkıya dahil değildir.
Parola, veritabanı bağlantısı veya gizli anahtar içermez.

Dart SDK kurulu ortamda depo kökünden:

    dart format lib/models tool/verify_models.dart
    dart analyze lib/models tool/verify_models.dart
    dart run tool/verify_models.dart

Kontrol programı altı modelin JSON gidiş-dönüşünü, null buluşma tarihini,
UTC dönüşümünü ve hatalı alan/enum reddini sınar.
Hazırlama ortamında Dart/Flutter bulunmadığından bu komutlar burada çalıştırılamadı.
