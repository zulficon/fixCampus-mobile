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
    'Android: süreç yeniden açılınca gerçek kayıtlı oturum geri geliyor',
    (tester) async {
      await app.main();
      await waitFor(tester, find.byType(NavigationBar));
      expect(Supabase.instance.client.auth.currentUser!.email, testEmailA);
      await openProfile(tester);
      expect(find.text(updatedName), findsOneWidget);
      await tester.tap(find.text('Çıkış yap'));
      await waitFor(tester, find.byType(LoginScreen));
      expect(Supabase.instance.client.auth.currentSession == null, isTrue);
      binding.reportData = {'phase': 'session_restart', 'result': 'PASS'};
    },
  );
}
