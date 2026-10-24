import 'package:flutter/material.dart';
import '../models/models.dart';

/// Kimlik Doğrulama ve Kullanıcı Oturum Yönetimi (İskelet & Demo Sağlayıcı)
class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    // Hafta 1 demosu için varsayılan örnek öğrenci kullanıcısı
    _currentUser = Profil(
      id: '00000000-0000-0000-0000-000000000001',
      adSoyad: 'Berke Mahmut Acar',
      rol: KullaniciRolu.ogrenci,
      olusturulmaTarihi: DateTime.utc(2026, 10, 21),
    );
    _isLoggedIn = true;
  }

  Profil? _currentUser;
  bool _isLoggedIn = false;
  bool _isLoading = false;

  Profil? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  bool get isAdmin => _currentUser?.rol == KullaniciRolu.yonetici;

  /// Giriş işlemi (Hafta 2'de Supabase Auth SDK ile bağlanacak iskelet)
  Future<bool> login({
    required String email,
    required String password,
    bool asAdmin = false,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _currentUser = Profil(
      id: asAdmin
          ? '00000000-0000-0000-0000-000000000099'
          : '00000000-0000-0000-0000-000000000001',
      adSoyad: asAdmin ? 'Kampüs Yönetici' : 'Berke Mahmut Acar',
      rol: asAdmin ? KullaniciRolu.yonetici : KullaniciRolu.ogrenci,
      olusturulmaTarihi: DateTime.now().toUtc(),
    );
    _isLoggedIn = true;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Kayıt işlemi
  Future<bool> register({
    required String adSoyad,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _currentUser = Profil(
      id: '00000000-0000-0000-0000-000000000002',
      adSoyad: adSoyad,
      rol: KullaniciRolu.ogrenci,
      olusturulmaTarihi: DateTime.now().toUtc(),
    );
    _isLoggedIn = true;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Demo rol değiştirme (Öğrenci <-> Yönetici)
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
    );
    notifyListeners();
  }

  /// Çıkış yapma
  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
