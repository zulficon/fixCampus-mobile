# Hafta 2 — Kimlik Doğrulama, Formlar, Profil ve Rol Yönetimi

Dönem projesi plan belgesindeki 2. Hafta hedefleri doğrultusunda, **fixCampus** mobil uygulamasında kayıt, giriş, çıkış ve profil akışları tamamlanmış; **Öğrenci** ve **Yönetici** rolleri tanımlanarak yetki denetimleri mobil arayüze entegre edilmiştir.

---

## 1. Görev Paylaşımı ve Sorumluluklar

| Üye | Rol & Sorumluluk | Yapılan Çalışmalar |
| :--- | :--- | :--- |
| **Berke Mahmut Acar** | **Giriş ve Kayıt Formları** | `LoginScreen` ve `RegisterScreen` üzerinde `Form` validasyonları, regex tabanlı kampüs e-posta denetimi, şifre uzunluğu ve parola eşleştirme, dinamik şifre gizle/göster (`obscureText`) butonları, buton üzerinde yükleniyor göstergeleri (`isLoading`) ve kullanıcı dostu hata bildirimleri. |
| **Berna Kalkan** | **Auth ve Profil Yönetimi** | `AuthProvider` durum yönetimi katmanı, oturum açma (`login`), kayıt olma (`register`), profil bilgisi düzenleme (`updateProfileName`) ve güvenli oturum kapatma (`logout`) akışları. |
| **Zülfikar Durak** (Lider) | **Rol Kontrolü ve Yetkilendirme** | `KullaniciRolu.ogrenci` ve `KullaniciRolu.yonetici` ayrımı, `SplashScreen` üzerindeki kimlik doğrulama yönlendirmesi (Auth Guard), `AdminPanelScreen` erişim koruması ve sunum provası için hızlı rol değiştirme mekanizması. |

---

## 2. Geliştirilen Ekranlar ve Akış Detayları

### 2.1. Giriş Formu (`lib/screens/auth/login_screen.dart`)
* **Doğrulama (Validation)**: E-posta formatı (`@` ve `.` kontrolü) ile minimum 6 karakterlik şifre kontrolleri `TextFormField` validator fonksiyonları ile denetlenir.
* **Göz İkonu (Toggle Obscure)**: Kullanıcı şifresini yazarken tek tıkla görünür/gizli yapabilir.
* **Yüklenme & Hata Durumu**: Giriş isteği sırasında buton üzerinde yükleniyor animasyonu çıkar ve olası hata durumlarında kırmızı bildirim kutusu ekranda belirir.
* **Hızlı Rol Testi Butonları**: Jüri ve sunum ortamında test kolaylığı sağlamak amacıyla *"Öğrenci Girişi"* ve *"Yönetici Girişi"* tek tıklamalı hızlı test butonları eklenmiştir.

### 2.2. Kayıt Formu (`lib/screens/auth/register_screen.dart`)
* **Eksiksiz Form Alanları**: Ad Soyad, Kampüs E-Postası, Parola ve Parola Tekrarı alanları.
* **Şifre Eşleştirme**: Parola ile parola tekrarı eşleşmediğinde form gönderimi engellenir ve anında uyarı verilir.
* **Öğrenci Rolü Kuralı**: Proje şartnamesi gereği yeni kaydolan tüm hesaplar otomatik olarak `Öğrenci` yetkisiyle oluşturulur.

### 2.3. Profil ve Çıkış İşlemleri (`lib/screens/profile/profile_screen.dart`)
* **Kullanıcı Bilgileri ve Rol Rozeti**: Kullanıcının adı, e-posta adresi ve rolüne göre renkli rozet (`Öğrenci` mavi / `Yönetici` siyah) görüntülenir.
* **Profili Düzenle**: Modal dialog penceresi açılarak kullanıcının ad-soyad bilgisini güncellemesine olanak tanınır.
* **Güvenli Çıkış (Logout)**: Kullanıcıdan onay isteyen çıkış iletişim kutusu sonrasında oturum sonlandırılır ve giriş ekranına yönlendirilir.

### 2.4. Rol Yetki Kontrolleri ve Yönetici Paneli (`lib/screens/admin/admin_panel_screen.dart`)
* **Yetki Koruması (Admin Guard)**: `AdminPanelScreen` ekranına giriş yetki denetimine tabi tutulmuştur. Eğer hesap Yönetici rolüne sahip değilse panel yerine *"Yetkisiz Erişim / Erişim İzniniz Yok"* uyarısı görüntülenir.
* **Dinamik Kart Gösterimi**: Profil ekranındaki *"Yönetici Paneli"* butonu yalnızca oturum sahibi **Yönetici** ise görünür; Öğrenci oturumunda gizlenir.

---

## 3. Ekran ve Navigasyon Akış Şeması

```mermaid
flowchart TD
    Splash([SplashScreen]) --> CheckAuth{Oturum Açık mı?}
    CheckAuth -- Hayır --> Login[LoginScreen]
    CheckAuth -- Evet --> Shell[MainShellScreen]

    Login <--> Register[RegisterScreen]
    Login --> Shell
    Register --> Shell

    subgraph MainTabs [Ana Sekmeler]
        Shell --> Radar[1. Radar]
        Shell --> LostFound[2. Kayıp & Buluntu]
        Shell --> Create[3. İlan Ver]
        Shell --> Profile[4. Profil]
    end

    Profile --> EditProfile[Profili Düzenle Dialog]
    Profile --> Logout([Çıkış Yap]) --> Login

    Profile -- Rol: Yönetici --> AdminPanel[AdminPanelScreen]
    Profile -- Rol: Öğrenci (Erişim Yok) -.-> Denied[Yetkisiz Erişim]
```

---

## 4. Doğrulama ve Kod Analizi

* `flutter analyze lib/`: 0 hata ve 0 uyarı ile tamamlandı.
* Uygulama bağımsız telefon penceresinde çalıştırılarak form validasyonları, hızlı rol geçişleri ve çıkış senaryoları uçtan uca test edildi.
