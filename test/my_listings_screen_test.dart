import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:fixcampus_mobile/models/models.dart';
import 'package:fixcampus_mobile/providers/auth_provider.dart';
import 'package:fixcampus_mobile/providers/listings_provider.dart';
import 'package:fixcampus_mobile/routes/app_routes.dart';
import 'package:fixcampus_mobile/screens/listings/my_listings_screen.dart';
import 'package:fixcampus_mobile/screens/shell/main_shell_screen.dart';
import 'package:fixcampus_mobile/services/api_exception.dart';
import 'package:fixcampus_mobile/services/listings_service.dart';
import 'package:fixcampus_mobile/services/local_profile_storage.dart';
import 'package:fixcampus_mobile/theme/app_theme.dart';
import 'package:fixcampus_mobile/widgets/listing_card.dart';
import 'auth_provider_test.dart' show FakeAuthService;
import 'support/listings_fakes.dart';

void main() {
  late FakeAuthService authService;
  late AuthProvider auth;
  late FakeListingsService service;
  late ListingsProvider listings;
  RouteSettings? opened;
  setUpAll(() async => initializeDateFormatting('tr_TR', null));
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    LocalProfileStorage.resetMemoryForTest();
    authService = FakeAuthService()..hasSession = true;
    auth = AuthProvider(service: authService);
    await auth.initialize();
    service = FakeListingsService();
    listings = ListingsProvider(service: service);
    opened = null;
  });
  tearDown(() async {
    auth.dispose();
    listings.dispose();
    await authService.events.close();
  });
  Future<void> mount(WidgetTester tester, {bool settle = true}) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider.value(value: listings),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const MyListingsScreen(),
          onGenerateRoute: (settings) {
            opened = settings;
            return MaterialPageRoute<void>(
              builder: (_) => const Scaffold(body: Text('Hedef ekran')),
            );
          },
        ),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  List<ListingCard> cards(WidgetTester tester) =>
      tester.widgetList<ListingCard>(find.byType(ListingCard)).toList();

  testWidgets(
    'Yalnız kendi ilanları tüm durumlarıyla yeniden eskiye sıralanır',
    (tester) async {
      service.items = [
        Ilan.fromJson({
          ...listingJson(id: 'old'),
          'durum': 'Cozuldu',
          'olusturulmaTarihi': '2026-11-01T10:00:00Z',
        }),
        Ilan.fromJson({...listingJson(id: 'other'), 'sahipId': 'other'}),
        Ilan.fromJson({...listingJson(id: 'new'), 'durum': 'Gizli'}),
      ];
      await mount(tester);
      expect(cards(tester).map((c) => c.ilan.id), ['new', 'old']);
      expect(find.text('2 ilan'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Yönetici de yalnız kendi ilanlarını görür', (tester) async {
    authService.role = KullaniciRolu.yonetici;
    await auth.initialize();
    service.items.add(
      Ilan.fromJson({...listingJson(id: 'other'), 'sahipId': 'other'}),
    );
    await mount(tester);
    expect(cards(tester), hasLength(1));
    expect(cards(tester).single.ilan.sahipId, ownerId);
  });
  testWidgets('İlk yükleme sırasında boş liste mesajı gösterilmez', (
    tester,
  ) async {
    service.pendingList = Completer<List<Ilan>>();
    final pending = service.pendingList!;
    await mount(tester, settle: false);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('Henüz ilanınız yok'), findsNothing);
    pending.complete([]);
    await tester.pumpAndSettle();
    expect(find.text('Henüz ilanınız yok'), findsOneWidget);
  });
  testWidgets('Boş durumdan ilan oluşturma rotasına gidilir', (tester) async {
    service.items = [];
    await mount(tester);
    await tester.tap(find.text('İlan oluştur'));
    await tester.pumpAndSettle();
    expect(opened!.name, AppRoutes.createListing);
  });
  testWidgets('Kart mevcut detay rotasına ilanı aktarır', (tester) async {
    await mount(tester);
    await tester.tap(find.byType(ListingCard));
    await tester.pumpAndSettle();
    expect(opened!.name, AppRoutes.listingDetail);
    expect((opened!.arguments as Ilan).id, listingId);
  });
  testWidgets(
    'İlk istek hatası boş ilan sonucu gibi gösterilmez ve tekrar denenir',
    (tester) async {
      service.error = const ListingApiException(
        ApiFailure.connection,
        'API kapalı',
      );
      await mount(tester);
      expect(find.text('API kapalı'), findsOneWidget);
      expect(find.text('Henüz ilanınız yok'), findsNothing);
      service.error = null;
      await tester.tap(find.text('Tekrar dene'));
      await tester.pumpAndSettle();
      expect(cards(tester), hasLength(1));
      expect(find.text('API kapalı'), findsNothing);
    },
  );
  testWidgets('Yenileme hatasında önceki ilan ve hata birlikte gösterilir', (
    tester,
  ) async {
    await mount(tester);
    service.error = const ListingApiException(
      ApiFailure.connection,
      'API kapalı',
    );
    await tester.tap(find.byTooltip('İlanlarımı yenile'));
    await tester.pumpAndSettle();
    expect(cards(tester), hasLength(1));
    expect(find.text('API kapalı'), findsOneWidget);
  });
  testWidgets('Boş yenileme eski ilanı temizler', (tester) async {
    await mount(tester);
    service.items = [];
    await tester.drag(find.byType(ListView), const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(cards(tester), isEmpty);
    expect(find.text('Henüz ilanınız yok'), findsOneWidget);
  });
  testWidgets('Başarılı düzenleme ve silme listeye yansır', (tester) async {
    await mount(tester);
    await listings.updateListing(listingId, request(title: 'Yeni başlık'));
    await tester.pumpAndSettle();
    expect(find.text('Yeni başlık'), findsOneWidget);
    await listings.deleteListing(listingId);
    await tester.pumpAndSettle();
    expect(cards(tester), isEmpty);
    expect(find.text('Henüz ilanınız yok'), findsOneWidget);
  });
  testWidgets('Hesap değişince önceki hesabın kartları gösterilmez', (
    tester,
  ) async {
    await mount(tester);
    authService.userId = 'other';
    await auth.initialize();
    await tester.pumpAndSettle();
    expect(cards(tester), isEmpty);
  });
  testWidgets('Profil doğrulanamadığında korunan ilanlar kapatılır', (
    tester,
  ) async {
    await mount(tester);
    authService.profileFails = true;
    await auth.initialize();
    await tester.pumpAndSettle();
    expect(cards(tester), isEmpty);
  });

  testWidgets('Üst menü gerçek İlanlarım rotasını açar', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await listings.load();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider.value(value: listings),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const MainShellScreen(),
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('İlanlarım'));
    await tester.pumpAndSettle();
    expect(find.byType(MyListingsScreen), findsOneWidget);
    expect(find.text('1 ilan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
