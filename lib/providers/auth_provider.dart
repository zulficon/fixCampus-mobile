import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../services/auth_service.dart';

/// Kimlik Doğrulama, Kullanıcı Oturum ve Rol Yönetimi Sağlayıcısı
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? service}) : _service = service {
    _subscription = service?.changes.listen(
      (_) {
        if (_isLoading) return; // İşlemin son durumunu tek yerde uygula.
        if (!service.hasSession) {
          _currentUser = null;
          _message = null;
          _hasSessionError = false;
          notifyListeners();
        } else {
          unawaited(initialize());
        }
      },
      onError: (Object error) {
        _hasSessionError = true;
        _message =
            'Oturum yenilenemedi. Bağlantınızı kontrol edip tekrar deneyin.';
        _notify();
      },
    );
  }

  final AuthService? _service;
  StreamSubscription<void>? _subscription;
  Profil? _currentUser;
  bool _isLoading = false;
  bool _disposed = false;
  String? _message;
  bool _hasSessionError = false;

  // Yerel hafızada tutulan bölüm ve sınıf (backend profili desteklemediğinde arayüzde korumak için)
  String? _cachedBolum;
  String? _cachedSinif;

  bool get hasSessionError => _hasSessionError;
  Profil? get currentUser => _currentUser;
  bool get isLoggedIn => _service?.hasSession ?? false;
  bool get isLoading => _isLoading;
  bool get isAdmin =>
      isLoggedIn &&
      !_hasSessionError &&
      _currentUser?.rol == KullaniciRolu.yonetici;
  bool get isStudent => !isAdmin;

  String? get email => _service?.email;
  String? get currentEmail => _service?.email;
  String? get message => _message;
  String? get errorMessage => _message;
  bool get isConfigured => _service != null;

  void clearError() {
    _message = null;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<bool> _run(
    Future<void> Function(AuthService) action, {
    bool sessionOperation = true,
  }) async {
    var succeeded = false;
    if (_isLoading) return false;
    final service = _service;
    _message = null;
    if (sessionOperation) _hasSessionError = false;
    if (service == null) {
      _message =
          'Supabase bağlantı ayarları eksik. Kurulum belgesini kontrol edin.';
      _notify();
      return false;
    }
    _isLoading = true;
    _notify();
    try {
      await action(service);
      succeeded = true;
      return true;
    } on AuthException catch (e) {
      _message = e.code == 'invalid_credentials'
          ? 'E-posta veya parola hatalı.'
          : 'Kimlik doğrulama tamamlanamadı. Bilgilerinizi ve e-posta onayını kontrol edin.';
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        _hasSessionError = true;
      }
      _message = e.response?.statusCode == 401
          ? 'Oturum doğrulanamadı. Çıkış yapıp yeniden giriş yapın.'
          : 'Profil API’sine ulaşılamadı. Bağlantıyı kontrol edip tekrar deneyin.';
    } catch (_) {
      _message =
          'İşlem tamamlanamadı. Bağlantınızı kontrol edip tekrar deneyin.';
    } finally {
      if (sessionOperation) _hasSessionError = !succeeded;
      if (!service.hasSession) {
        _currentUser = null;
        _hasSessionError = false;
      }
      _isLoading = false;
      _notify();
    }
    return false;
  }

  Future<bool> initialize() => _run((s) async {
        final profile = s.hasSession ? await s.loadProfile() : null;
        if (profile != null) {
          _currentUser = profile.copyWith(
            bolum: profile.bolum ?? _cachedBolum ?? 'Bilgisayar Mühendisliği',
            sinif: profile.sinif ?? _cachedSinif ?? '4. Sınıf',
          );
        } else {
          _currentUser = null;
        }
      });

  Future<bool> login({
    required String email,
    required String password,
    bool asAdmin = false,
  }) =>
      _run((s) async {
        _currentUser = null;
        await s.signIn(email.trim(), password);
        final profile = await s.loadProfile();
        _currentUser = profile.copyWith(
          bolum: profile.bolum ?? _cachedBolum ?? (asAdmin ? 'Rektörlük / Yönetim' : 'Bilgisayar Mühendisliği'),
          sinif: profile.sinif ?? _cachedSinif ?? (asAdmin ? '-' : '4. Sınıf'),
        );
      });

  Future<bool> register({
    required String adSoyad,
    required String email,
    required String password,
    String? bolum,
    String? sinif,
  }) {
    if (bolum != null) _cachedBolum = bolum.trim();
    if (sinif != null) _cachedSinif = sinif.trim();

    return _run((s) async {
      _currentUser = null;
      await s.signUp(adSoyad.trim(), email.trim(), password);
      if (s.hasSession) {
        final profile = await s.saveProfile(adSoyad.trim());
        _currentUser = profile.copyWith(
          bolum: _cachedBolum ?? 'Bilgisayar Mühendisliği',
          sinif: _cachedSinif ?? '1. Sınıf',
        );
      } else {
        _message = 'Hesap oluşturuldu. E-postanızı onaylayıp giriş yapın.';
      }
    });
  }

  Future<bool> updateProfile(
    String name, {
    String? bolum,
    String? sinif,
  }) async {
    final trimmed = name.trim();
    if (trimmed.length < 2 || trimmed.length > 100) {
      _message = 'Ad soyad 2–100 karakter olmalıdır.';
      _notify();
      return false;
    }
    if (bolum != null) _cachedBolum = bolum.trim();
    if (sinif != null) _cachedSinif = sinif.trim();

    return _run((s) async {
      final updated = await s.saveProfile(trimmed);
      _currentUser = updated.copyWith(
        bolum: _cachedBolum ?? _currentUser?.bolum ?? 'Bilgisayar Mühendisliği',
        sinif: _cachedSinif ?? _currentUser?.sinif ?? '4. Sınıf',
      );
    }, sessionOperation: false);
  }

  Future<bool> updateProfileDetails({
    required String adSoyad,
    String? bolum,
    String? sinif,
  }) =>
      updateProfile(adSoyad, bolum: bolum, sinif: sinif);

  /// Demo rol değiştirme (Öğrenci <-> Yönetici)
  void toggleRoleForDemo() {
    if (_currentUser == null) return;
    final newRole = _currentUser!.rol == KullaniciRolu.ogrenci
        ? KullaniciRolu.yonetici
        : KullaniciRolu.ogrenci;

    _currentUser = _currentUser!.copyWith(
      rol: newRole,
      bolum: newRole == KullaniciRolu.yonetici ? 'Rektörlük / Yönetim' : (_cachedBolum ?? 'Bilgisayar Mühendisliği'),
      sinif: newRole == KullaniciRolu.yonetici ? '-' : (_cachedSinif ?? '4. Sınıf'),
    );
    notifyListeners();
  }

  Future<bool> logout() => _run((s) async {
        await s.signOut();
        _currentUser = null;
      });

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
