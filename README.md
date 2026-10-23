# fixCampus Mobile

fixCampus kampüs platformunun Flutter mobil uygulaması için ayrı Git deposu.

## Durum

Depo hazırlandı. Flutter uygulama iskeleti henüz oluşturulmadı.

## Planlanan yapı

- Mobil uygulama: Flutter / Dart, ilk hedef Android.
- Veri ve iş kuralları: ortak ASP.NET Core API.
- Kimlik doğrulama ve fotoğraf depolama: proje planına göre Supabase Auth ve Storage.
- İlk sürüm hedefi: Sosyal Radar ve Kayıp-Buluntu.

Bu maddeler planlanan kapsamdır; uygulanmış özellikler değildir.

## Geliştirmeye başlama

Flutter uygulamasını bu depo kökünde oluşturmak için:

```powershell
flutter create --project-name fixcampus_mobile --platforms android .
flutter run
```

Depo adı `fixCampus-mobile`, Dart proje adı `fixcampus_mobile` olarak kullanılır.

## Yapılandırma

Gerçek ortam dosyalarını ve imzalama anahtarlarını Git'e eklemeyin. Veritabanı
parolası ve Supabase service_role/secret anahtarları yalnızca sunucuda tutulur.

## Git

Ana dal: `main`. Uzak depo henüz bağlanmadı.
