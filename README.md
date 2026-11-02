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
- **Berke Mahmut Acar:** Giriş ve kayıt formları (`LoginScreen`, `RegisterScreen`),
  form validasyonları, şifre gizle/göster ve profil bölüm/sınıf yönetimi.
- **Zülfikar Durak:** Öğrenci/yönetici ekran erişimi, profil doğrulama,
  uygulamaya dönüşte rol yenileme ve oturum kaybında korunan içeriği kapatma.
  Rol doğrulaması sırasında mevcut sekme durumu korunur.

### Üçüncü hafta

- **Berke Mahmut Acar:** İlan verme formu (`CreateListingScreen`), zengin detay
  görünümü (`ListingDetailScreen`), ilan düzenleme ekranı (`EditListingScreen`),
  silme onay iletişim kutusu (`AlertDialog`), DatePicker ve TimePicker ile buluşma
  tarihi/saati seçimi ve `AppRoutes.editListing` rotası.
- **Berna Kalkan:** CRUD API servis katmanı (`ListingService`, `ApiListingService`),
  `ApiClient` üzerinden JWT Bearer token ile uç nokta haberleşmesi ve
  `ListingsProvider` durum yönetimi katmanı.
- **Zülfikar Durak:** `ListingValidator` alan doğrulama kuralları (başlık 3-150,
  açıklama 5-3000, yer 2-200), Sosyal için gelecek tarih zorunluluğu, Kayıp/Buluntu
  için tarih kısıtlaması, kategori-tür eşleşmesi ve sahiplik/yönetici yetki denetimi.

## Uygulama ekranları

- Açılış ve oturum durumuna göre yönlendirme.
- Giriş ve kayıt.
- Sosyal Radar ve kategori filtreleri.
- Kayıp-Buluntu ve ilan türü filtreleri.
- İlan detay görünümü, düzenleme ve silme aksiyonları.
- Dinamik tür, kategori ve tarih/saat seçimli yeni ilan verme formu.
- İlan düzenleme formu ve yetki denetimi.
- Profil bilgileri, ad soyad düzenleme, İlanlarım ve çıkış.
- Yönetici paneli ve rol kontrollü rota erişimi.

## Çalıştırma

Gereksinimler: Flutter >= 3.35, Dart >= 3.9, Android SDK ve Android cihaz
veya emülatör. Profil işlemleri için ortak ASP.NET Core Web API çalışmalıdır.

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

3. Hafta doğrulamasında 106 test geçti, `flutter analyze` 0 uyarı/hata verdi ve model doğrulama programı başarılı oldu.

## Teknik belgeler

- [Veri modelleri](docs/hafta-01-veri-modeli.md)
- [Mobil uygulama iskeleti](docs/hafta-01-mobil-iskelet.md)
- [API servisleri](docs/hafta-01-api-servisi.md)
- [Giriş ve profil](docs/hafta-02-auth-profil.md)
- [Rol ve oturum kontrolü](docs/hafta-02-rol-ve-oturum.md)
- [İlan CRUD ve sayfaları](docs/hafta-03-ilan-crud-ve-sayfalari.md)

## Ekip

| Ad soyad | Öğrenci numarası | GitHub |
|---|---|---|
| Berna Kalkan | 22290948 | [bernakalkann](https://github.com/bernakalkann) |
| Berke Mahmut Acar | 22290455 | [berke1227](https://github.com/berke1227) |
| Zülfikar Durak | 22290590 | [zulficon](https://github.com/zulficon) |
