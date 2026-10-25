import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:supabase/supabase.dart';
import 'package:fixcampus_mobile/core/network/api_client.dart';
import 'package:fixcampus_mobile/services/auth_service.dart';

/// Gerçek Supabase + ASP.NET API. Yapılandırma dosyası git dışında tutulur.
/// İki ayrı test hesabı oluşturur; mevcut kullanıcı verisini değiştirmez.
Future<void> main(List<String> args) async {
  if (args.length != 2) {
    stderr.writeln(
        'Kullanım: dart run tool/live_auth_check.dart CONFIG_JSON RAPOR_JSON');
    exitCode = 2;
    return;
  }
  final config =
      jsonDecode(await File(args[0]).readAsString()) as Map<String, dynamic>;
  final url = config['SUPABASE_URL'] as String;
  final key = config['SUPABASE_ANON_KEY'] as String;
  final apiUrl = config['API_BASE_URL'] as String;
  final results = <Map<String, dynamic>>[];
  final clients = <SupabaseClient>[];
  final http = Dio(BaseOptions(
      baseUrl: apiUrl,
      validateStatus: (_) => true,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30)));
  final stamp = DateTime.now().toUtc().microsecondsSinceEpoch;
  final random = Random.secure();
  final password =
      'Fc!${List.generate(24, (_) => random.nextInt(10)).join()}aZ';
  final emailA = 'fixcampus-mobile-a-$stamp@example.com';
  final emailB = 'fixcampus-mobile-b-$stamp@example.com';
  SupabaseClient client() {
    final c = SupabaseClient(url, key,
        authOptions: AuthClientOptions(
            autoRefreshToken: false, pkceAsyncStorage: _MemoryPkceStorage()));
    clients.add(c);
    return c;
  }

  SupabaseAuthService service(SupabaseClient c) => SupabaseAuthService(
      c,
      ApiClient(
          baseUrl: apiUrl,
          tokenProvider: () => c.auth.currentSession?.accessToken));
  void require(bool condition, String message) {
    if (!condition) throw StateError(message);
  }

  Future<void> check(String name, Future<void> Function() action) async {
    try {
      await action();
      results.add({'test': name, 'status': 'PASS'});
      stdout.writeln('PASS: $name');
    } catch (e, stack) {
      final detail = switch (e) {
        AuthException a =>
          'AuthException code=${a.code} status=${a.statusCode}',
        DioException d =>
          'DioException type=${d.type.name} status=${d.response?.statusCode}',
        StateError s => s.message,
        _ => e.runtimeType.toString(),
      };
      stderr.writeln(stack);
      results.add({'test': name, 'status': 'FAIL', 'detail': detail});
      stdout.writeln('FAIL: $name ($detail)');
      rethrow;
    }
  }

  final a = client();
  final b = client();
  final mobileA = service(a);
  final mobileB = service(b);
  try {
    await check('Swagger/OpenAPI profil ve Auth uçlarını sunuyor', () async {
      final r = await http.get<Map<String, dynamic>>('/openapi/v1.json');
      final paths = r.data?['paths'] as Map?;
      require(
          r.statusCode == 200 &&
              paths?.containsKey('/api/profil') == true &&
              paths?.containsKey('/api/auth/giris') == true,
          'Swagger sözleşmesi eksik');
    });
    await check('Girişsiz profil isteği 401', () async {
      require((await http.get('/api/profil')).statusCode == 401,
          'Anonim profil erişimi kabul edildi');
    });
    await check('Sahte erişim belirteci 401', () async {
      require(
          (await http.get('/api/profil',
                      options: Options(
                          headers: {'Authorization': 'Bearer forged-token'})))
                  .statusCode ==
              401,
          'Sahte token kabul edildi');
    });
    await check('Mobil SDK ile kayıt ve API profil oluşturma', () async {
      await mobileA.signUp('Mobil Test A', emailA, password);
      require(mobileA.hasSession,
          'E-posta onayı açık: yerel demo oturumu oluşmadı');
      final profile = await mobileA.loadProfile();
      require(
          profile.id == a.auth.currentUser!.id &&
              profile.adSoyad == 'Mobil Test A' &&
              profile.rol.apiValue == 'Ogrenci',
          'Mobil kayıt/profil eşleşmedi');
    });
    await check('Mobilde çıkış sonrası oturum temizleniyor', () async {
      await mobileA.signOut();
      require(!mobileA.hasSession && a.auth.currentUser == null,
          'SDK oturumu temizlenmedi');
    });
    await check('Yanlış parola gerçek Supabase tarafından reddediliyor',
        () async {
      var rejected = false;
      try {
        await mobileA.signIn(emailA, 'Wrong!password123');
      } on AuthException {
        rejected = true;
      }
      require(rejected && !mobileA.hasSession, 'Yanlış parola kabul edildi');
    });
    await check('Doğru parola ile mobil giriş', () async {
      await mobileA.signIn(emailA, password);
      require(
          mobileA.hasSession &&
              (await mobileA.loadProfile()).adSoyad == 'Mobil Test A',
          'Giriş/profil başarısız');
    });
    await check('Profil değişikliği yeni API isteğinde kalıcı', () async {
      final updated = await mobileA.saveProfile('Mobil Test A Güncel');
      final loaded = await mobileA.loadProfile();
      require(
          updated.adSoyad == 'Mobil Test A Güncel' &&
              loaded.adSoyad == updated.adSoyad,
          'Profil kalıcı değil');
    });
    await check('Geçersiz profil adı API tarafından 400 ile reddediliyor',
        () async {
      final r = await http.put('/api/profil',
          data: {'adSoyad': ' '},
          options: Options(headers: {
            'Authorization': 'Bearer ${a.auth.currentSession!.accessToken}'
          }));
      require(
          r.statusCode == 400 &&
              (await mobileA.loadProfile()).adSoyad == 'Mobil Test A Güncel',
          'Geçersiz ad kaydedildi');
    });
    await check('SDK refresh sonrası API güncel tokenla çalışıyor', () async {
      final old = a.auth.currentSession!.refreshToken;
      await a.auth.refreshSession();
      require(
          a.auth.currentSession!.refreshToken != old &&
              (await mobileA.loadProfile()).id == a.auth.currentUser!.id,
          'Yenilenmiş oturum API ile çalışmadı');
    });
    await check('Kaydedilmiş oturum yeni SDK istemcisinde geri yükleniyor',
        () async {
      final restored = client();
      await restored.auth
          .recoverSession(jsonEncode(a.auth.currentSession!.toJson()));
      require(
          (await service(restored).loadProfile()).id == a.auth.currentUser!.id,
          'Oturum geri yüklenemedi');
    });
    await check('Web Auth API aynı mobil hesabıyla giriş yapıyor', () async {
      final r = await http.post<Map<String, dynamic>>('/api/auth/giris',
          data: {'email': emailA, 'password': password});
      require(r.statusCode == 200 && r.data?['access_token'] is String,
          'Web giriş API başarısız');
      final webProfile = await http.get<Map<String, dynamic>>('/api/profil',
          options: Options(
              headers: {'Authorization': 'Bearer ${r.data!['access_token']}'}));
      require(
          webProfile.statusCode == 200 &&
              webProfile.data?['id'] == a.auth.currentUser!.id &&
              webProfile.data?['adSoyad'] == 'Mobil Test A Güncel',
          'Web ve mobil profil farklı');
    });
    await check('İkinci hesap farklı profil ve öğrenci rolü alıyor', () async {
      await mobileB.signUp('Mobil Test B', emailB, password);
      require(mobileB.hasSession, 'İkinci hesap oturumu oluşmadı');
      final p = await mobileB.loadProfile();
      require(
          p.id != a.auth.currentUser!.id &&
              p.adSoyad == 'Mobil Test B' &&
              p.rol.apiValue == 'Ogrenci',
          'Hesap ayrımı başarısız');
    });
    await check(
        'Başkasının ID’si ve yönetici rolü gönderilse de yalnızca kendi profilini düzenliyor',
        () async {
      final r = await http.put<Map<String, dynamic>>('/api/profil',
          data: {
            'id': a.auth.currentUser!.id,
            'adSoyad': 'Mobil Test B Güncel',
            'rol': 'Yonetici'
          },
          options: Options(headers: {
            'Authorization': 'Bearer ${b.auth.currentSession!.accessToken}'
          }));
      require(
          r.statusCode == 200 &&
              r.data?['id'] == b.auth.currentUser!.id &&
              r.data?['rol'] == 'Ogrenci' &&
              (await mobileA.loadProfile()).adSoyad == 'Mobil Test A Güncel',
          'Sahiplik veya rol güvenliği başarısız');
    });
    await check(
        'Webde yapılan profil değişikliği mobil SDK servisinde görünüyor',
        () async {
      await http.put('/api/profil',
          data: {'adSoyad': 'Mobil Web Ortak'},
          options: Options(headers: {
            'Authorization': 'Bearer ${b.auth.currentSession!.accessToken}'
          }));
      require((await mobileB.loadProfile()).adSoyad == 'Mobil Web Ortak',
          'Ortak veri tutarsız');
    });
    await check('Çıkıştan sonra refresh token yeniden kullanılamıyor',
        () async {
      final refreshToken = b.auth.currentSession!.refreshToken;
      await mobileB.signOut();
      final fresh = client();
      var rejected = false;
      try {
        await fresh.auth.refreshSession(refreshToken);
      } on AuthException {
        rejected = true;
      }
      require(
          rejected && !mobileB.hasSession, 'Çıkış refresh tokenı iptal etmedi');
    });
  } catch (_) {
    exitCode = 1;
  } finally {
    for (final c in clients) {
      await c.dispose();
    }
    http.close();
    await File(args[1])
        .writeAsString(const JsonEncoder.withIndent('  ').convert({
      'date': DateTime.now().toUtc().toIso8601String(),
      'scope': 'Gerçek mobil SupabaseAuthService + aynı ASP.NET Core web API',
      'results': results,
      'testAccountsCreated': a.auth.currentUser != null ? 2 : 1,
      'androidDeviceTest': 'NOT_RUN',
    }));
    stdout.writeln(
        'Sonuç: ${results.where((r) => r['status'] == 'PASS').length}/${results.length} geçti.');
  }
}

class _MemoryPkceStorage implements GotrueAsyncStorage {
  final _items = <String, String>{};
  @override
  Future<String?> getItem({required String key}) async => _items[key];
  @override
  Future<void> setItem({required String key, required String value}) async {
    _items[key] = value;
  }

  @override
  Future<void> removeItem({required String key}) async {
    _items.remove(key);
  }
}
