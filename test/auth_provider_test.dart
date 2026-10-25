import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixcampus_mobile/models/models.dart';
import 'package:fixcampus_mobile/providers/auth_provider.dart';
import 'package:fixcampus_mobile/services/auth_service.dart';

class FakeAuthService implements AuthService {
  @override
  bool hasSession = false;
  bool fail = false;
  bool profileFails = false;
  bool signOutFails = false;
  Completer<void>? pendingSignIn;
  bool confirmEmail = false;
  String name = 'Berke Mahmut Acar';
  KullaniciRolu role = KullaniciRolu.ogrenci;
  final events = StreamController<void>.broadcast(sync: true);
  @override
  String? get email => hasSession ? 'test@example.com' : null;
  @override
  Stream<void> get changes => events.stream;
  @override
  Future<void> signIn(String email, String password) async {
    if (fail) throw StateError('offline');
    if (pendingSignIn != null) await pendingSignIn!.future;
    hasSession = true;
    events.add(null);
  }

  @override
  Future<void> signUp(String name, String email, String password) async {
    hasSession = !confirmEmail;
  }

  @override
  Future<void> signOut() async {
    if (signOutFails) throw StateError('offline');
    hasSession = false;
    events.add(null);
  }

  @override
  Future<Profil> loadProfile() async {
    if (profileFails) throw StateError('API offline');
    if (fail) throw StateError('offline');
    return Profil(
        id: '00000000-0000-0000-0000-000000000001',
        adSoyad: name,
        rol: role,
        olusturulmaTarihi: DateTime.utc(2026, 10, 21));
  }

  @override
  Future<Profil> saveProfile(String name) async {
    if (fail) throw StateError('offline');
    this.name = name;
    return loadProfile();
  }
}

void main() {
  late FakeAuthService service;
  late AuthProvider auth;
  setUp(() {
    service = FakeAuthService();
    auth = AuthProvider(service: service);
  });
  tearDown(() async {
    auth.dispose();
    await service.events.close();
  });

  test('Başlangıçta demo kullanıcı veya yetki verilmez', () {
    expect(auth.isLoggedIn, false);
    expect(auth.currentUser, null);
    expect(auth.isAdmin, false);
  });
  test('Kayıt profil adını kaydeder; çıkış profili temizler', () async {
    expect(
        await auth.register(
            adSoyad: ' Berna Kalkan ',
            email: 'b@example.com',
            password: 'password123'),
        true);
    expect(auth.currentUser?.adSoyad, 'Berna Kalkan');
    expect(auth.isAdmin, false);
    expect(await auth.logout(), true);
    expect(auth.isLoggedIn, false);
    expect(auth.currentUser, null);
  });
  test('Kayıt onay gerektiriyorsa giriş yapılmış sayılmaz', () async {
    service.confirmEmail = true;
    expect(
        await auth.register(
            adSoyad: 'Berna', email: 'b@example.com', password: 'password123'),
        true);
    expect(auth.isLoggedIn, false);
    expect(auth.message, contains('onaylayıp'));
  });
  test('SDK oturumu geri yüklenir; ad düzenlemesi kalıcı servise iletilir',
      () async {
    service.hasSession = true;
    await auth.initialize();
    expect(auth.currentUser, isNotNull);
    expect(await auth.updateProfile(' Berna Kalkan '), true);
    expect(service.name, 'Berna Kalkan');
    expect(await auth.updateProfile(' '), false);
    expect(service.name, 'Berna Kalkan');
  });
  test('Başarısız girişte loading kapanır ve kullanıcı oluşmaz', () async {
    service.fail = true;
    expect(await auth.login(email: 'b@example.com', password: 'wrong'), false);
    expect(auth.isLoading, false);
    expect(auth.currentUser, null);
    expect(auth.message, isNotNull);
  });
  test('Oturum sona erince profil ve yönetici yetkisi temizlenir', () async {
    service.hasSession = true;
    await auth.initialize();
    service.hasSession = false;
    service.events.add(null);
    expect(auth.currentUser, null);
    expect(auth.isLoggedIn, false);
    expect(auth.isAdmin, false);
  });
  test('Eksik yapılandırma sahte giriş sağlamaz', () async {
    final unconfigured = AuthProvider();
    expect(await unconfigured.login(email: 'a@b.com', password: 'password123'),
        false);
    expect(unconfigured.isLoggedIn, false);
    unconfigured.dispose();
  });
  test('Aynı anda iki giriş isteği gönderilmez', () async {
    service.pendingSignIn = Completer<void>();
    final first = auth.login(email: 'b@example.com', password: 'password123');
    expect(auth.isLoading, true);
    expect(await auth.login(email: 'b@example.com', password: 'password123'),
        false);
    service.pendingSignIn!.complete();
    expect(await first, true);
    expect(auth.isLoading, false);
  });
  test('SDK girişi sonrası profil API hatası tekrar denenebilir', () async {
    service.profileFails = true;
    expect(await auth.login(email: 'b@example.com', password: 'password123'),
        false);
    expect(auth.isLoggedIn, true);
    expect(auth.currentUser, null);
    expect(auth.isAdmin, false);
    service.profileFails = false;
    expect(await auth.initialize(), true);
    expect(auth.currentUser, isNotNull);
    expect(auth.message, null);
  });
  test(
      'Başarısız çıkışta kullanıcıya hata gösterilir ve oturum yanlışlıkla temizlenmez',
      () async {
    service.hasSession = true;
    await auth.initialize();
    service.signOutFails = true;
    expect(await auth.logout(), false);
    expect(auth.isLoggedIn, true);
    expect(auth.currentUser, isNotNull);
    expect(auth.message, isNotNull);
    expect(auth.isLoading, false);
  });
  test('SDK değişiklik bildirimi API rolünü yeniden okur', () async {
    service.hasSession = true;
    await auth.initialize();
    service.role = KullaniciRolu.yonetici;
    service.events.add(null);
    await Future<void>.delayed(Duration.zero);
    expect(auth.isAdmin, true);
    service.role = KullaniciRolu.ogrenci;
    service.events.add(null);
    await Future<void>.delayed(Duration.zero);
    expect(auth.isAdmin, false);
  });
  test('SDK yenileme hatası uygulamayı düşürmeden kullanıcıya bildirilir',
      () async {
    service.hasSession = true;
    await auth.initialize();
    service.events.addError(StateError('offline'));
    expect(auth.message, contains('Oturum yenilenemedi'));
    expect(auth.isLoading, false);
  });
}
