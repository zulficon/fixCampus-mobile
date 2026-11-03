# fixCampus Mobile

Üniversite kampüsündeki sosyal buluşma ve kayıp-buluntu ilanları için Flutter
mobil uygulaması. BLM4587 iOS ile Mobil Uygulama Geliştirme I dönem projesidir.

## Tamamlanan çalışmalar

### Birinci hafta

- **Berna Kalkan:** Profil, Kategori, Ilan, Katilim, IlanFotografi ve Sikayet
  modelleri; JSON dönüşümleri ve model doğrulama programı.
- **Berke Mahmut Acar:** Flutter proje iskeleti, Android yapılandırması,
  Material 3 tema, Provider altyapısı, menü geçişleri ve temel ekranlar.
- **Zülfikar Durak:** Dio tabanlı API servisleri, bağlantı ayarları, yanıt
  sözleşmeleri, hata yönetimi ve API bağlantı kontrol programı.

### İkinci hafta

- **Berna Kalkan:** Supabase SDK ile giriş, kayıt ve çıkış; oturum saklama ve
  yenileme; Web API üzerinden profil okuma ve ad soyad güncelleme.
- **Zülfikar Durak:** Öğrenci/yönetici ekran erişimi, profil doğrulama,
  uygulamaya dönüşte rol yenileme ve oturum kaybında korunan içeriği kapatma.
  Rol doğrulaması sırasında mevcut sekme durumu korunur.

### Üçüncü hafta — Berna: API bağlantısı

- `/api/kategoriler` ve `/api/ilanlar` üzerinden gerçek veri yükleme.
- İlan oluşturma, detay, güncelleme ve silme için tipli servis ve Provider bağlantısı.
- Auth ile ortak API istemcisi, güncel Bearer belirteci ve hesap değişiminde veri temizliği.
- API alan hataları, oturum/yetki hataları, silinmiş ilan, ağ hatası ve tekrar deneme.
- Mevcut form ve detay ekranında CRUD çağrıları; güncelleme/silme yalnızca sahibine gösterilir.

### Üçüncü hafta — Zülfikar: doğrulama ve sahiplik

- Ortak ilan doğrulaması: başlık 2–150, açıklama 1–3000, yer 1–200 karakter.
- Kategorinin ilan türüyle eşleşmesi ve sosyal ilan için gelecek tarih kontrolü.
- Oluşturma/düzenleme formunda güncel oturum ve profil kontrolü.
- Düzenleme/silmede ilan sahipliği; silme onayından sonra yetkiyi yeniden kontrol etme.
- Hesap veya profil doğrulama durumu değişince açık formdaki işlemleri kapatma.

## Uygulama ekranları

- Açılış ve oturum durumuna göre yönlendirme.
- Giriş ve kayıt.
- Sosyal Radar ve kategori filtreleri.
- Kayıp-Buluntu ve ilan türü filtreleri.
- İlan detay görünümü ve ilan verme formu taslağı.
- Profil bilgileri, ad soyad düzenleme, İlanlarım ve çıkış.
- Yönetici paneli taslağı ve rol kontrollü rota erişimi.

İlanlar ve kategoriler ortak ASP.NET Core Web API üzerinden yüklenir.
Oluşturma, detay okuma, güncelleme ve silme aynı Supabase verisi üzerinde çalışır.
Katılım ve şikâyet düğmeleri sonraki haftaların ekran iskeletidir.

## Çalıştırma

Gereksinimler: Flutter >= 3.47, Dart >= 3.13, Android SDK ve Android cihaz
veya emülatör. Doğrulamada Flutter 3.47.8 kullanılır. Profil ve ilan işlemleri için
ortak ASP.NET Core Web API çalışmalıdır.

```sh
flutter pub get
flutter run --dart-define=SUPABASE_URL=https://PROJE.supabase.co --dart-define=SUPABASE_ANON_KEY=PUBLIC_KEY --dart-define=API_BASE_URL=http://10.0.2.2:5168
```

`SUPABASE_ANON_KEY` için projenin açık publishable/anon anahtarı kullanılır.
Android emülatöründe bilgisayardaki API adresi `http://10.0.2.2:5168` olur.

USB üzerinden bağlı Android telefonda API bağlantısı:

```sh
adb reverse tcp:5168 tcp:5168
```

Bu bağlantıda uygulama `API_BASE_URL=http://127.0.0.1:5168` ile derlenir.

## Test ve derleme

```sh
flutter test --reporter expanded
flutter build apk --debug
```

3 Kasım 2026 doğrulamasında 106 Flutter testi ve ortak ağ projesinin Auth,
yetki/OpenAPI ve ilan kontrol projeleri geçti; Android debug APK derlendi. Ayrıntılar
[GitHub Actions](https://github.com/zulficon/fixCampus-mobile/actions/runs/41627725194)
ve [hafta 3 doğrulama belgesinde](docs/hafta-03-api-baglantisi.md) bulunur.
Gerçek iki hesaplı emülatör gösterimi raporun 4. hafta kontrolüdür.

## Teknik belgeler

- [Veri modelleri](docs/hafta-01-veri-modeli.md)
- [Mobil uygulama iskeleti](docs/hafta-01-mobil-iskelet.md)
- [API servisleri](docs/hafta-01-api-servisi.md)
- [Giriş ve profil](docs/hafta-02-auth-profil.md)
- [Rol ve oturum kontrolü](docs/hafta-02-rol-ve-oturum.md)
- [İlan doğrulama ve sahiplik](docs/hafta-03-ilan-dogrulama.md)
- [Üçüncü hafta ilan API bağlantısı ve doğrulama](docs/hafta-03-api-baglantisi.md)

## Ekip

| Ad soyad | Öğrenci numarası | GitHub |
|---|---|---|
| Berna Kalkan | 22290948 | [bernakalkann](https://github.com/bernakalkann) |
| Berke Mahmut Acar | 22290455 | [berke1227](https://github.com/berke1227) |
| Zülfikar Durak | 22290590 | [zulficon](https://github.com/zulficon) |
