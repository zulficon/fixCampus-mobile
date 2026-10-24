# fixCampus Mobile

fixCampus üniversite kampüs platformunun Flutter mobil uygulaması deposudur.

BLM4587 iOS ile Mobil Uygulama Geliştirme I dersi dönem projesidir.

---

## 📌 Proje Durumu (Hafta 1)

1. Hafta (21–25 Ekim 2026) hedefleri doğrultusunda:
- **Berna Kalkan**: Flutter ortak veri modelleri (`lib/models/`) tanımlandı, JSON serileştirme sözleşmesi ve test programı hazırlandı ([docs/hafta-01-veri-modeli.md](docs/hafta-01-veri-modeli.md)).
- **Berke Mahmut Acar**: Flutter proje iskeleti, Android yapılandırması, Material 3 kampüs teması, rota yönetimi, durum yönetimi (`provider`) ve temel ekran akışları geliştirildi ([docs/hafta-01-mobil-iskelet.md](docs/hafta-01-mobil-iskelet.md)).
- **Zülfikar Durak**: Ortak API istemcisi ve bağlantı yapılandırması (`lib/core/network/api_client.dart`) hazırlandı.

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
