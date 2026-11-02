import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fixcampus_mobile/models/models.dart';
import 'package:fixcampus_mobile/providers/auth_provider.dart';
import 'package:fixcampus_mobile/providers/listings_provider.dart';
import 'package:fixcampus_mobile/screens/listings/create_listing_screen.dart';
import 'package:fixcampus_mobile/screens/listings/edit_listing_screen.dart';
import 'package:fixcampus_mobile/screens/listings/listing_detail_screen.dart';
import 'package:fixcampus_mobile/services/local_profile_storage.dart';
import 'auth_provider_test.dart' show FakeAuthService;

void main() {
  final now = DateTime.utc(2026, 11, 2, 12, 0);

  final testIlan = Ilan(
    id: 'ilan-test-1',
    sahipId: '00000000-0000-0000-0000-000000000001',
    kategoriId: 'kat-1',
    baslik: 'Test Voleybol İlanı',
    aciklama: 'Test amaçlı açıklama içeriği...',
    tur: IlanTuru.sosyal,
    yer: 'Spor Tesisleri',
    bulusmaTarihi: now.add(const Duration(days: 2)),
    durum: IlanDurumu.aktif,
    olusturulmaTarihi: now,
  );

  late FakeAuthService service;
  late AuthProvider auth;
  late ListingsProvider listingsProvider;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    LocalProfileStorage.resetMemoryForTest();
    service = FakeAuthService();
    auth = AuthProvider(service: service);
    listingsProvider = ListingsProvider();
  });

  tearDown(() async {
    auth.dispose();
    await service.events.close();
  });

  Future<void> mountWidget(WidgetTester tester, Widget child) async {
    await tester.binding.setSurfaceSize(const Size(412, 870));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
          ChangeNotifierProvider<ListingsProvider>.value(value: listingsProvider),
        ],
        child: MaterialApp(
          home: child,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('3. Hafta İlan Ekranları Widget Testleri', () {
    testWidgets('CreateListingScreen boş form gönderildiğinde validasyon hataları gösterir', (tester) async {
      await mountWidget(tester, const CreateListingScreen());

      expect(find.text('Yeni İlan Oluştur'), findsOneWidget);
      expect(find.byKey(const Key('create_listing_submit_button')), findsOneWidget);

      // Boş formda gönder butonuna tıkla
      await tester.tap(find.byKey(const Key('create_listing_submit_button')));
      await tester.pumpAndSettle();

      // Validasyon uyarıları görüntülenmeli
      expect(find.text('İlan başlığı zorunludur.'), findsOneWidget);
      expect(find.text('Konum veya yer bilgisi zorunludur.'), findsOneWidget);
      expect(find.text('İlan açıklaması zorunludur.'), findsOneWidget);
    });

    testWidgets('CreateListingScreen tür değiştirildiğinde tarih seçici görünürlüğü değişir', (tester) async {
      await mountWidget(tester, const CreateListingScreen());

      // Başlangıçta Sosyal türü seçilidir, tarih seçici vardır
      expect(find.byKey(const Key('create_listing_date_picker')), findsOneWidget);

      // 'Kayıp' türüne geç
      await tester.tap(find.text('Kayıp'));
      await tester.pumpAndSettle();

      // Kayıp türünde tarih seçici gizlenmelidir
      expect(find.byKey(const Key('create_listing_date_picker')), findsNothing);
    });

    testWidgets('ListingDetailScreen: İlan sahibi girdiğinde düzenle ve sil butonları görünür', (tester) async {
      service.hasSession = true;
      service.userId = '00000000-0000-0000-0000-000000000001';
      service.role = KullaniciRolu.ogrenci;
      await auth.initialize();

      await mountWidget(tester, ListingDetailScreen(ilan: testIlan));

      expect(find.text('Test Voleybol İlanı'), findsOneWidget);
      expect(find.byKey(const Key('detail_edit_button')), findsOneWidget);
      expect(find.byKey(const Key('detail_delete_button')), findsOneWidget);
      expect(find.byKey(const Key('detail_action_edit')), findsOneWidget);
      expect(find.byKey(const Key('detail_action_delete')), findsOneWidget);
    });

    testWidgets('ListingDetailScreen: Başka bir öğrenci girdiğinde düzenle ve sil butonları gizlenir', (tester) async {
      service.hasSession = true;
      service.userId = 'baska-ogrenci-uuid';
      service.role = KullaniciRolu.ogrenci;
      await auth.initialize();

      await mountWidget(tester, ListingDetailScreen(ilan: testIlan));

      expect(find.text('Test Voleybol İlanı'), findsOneWidget);
      expect(find.byKey(const Key('detail_edit_button')), findsNothing);
      expect(find.byKey(const Key('detail_delete_button')), findsNothing);
      expect(find.byKey(const Key('detail_action_edit')), findsNothing);
      expect(find.byKey(const Key('detail_action_delete')), findsNothing);
    });

    testWidgets('ListingDetailScreen: Yönetici girdiğinde ilanın sahibi olmasa bile düzenle/sil butonları görünür', (tester) async {
      service.hasSession = true;
      service.userId = 'admin-kullanici-uuid';
      service.role = KullaniciRolu.yonetici;
      await auth.initialize();

      await mountWidget(tester, ListingDetailScreen(ilan: testIlan));

      expect(find.byKey(const Key('detail_edit_button')), findsOneWidget);
      expect(find.byKey(const Key('detail_delete_button')), findsOneWidget);
      expect(find.text('Yönetici İlan Denetimi'), findsOneWidget);
    });

    testWidgets('ListingDetailScreen: Sil butonuna basıldığında onay diyalogu açılır', (tester) async {
      service.hasSession = true;
      service.userId = '00000000-0000-0000-0000-000000000001';
      service.role = KullaniciRolu.ogrenci;
      await auth.initialize();

      await mountWidget(tester, ListingDetailScreen(ilan: testIlan));

      await tester.tap(find.byKey(const Key('detail_delete_button')));
      await tester.pumpAndSettle();

      expect(find.text('İlanı Sil'), findsOneWidget);
      expect(find.text('Bu ilanı silmek istediğinize emin misiniz? Bu işlem geri alınamaz.'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'İptal'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Sil'), findsOneWidget);
    });

    testWidgets('EditListingScreen: İlan sahibi alanları dolu görür', (tester) async {
      service.hasSession = true;
      service.userId = '00000000-0000-0000-0000-000000000001';
      service.role = KullaniciRolu.ogrenci;
      await auth.initialize();

      await mountWidget(tester, EditListingScreen(ilan: testIlan));

      expect(find.text('İlanı Düzenle'), findsOneWidget);
      expect(find.text('Test Voleybol İlanı'), findsOneWidget);
      expect(find.text('Spor Tesisleri'), findsOneWidget);
      expect(find.text('Test amaçlı açıklama içeriği...'), findsOneWidget);
    });

    testWidgets('EditListingScreen: Yetkisiz kullanıcı açmaya çalıştığında yetkisiz erişim uyarısı verir', (tester) async {
      service.hasSession = true;
      service.userId = 'yetkisiz-kullanici-uuid';
      service.role = KullaniciRolu.ogrenci;
      await auth.initialize();

      await mountWidget(tester, EditListingScreen(ilan: testIlan));

      expect(find.text('Yetkisiz Erişim'), findsOneWidget);
      expect(find.text('Bu ilanı düzenleme yetkiniz bulunmuyor.'), findsOneWidget);
    });
  });
}
