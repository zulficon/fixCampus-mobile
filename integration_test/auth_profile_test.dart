import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fixcampus_mobile/main.dart' as app;
import 'package:fixcampus_mobile/screens/auth/login_screen.dart';
import 'test_support.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Android: gerçek kayıt, giriş, profil, token, çıkış ve hesap ayrımı',
    (tester) async {
      expect(
        testEmailA,
        isNotEmpty,
        reason: 'Git dışındaki test yapılandırmasını kullanın.',
      );
      await app.main();
      await waitFor(tester, find.byType(LoginScreen));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Giriş Yap'));
      await tester.pumpAndSettle();
      expect(Supabase.instance.client.auth.currentSession == null, isTrue);
      expect(find.textContaining('Geçerli bir e-posta'), findsOneWidget);

      await register(tester, testNameA, testEmailA);
      final client = Supabase.instance.client;
      final firstUser = client.auth.currentUser!.id;
      await openProfile(tester);
      expect(find.text(testNameA), findsOneWidget);
      expect(find.text(testEmailA), findsOneWidget);

      await tester.tap(find.text('Profili düzenle'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), ' ');
      await tester.tap(find.text('Kaydet'));
      await tester.pumpAndSettle();
      expect(find.textContaining('2–100 karakter'), findsWidgets);
      expect(find.text(testNameA), findsOneWidget);

      await tester.tap(find.text('Profili düzenle'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), updatedName);
      await tester.tap(find.text('Kaydet'));
      await waitFor(tester, find.text(updatedName));
      final http = Dio(
        BaseOptions(baseUrl: const String.fromEnvironment('API_BASE_URL')),
      );
      final profile = await http.get<Map<String, dynamic>>(
        '/api/profil',
        options: Options(
          headers: {
            'Authorization':
                'Bearer ${client.auth.currentSession!.accessToken}',
          },
        ),
      );
      expect(profile.data!['adSoyad'], updatedName);
      expect(profile.data!['id'], firstUser);
      expect(profile.data!['rol'], 'Ogrenci');
      final webLogin = await http.post<Map<String, dynamic>>(
        '/api/auth/giris',
        data: {'email': testEmailA, 'password': testPassword},
      );
      final webProfile = await http.get<Map<String, dynamic>>(
        '/api/profil',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${webLogin.data!['access_token']}',
          },
        ),
      );
      expect(webProfile.data!['id'], firstUser);
      expect(webProfile.data!['adSoyad'], updatedName);

      final oldRefresh = client.auth.currentSession!.refreshToken;
      await client.auth.refreshSession();
      expect(client.auth.currentSession!.refreshToken != oldRefresh, isTrue);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Çıkış yap'));
      await waitFor(tester, find.byType(LoginScreen));
      expect(client.auth.currentSession == null, isTrue);
      await fillLogin(tester, testEmailA, 'Wrong!password123');
      await waitFor(tester, find.text('E-posta veya parola hatalı.'));
      expect(client.auth.currentSession == null, isTrue);
      await fillLogin(tester, testEmailA, testPassword);
      await waitFor(tester, find.byType(NavigationBar));
      await openProfile(tester);
      expect(find.text(updatedName), findsOneWidget);
      expect(client.auth.currentUser!.id, firstUser);

      await tester.tap(find.text('Çıkış yap'));
      await waitFor(tester, find.byType(LoginScreen));
      await register(tester, testNameB, testEmailB);
      await openProfile(tester);
      expect(client.auth.currentUser!.id, isNot(firstUser));
      expect(find.text(testNameB), findsOneWidget);
      expect(find.text(updatedName), findsNothing);
      await tester.tap(find.text('Çıkış yap'));
      await waitFor(tester, find.byType(LoginScreen));
      await fillLogin(tester, testEmailA, testPassword);
      await waitFor(tester, find.byType(NavigationBar));
      await openProfile(tester);
      expect(find.text(updatedName), findsOneWidget);
      http.close();
      // Sonraki APK çalıştırması aynı emülatörün gerçek kayıtlı oturumunu sınar.
      binding.reportData = {
        'phase': 'auth_profile',
        'result': 'PASS',
        'checks': [
          'register',
          'invalid_name',
          'profile_saved_in_api',
          'web_auth_same_android_account',
          'refresh',
          'logout',
          'wrong_password',
          'correct_login',
          'two_account_isolation',
        ],
      };
    },
  );
}
