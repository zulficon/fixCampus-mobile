import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../services/auth_service.dart';

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
  bool get hasSessionError => _hasSessionError;
  Profil? get currentUser => _currentUser;
  bool get isLoggedIn => _service?.hasSession ?? false;
  bool get isLoading => _isLoading;
  bool get isAdmin =>
      isLoggedIn &&
      !_hasSessionError &&
      _currentUser?.rol == KullaniciRolu.yonetici;
  String? get email => _service?.email;
  String? get message => _message;
  bool get isConfigured => _service != null;

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
    _currentUser = s.hasSession ? await s.loadProfile() : null;
  });

  Future<bool> login({required String email, required String password}) =>
      _run((s) async {
        _currentUser = null;
        await s.signIn(email.trim(), password);
        _currentUser = await s.loadProfile();
      });

  Future<bool> register({
    required String adSoyad,
    required String email,
    required String password,
  }) => _run((s) async {
    _currentUser = null;
    await s.signUp(adSoyad.trim(), email.trim(), password);
    if (s.hasSession) {
      // API sahipliği tokendan çıkarır; rol ve kullanıcı ID'si gönderilmez.
      _currentUser = await s.saveProfile(adSoyad.trim());
    } else {
      _message = 'Hesap oluşturuldu. E-postanızı onaylayıp giriş yapın.';
    }
  });

  Future<bool> updateProfile(String name) async {
    if (name.trim().length < 2 || name.trim().length > 100) {
      _message = 'Ad soyad 2–100 karakter olmalıdır.';
      _notify();
      return false;
    }
    return _run((s) async {
      _currentUser = await s.saveProfile(name.trim());
    }, sessionOperation: false);
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
