import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fixcampus_mobile/main.dart' as app;
import 'package:fixcampus_mobile/screens/auth/login_screen.dart';
import 'test_support.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Android: çıkış sonrası yeniden başlatma girişsiz kalıyor', (
    tester,
  ) async {
    await app.main();
    await waitFor(tester, find.byType(LoginScreen));
    expect(Supabase.instance.client.auth.currentSession == null, isTrue);
    binding.reportData = {'phase': 'logout_restart', 'result': 'PASS'};
  });
}
