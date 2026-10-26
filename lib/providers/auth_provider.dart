import 'package:flutter/material.dart';
import '../models/models.dart';

/// Kimlik Doğrulama, Kullanıcı Oturum ve Rol Yönetimi Sağlayıcısı
class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    // Varsayılan öğrenci kullanıcısı ve oturumu
    _currentUser = Profil(
      id: '00000000-0000-0000-0000-000000000001',
      adSoyad: 'Berke Mahmut Acar',
      rol: KullaniciRolu.ogrenci,
      olusturulmaTarihi: DateTime.utc(2026, 10, 21),
      bolum: 'Bilgisayar Mühendisliği',
      sinif: '4. Sınıf',
    );
    _currentEmail = 'berke@ogr.edu.tr';
    _isLoggedIn = true;
  }

  Profil? _currentUser;
  String? _currentEmail;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;

  Profil? get currentUser => _currentUser;
  String? get currentEmail => _currentEmail;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Rol denetimleri
  bool get isAdmin => _currentUser?.rol == KullaniciRolu.yonetici;
  bool get isStudent => _currentUser?.rol == KullaniciRolu.ogrenci;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Giriş işlemi
  Future<bool> login({
    required String email,
    required String password,
    bool asAdmin = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    final trimmedEmail = email.trim().toLowerCase();
    final trimmedPass = password.trim();

    if (trimmedEmail.isEmpty || trimmedPass.isEmpty) {
      _errorMessage = 'Lütfen e-posta ve şifrenizi giriniz.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (trimmedPass.length < 6) {
      _errorMessage = 'Şifre en az 6 karakter olmalıdır.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Rol belirleme: 'admin' içeren e-posta veya asAdmin bayrağı yönetici yapar
    final isRoleAdmin = asAdmin || trimmedEmail.contains('admin');

    _currentEmail = trimmedEmail;
    _currentUser = Profil(
      id: isRoleAdmin
          ? '00000000-0000-0000-0000-000000000099'
          : '00000000-0000-0000-0000-000000000001',
      adSoyad: isRoleAdmin ? 'Kampüs Yönetici' : 'Berke Mahmut Acar',
      rol: isRoleAdmin ? KullaniciRolu.yonetici : KullaniciRolu.ogrenci,
      olusturulmaTarihi: DateTime.utc(2026, 10, 21),
      bolum: isRoleAdmin ? 'Rektörlük / Yönetim' : 'Bilgisayar Mühendisliği',
      sinif: isRoleAdmin ? '-' : '4. Sınıf',
    );

    _isLoggedIn = true;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  /// Kayıt işlemi
  Future<bool> register({
    required String adSoyad,
    required String email,
    required String password,
    String? bolum,
    String? sinif,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));

    final trimmedName = adSoyad.trim();
    final trimmedEmail = email.trim().toLowerCase();
    final trimmedPass = password.trim();

    if (trimmedName.length < 2) {
      _errorMessage = 'Ad Soyad en az 2 karakter olmalıdır.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (!trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
      _errorMessage = 'Geçerli bir kampüs e-posta adresi giriniz.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (trimmedPass.length < 6) {
      _errorMessage = 'Şifre en az 6 karakter olmalıdır.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _currentEmail = trimmedEmail;
    _currentUser = Profil(
      id: '00000000-0000-0000-0000-000000000002',
      adSoyad: trimmedName,
      rol: KullaniciRolu.ogrenci,
      olusturulmaTarihi: DateTime.now().toUtc(),
      bolum: bolum?.trim().isNotEmpty == true ? bolum!.trim() : 'Genel',
      sinif: sinif?.trim().isNotEmpty == true ? sinif!.trim() : '1. Sınıf',
    );

    _isLoggedIn = true;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  /// Profil Bilgilerini Güncelleme (Ad Soyad, Bölüm, Sınıf)
  Future<bool> updateProfile({
    required String adSoyad,
    String? bolum,
    String? sinif,
  }) async {
    final trimmedName = adSoyad.trim();
    if (trimmedName.length < 2 || _currentUser == null) return false;

    _currentUser = Profil(
      id: _currentUser!.id,
      adSoyad: trimmedName,
      rol: _currentUser!.rol,
      olusturulmaTarihi: _currentUser!.olusturulmaTarihi,
      bolum: bolum?.trim(),
      sinif: sinif?.trim(),
    );
    notifyListeners();
    return true;
  }

  /// Geriye dönük uyumluluk için profil adı güncelleme
  Future<bool> updateProfileName(String newName) => updateProfile(adSoyad: newName);

  /// Demo Gösterimi için Anında Rol Değiştirme (Öğrenci <-> Yönetici)
  void toggleRoleForDemo() {
    if (_currentUser == null) return;
    final newRole = _currentUser!.rol == KullaniciRolu.ogrenci
        ? KullaniciRolu.yonetici
        : KullaniciRolu.ogrenci;

    _currentUser = Profil(
      id: _currentUser!.id,
      adSoyad: newRole == KullaniciRolu.yonetici ? 'Kampüs Yönetici' : 'Berke Mahmut Acar',
      rol: newRole,
      olusturulmaTarihi: _currentUser!.olusturulmaTarihi,
      bolum: newRole == KullaniciRolu.yonetici ? 'Rektörlük / Yönetim' : 'Bilgisayar Mühendisliği',
      sinif: newRole == KullaniciRolu.yonetici ? '-' : '4. Sınıf',
    );
    notifyListeners();
  }

  /// Çıkış Yapma (Logout)
  void logout() {
    _currentUser = null;
    _currentEmail = null;
    _isLoggedIn = false;
    _errorMessage = null;
    notifyListeners();
  }
}
