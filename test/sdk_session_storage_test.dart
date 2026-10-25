import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Gerçek SDK oturumu saklar, yeniden başlatmada yükler ve çıkışta siler',
      () async {
    SharedPreferences.setMockInitialValues({});
    const storageKey = 'sdk-test-auth-token';
    const userId = '00000000-0000-4000-8000-000000000010';
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    String encode(Map<String, dynamic> value) =>
        base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
    final token = '${encode({'alg': 'HS256', 'typ': 'JWT'})}.${encode({
          'sub': userId,
          'exp': now + 3600,
          'iat': now
        })}.test-signature';
    Future<void> initialize() async {
      await Supabase.initialize(
        url: 'https://sdk-test.supabase.co',
        publishableKey: 'test-public-key',
        debug: false,
        httpClient: MockClient((request) async {
          if (request.url.path.endsWith('/logout')) {
            return http.Response('', 204);
          }
          return http.Response(
              jsonEncode({
                'access_token': token,
                'refresh_token': 'test-refresh-token',
                'token_type': 'bearer',
                'expires_in': 3600,
                'expires_at': now + 3600,
                'user': {
                  'id': userId,
                  'aud': 'authenticated',
                  'email': 'sdk@example.com',
                  'app_metadata': {},
                  'user_metadata': {'ad_soyad': 'SDK Test'},
                  'created_at': DateTime.now().toUtc().toIso8601String()
                },
              }),
              200,
              headers: {'content-type': 'application/json'});
        }),
        authOptions: FlutterAuthClientOptions(
            autoRefreshToken: false,
            detectSessionInUri: false,
            localStorage:
                SharedPreferencesLocalStorage(persistSessionKey: storageKey)),
      );
      // Uygulamanın ilk karesi öncesindeki asenkron SDK kurtarmasının bitmesini bekle.
      await Future<void>.delayed(Duration.zero);
    }

    await initialize();
    await Supabase.instance.client.auth.signInWithPassword(
        email: 'sdk@example.com', password: 'test-password');
    await Future<void>.delayed(Duration.zero);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.containsKey(storageKey), true);
    await Supabase.instance.dispose();
    await initialize();
    expect(Supabase.instance.client.auth.currentUser?.id, userId);
    expect(Supabase.instance.client.auth.currentSession, isNotNull);
    await Supabase.instance.client.auth.signOut(scope: SignOutScope.local);
    await Future<void>.delayed(Duration.zero);
    expect(Supabase.instance.client.auth.currentSession, null);
    expect(preferences.containsKey(storageKey), false);
    await Supabase.instance.dispose();
  });
}
