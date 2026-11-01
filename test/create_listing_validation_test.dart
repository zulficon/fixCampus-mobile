import 'package:fixcampus_mobile/models/models.dart';
import 'package:fixcampus_mobile/providers/auth_provider.dart';
import 'package:fixcampus_mobile/providers/listings_provider.dart';
import 'package:fixcampus_mobile/screens/listings/create_listing_screen.dart';
import 'package:fixcampus_mobile/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _Auth extends AuthProvider {
  _Auth({required this.verified});
  final bool verified;
  @override
  bool get isLoggedIn => verified;
  @override
  Profil? get currentUser => verified
      ? Profil(
          id: 'owner',
          adSoyad: 'Öğrenci',
          rol: KullaniciRolu.ogrenci,
          olusturulmaTarihi: DateTime.utc(2026),
        )
      : null;
}

void main() {
  Future<void> open(WidgetTester tester, {bool verified = false}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => _Auth(verified: verified),
          ),
          ChangeNotifierProvider(create: (_) => ListingsProvider()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CreateListingScreen(),
        ),
      ),
    );
  }

  Future<void> submit(WidgetTester tester) async {
    final button = find.text('İlanı Yayınla (İskelet)');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  Future<void> fill(WidgetTester tester) async {
    await tester.enterText(find.byType(TextFormField).at(0), 'Çalışma grubu');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Kütüphanede buluşuyoruz.',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'Kütüphane');
    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Spor').last);
    await tester.pumpAndSettle();
  }

  testWidgets('Boş ilan formu alan hatalarını gösterir, başarı mesajı vermez', (
    tester,
  ) async {
    await open(tester, verified: true);
    await submit(tester);
    expect(find.text('İlan başlığını girin.'), findsOneWidget);
    expect(find.text('İlan açıklamasını girin.'), findsOneWidget);
    expect(find.text('İlan yerini girin.'), findsOneWidget);
    expect(find.text('Kategori seçin.'), findsOneWidget);
    expect(
      find.text('İlan oluşturma özelliği yakında aktifleşecektir.'),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('Tür değişimi eski kategoriyi temizler ve yeni seçim ister', (
    tester,
  ) async {
    await open(tester, verified: true);
    await fill(tester);
    await tester.ensureVisible(find.text('Kayıp'));
    await tester.tap(find.text('Kayıp'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await submit(tester);
    expect(find.text('Kategori seçin.'), findsOneWidget);
  });
  testWidgets('Geçerli form doğrulanmamış oturumla gönderilemez', (
    tester,
  ) async {
    await open(tester);
    await fill(tester);
    await submit(tester);
    expect(
      find.text('İlan vermek için oturumunuzu doğrulayın.'),
      findsOneWidget,
    );
    expect(
      find.text('İlan oluşturma özelliği yakında aktifleşecektir.'),
      findsNothing,
    );
  });
  testWidgets('Geçerli form API bağlantısına ayrılan mevcut işleme ulaşır', (
    tester,
  ) async {
    await open(tester, verified: true);
    await fill(tester);
    await submit(tester);
    expect(
      find.text('İlan oluşturma özelliği yakında aktifleşecektir.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
