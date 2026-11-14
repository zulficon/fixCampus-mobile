import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:fixcampus_mobile/models/models.dart';
import 'package:fixcampus_mobile/providers/auth_provider.dart';
import 'package:fixcampus_mobile/providers/listings_provider.dart';
import 'package:fixcampus_mobile/screens/listings/listing_detail_screen.dart';
import 'package:fixcampus_mobile/services/local_profile_storage.dart';
import 'auth_provider_test.dart' show FakeAuthService;
import 'support/listings_fakes.dart';

void main() {
  setUpAll(() async => initializeDateFormatting('tr_TR', null));
  for (final expired in [true, false]) {
    testWidgets(
      'Detay katılımı ${expired ? 'geçmiş ilanda kapalı' : 'gelecek ilanda açık'}',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        LocalProfileStorage.resetMemoryForTest();
        final authService = FakeAuthService()..hasSession = true;
        final auth = AuthProvider(service: authService);
        await auth.initialize();
        final item = Ilan.fromJson({
          ...listingJson(),
          'bulusmaTarihi': DateTime.now()
              .toUtc()
              .add(Duration(days: expired ? -1 : 1))
              .toIso8601String(),
        });
        final service = FakeListingsService()..items = [item];
        final provider = ListingsProvider(service: service);
        addTearDown(() async {
          auth.dispose();
          provider.dispose();
          await authService.events.close();
        });
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: auth),
              ChangeNotifierProvider.value(value: provider),
            ],
            child: MaterialApp(home: ListingDetailScreen(ilan: item)),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.text('Bu buluşmanın süresi doldu. Katılım kapalı.'),
          expired ? findsOneWidget : findsNothing,
        );
        expect(
          find.textContaining('Buluşmaya Katıl'),
          expired ? findsNothing : findsOneWidget,
        );
        expect(find.text('İlanı Düzenle'), findsOneWidget);
      },
    );
  }
}
