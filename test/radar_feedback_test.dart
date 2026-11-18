import 'package:fixcampus_mobile/models/models.dart';
import 'package:fixcampus_mobile/providers/auth_provider.dart';
import 'package:fixcampus_mobile/providers/listings_provider.dart';
import 'package:fixcampus_mobile/screens/radar/radar_feed_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'support/listings_fakes.dart';

class _RadarAuth extends AuthProvider {
  @override
  Profil get currentUser => Profil(
    id: ownerId,
    adSoyad: 'Öğrenci',
    rol: KullaniciRolu.ogrenci,
    olusturulmaTarihi: DateTime.utc(2026),
  );
}

class _Launcher extends UrlLauncherPlatform {
  _Launcher(this.opens);
  final bool opens;
  final urls = <String>[];
  @override
  get linkDelegate => null;
  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    urls.add(url);
    return opens;
  }
}

void main() {
  for (final opens in [true, false]) {
    testWidgets('Harita paneli kapanır; açılma sonucu $opens görünür', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      final originalLauncher = UrlLauncherPlatform.instance;
      final launcher = _Launcher(opens);
      UrlLauncherPlatform.instance = launcher;
      addTearDown(() => UrlLauncherPlatform.instance = originalLauncher);
      final auth = _RadarAuth();
      final service = FakeListingsService();
      final provider = ListingsProvider(service: service);
      await provider.load();
      addTearDown(auth.dispose);
      addTearDown(provider.dispose);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: auth),
            ChangeNotifierProvider.value(value: provider),
          ],
          child: const MaterialApp(home: RadarFeedScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Haritada gör'));
      await tester.tap(find.text('Haritada gör'));
      await tester.pumpAndSettle();
      expect(find.text('Buluşma konumları'), findsOneWidget);
      await tester.tap(find.widgetWithText(ListTile, service.items.single.yer));
      await tester.pumpAndSettle();
      expect(find.text('Buluşma konumları'), findsNothing);
      expect(launcher.urls, hasLength(1));
      expect(
        Uri.parse(launcher.urls.single).queryParameters['query'],
        service.items.single.yer,
      );
      expect(
        find.text('Harita açılamadı.'),
        opens ? findsNothing : findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
