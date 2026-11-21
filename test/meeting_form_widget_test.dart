import 'package:fixcampus_mobile/models/models.dart';
import 'package:fixcampus_mobile/providers/auth_provider.dart';
import 'package:fixcampus_mobile/providers/listings_provider.dart';
import 'package:fixcampus_mobile/screens/listings/create_listing_screen.dart';
import 'package:fixcampus_mobile/services/local_profile_storage.dart';
import 'package:fixcampus_mobile/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_provider_test.dart' show FakeAuthService;
import 'support/listings_fakes.dart';

void main() {
  late FakeAuthService authService;
  late AuthProvider auth;
  late FakeListingsService service;
  late ListingsProvider listings;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    LocalProfileStorage.resetMemoryForTest();
    authService = FakeAuthService()..hasSession = true;
    auth = AuthProvider(service: authService);
    await auth.initialize();
    service = FakeListingsService();
    listings = ListingsProvider(service: service);
    await listings.load();
  });

  tearDown(() async {
    auth.dispose();
    listings.dispose();
    await authService.events.close();
  });

  Future<void> mountScreen(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
          ChangeNotifierProvider<ListingsProvider>.value(value: listings),
        ],
        child: MaterialApp(theme: AppTheme.lightTheme, home: screen),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> fillBasicSocialFields(WidgetTester tester) async {
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Algoritma Çalışma Buluşması',
    );
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'Vize öncesi soru çözümü yapacağız.',
    );

    final categoryDropdown = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(categoryDropdown);
    await tester.tap(categoryDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Spor').last);
    await tester.pumpAndSettle();

    final campusChip = find.text('Merkez Kütüphane');
    await tester.ensureVisible(campusChip);
    await tester.tap(campusChip);
    await tester.pumpAndSettle();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  testWidgets(
    'Kampüs yer çipi, ayrı tarih/saat seçici düğmeleri ve hızlı zaman çipi ile sosyal ilan yayınlanır',
    (tester) async {
      final fixedNow = DateTime(2030, 11, 4, 14, 0);
      await mountScreen(
        tester,
        CreateListingScreen(nowProvider: () => fixedNow),
      );

      await fillBasicSocialFields(tester);

      // Ayrı Tarih Seç ve Saat Seç düğmeleri görünür
      expect(find.byKey(const ValueKey('meeting_date_button')), findsOneWidget);
      expect(find.byKey(const ValueKey('meeting_time_button')), findsOneWidget);
      expect(find.text('Buluşma tarihi ve saati seçin'), findsOneWidget);

      // Hızlı zaman çipi ile gelecekteki buluşma saatini seç
      final timePreset = find.text('Yarın 15:00');
      await tester.ensureVisible(timePreset);
      await tester.tap(timePreset);
      await tester.pumpAndSettle();

      expect(find.text('Buluşma tarihi ve saati seçin'), findsNothing);
      expect(find.text('Zamanı Sıfırla'), findsOneWidget);
      expect(find.text('05.11.2030'), findsOneWidget);
      expect(find.text('15:00'), findsOneWidget);

      // İlanı yayınla
      final publishButton = find.widgetWithText(ElevatedButton, 'İlanı Yayınla');
      await tester.ensureVisible(publishButton);
      await tester.tap(publishButton);
      await tester.pumpAndSettle();

      expect(service.creates, 1);
      expect(service.savedRequest!.tur, IlanTuru.sosyal);
      expect(service.savedRequest!.yer, 'Merkez Kütüphane');
      expect(service.savedRequest!.bulusmaTarihi, DateTime(2030, 11, 5, 15, 0));
      expect(find.text('İlan yayınlandı.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Geçerli buluşma zamanı seçildiğinde önceki kırmızı tarih uyarısı anında temizlenir',
    (tester) async {
      final fixedNow = DateTime(2030, 11, 4, 22, 30);
      await mountScreen(
        tester,
        CreateListingScreen(nowProvider: () => fixedNow),
      );

      await fillBasicSocialFields(tester);

      // Tarih seçmeden göndermeyi dene -> kırmızı tarih uyarısı çıkar
      final publishButton = find.widgetWithText(ElevatedButton, 'İlanı Yayınla');
      await tester.ensureVisible(publishButton);
      await tester.tap(publishButton);
      await tester.pumpAndSettle();

      expect(
        find.text('Sosyal ilan için gelecekte bir buluşma zamanı seçin.'),
        findsOneWidget,
      );
      expect(service.creates, 0);

      // Geçerli gelecek bir zaman çipine dokununca kırmızı uyarı anında kalkmalı
      final preset = find.text('+2 Saat Sonra');
      await tester.ensureVisible(preset);
      await tester.tap(preset);
      await tester.pumpAndSettle();

      expect(
        find.text('Sosyal ilan için gelecekte bir buluşma zamanı seçin.'),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Düzenleme modunda mevcut yer çipi ve ayrılmış tarih/saat alanları doldurulur',
    (tester) async {
      final existing = Ilan.fromJson({
        ...listingJson(),
        'yer': 'Merkez Kütüphane',
        'bulusmaTarihi': '2030-11-06T12:30:00Z',
      });
      final localMeeting = existing.bulusmaTarihi!.toLocal();

      await mountScreen(tester, CreateListingScreen(ilan: existing));

      expect(find.text('Yeri Temizle'), findsOneWidget);
      expect(find.text('Zamanı Sıfırla'), findsOneWidget);
      expect(
        find.text(DateFormat('dd.MM.yyyy').format(localMeeting)),
        findsOneWidget,
      );
      expect(
        find.text(DateFormat('HH:mm').format(localMeeting)),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
