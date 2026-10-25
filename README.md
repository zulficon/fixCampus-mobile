# fixCampus Mobile

fixCampus üniversite kampüs platformunun Flutter mobil uygulaması deposudur.

BLM4587 iOS ile Mobil Uygulama Geliştirme I dersi dönem projesidir.

---

## 📌 Proje Durumu (Hafta 1)

1. Hafta (21–25 Ekim 2026) hedefleri doğrultusunda:
- **Berna Kalkan**: Flutter ortak veri modelleri (`lib/models/`) tanımlandı, JSON serileştirme sözleşmesi ve test programı hazırlandı ([docs/hafta-01-veri-modeli.md](docs/hafta-01-veri-modeli.md)).
- **Berke Mahmut Acar**: Flutter proje iskeleti, Android yapılandırması, Material 3 kampüs teması, rota yönetimi, durum yönetimi (`provider`) ve temel ekran akışları geliştirildi ([docs/hafta-01-mobil-iskelet.md](docs/hafta-01-mobil-iskelet.md)).
- **Zülfikar Durak**: Dio tabanlı API servisleri, yanıt sözleşmeleri ve bağlantı kontrolü (`lib/services/api_service.dart`) hazırlandı.

---

## 📱 Ekran Akışları

1. **Açılış (Splash)**: Oturum durumuna göre yönlendirme.
2. **Kimlik Doğrulama (Auth)**: Öğrenci ve Yönetici rolü ile Giriş / Kayıt ekranları.
3. **Ana Kabuk (Main Shell)**:
   - **Sosyal Radar**: Kampüsteki ders çalışma, spor ve buluşma etkinlikleri, kategori filtreleri, "Geliyorum" katılım sistemi.
   - **Kayıp & Buluntu**: Kayıp eşyalar ve bulunan eşyalar sekmesi, aktif/çözüldü durumu filtreleme.
   - **Yeni İlan Ver**: Sosyal buluşma (tarih/saat seçici) ve Kayıp-Buluntu (fotoğraf alanı) ilan oluşturma.
   - **Profil**: Kullanıcı bilgileri, "İlanlarım" listesi, demo rol değiştirici ve çıkış.
4. **İlan Detayı**: Konum, zaman, açıklama, katılım durumu, çözüldü işaretleme ve "Şikâyet Et" modal formu.
5. **Yönetici Paneli**: Uygunsuz ilan şikâyetlerini inceleme, ilanı gizleme ve kategorileri denetleme.

---

## 🚀 Çalıştırma

Gereksinimler: Flutter SDK (>= 3.10.0), Android SDK veya Emülatör.

```powershell
# Bağımlılıkları yükleyin
flutter pub get

# Uygulamayı Android emülatörde veya cihazda çalıştırın
flutter run
```

---

## 👥 Grup Üyeleri

- Berna Kalkan (22290948, bernakalkann)
- Berke Mahmut Acar (22290455, berke1227)
- Zülfikar Durak (22290590, zulficon)

🔗 **GitHub:** [zulficon/fixCampus-mobile](https://github.com/zulficon/fixCampus-mobile)

## Zülfikar birinci hafta API katkısı

Dio tabanlı salt okunur servis `lib/services/api_service.dart` içindedir.
Durum, örnek ilanlar ve veritabanı demosu için ayrı yanıt sözleşmeleri ile
bağlantı, zaman aşımı, HTTP ve JSON hata yönetimini içerir. Ayrıntılar:
[hafta-01-api-servisi.md](docs/hafta-01-api-servisi.md).

Bu servis, Berke'nin `ApiClient` iskeletinden ve Berna'nın ikinci hafta
giriş/profil entegrasyonundan ayrı bir katkıdır. İlan ekranları halen
`ListingsProvider` içindeki demo kayıtları kullanır.

```powershell
$env:PUB_CACHE = "$PWD\.pub-cache"
flutter pub get
flutter test test/api_service_test.dart
dart run tool/check_api.dart http://127.0.0.1:5168
```

Son komut için .NET API açık olmalıdır. `sample` / `isPersisted: false` çıktısı
sabit örnek veriyi belirtir; canlı veritabanı okuması ayrı değerlendirilir.

## Zülfikar ikinci hafta rol ve oturum katkısı

API profili doğrulanmadan korunan sayfa açılmaz; öğrenci yönetici sayfasına
erişemez. Rol yeniden okunurken içerik gizlenir, doğrulama sonrası sekme durumu
korunur. Profil API hatasında eski yönetici bilgisi kullanılmaz. Uygulamaya
dönüşte rol yeniden okunur; oturum kaybında içerik kaldırılır.

Ortak `AuthGuard`, `RoleSessionGuard` katmanına yönlendirilmiştir. Berna'nın
giriş/profil servisi, Provider'ı ve modelleri değiştirilmemiştir.

- [Rol ve oturum görevi](docs/hafta-02-rol-ve-oturum.md)
- [Berna ikinci hafta incelemesi](docs/berna-hafta-02-inceleme.md)

Bu kontrol mobil ekran erişimi içindir. Gerçek yönetim uçlarında sunucu
yetkilendirmesi ayrıca gerekir. İlanlar halen demo verisi kullanır.
