import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixcampus_mobile/models/models.dart';
import 'package:fixcampus_mobile/security/listing_expiry_policy.dart';
import 'package:fixcampus_mobile/widgets/listing_expiry_boundary.dart';
import 'package:fixcampus_mobile/widgets/expiry_aware_listing_results.dart';
import 'package:fixcampus_mobile/providers/listings_provider.dart';
import 'package:fixcampus_mobile/services/listings_service.dart';
import 'support/listings_fakes.dart';

const policy = ListingExpiryPolicy();
final start = DateTime.utc(2030, 1, 1, 12);
Ilan social(DateTime? date, {String id = 'social'}) => Ilan.fromJson({
  ...listingJson(id: id),
  'bulusmaTarihi': date?.toIso8601String(),
});

class TimeService extends FakeListingsService {
  TimeService(this.now);
  final DateTime Function() now;
  int searches = 0;
  @override
  Future<ListingPage> searchListings(ListingQuery query) async {
    searches++;
    final visible = items.where((i) => !policy.isExpired(i, now())).toList();
    return ListingPage(
      items: visible,
      totalCount: visible.length,
      page: 1,
      pageSize: 12,
      totalPages: 1,
    );
  }
}

void main() {
  for (final offset in [-1, 0, 1]) {
    test('Süre sınırı $offset mikrosaniye', () {
      expect(
        policy.isExpired(
          social(start.add(Duration(microseconds: offset))),
          start,
        ),
        offset <= 0,
      );
    });
  }
  test('Saat dilimi aynı anı değiştirmez; tarihsiz sosyal ilan kapalıdır', () {
    expect(
      policy.isExpired(
        social(DateTime.parse('2030-01-01T15:00:00+03:00')),
        start,
      ),
      isTrue,
    );
    expect(policy.isExpired(social(null), start), isTrue);
  });
  test('Kayıp ve buluntu için süre uygulanmaz, kayıt durumu değiştirilmez', () {
    for (final type in ['Kayip', 'Buluntu']) {
      final item = Ilan.fromJson({
        ...listingJson(),
        'tur': type,
        'bulusmaTarihi': null,
      });
      expect(policy.isExpired(item, start), isFalse);
      expect(item.durum, IlanDurumu.aktif);
    }
  });
  testWidgets('Ekran açıkken tam sürede kapanır ve yalnız bir kez yenilenir', (
    tester,
  ) async {
    var now = start;
    var refreshes = 0;
    final item = social(start.add(const Duration(seconds: 5)));
    await tester.pumpWidget(
      MaterialApp(
        home: ListingExpiryBoundary(
          items: [item],
          clock: () => now,
          onExpiry: () async {
            refreshes++;
          },
          builder: (_, time) =>
              Text(policy.isExpired(item, time) ? 'Kapalı' : 'Açık'),
        ),
      ),
    );
    expect(find.text('Açık'), findsOneWidget);
    now = start.add(const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('Kapalı'), findsOneWidget);
    expect(refreshes, 1);
    await tester.pump(const Duration(minutes: 2));
    expect(refreshes, 1);
  });
  testWidgets('Uygulamaya dönüş saati ve süreyi yeniden kontrol eder', (
    tester,
  ) async {
    var now = start;
    final item = social(start.add(const Duration(hours: 1)));
    var refreshed = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: ListingExpiryBoundary(
          items: [item],
          clock: () => now,
          onExpiry: () async {
            refreshed++;
          },
          builder: (_, time) =>
              Text(policy.isExpired(item, time) ? 'Kapalı' : 'Açık'),
        ),
      ),
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    now = start.add(const Duration(hours: 2));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.text('Kapalı'), findsOneWidget);
    expect(refreshed, 1);
  });
  testWidgets('Sayfa kapanınca zamanlayıcı ve callback iptal edilir', (
    tester,
  ) async {
    var called = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: ListingExpiryBoundary(
          items: [social(start.add(const Duration(seconds: 1)))],
          clock: () => start,
          onExpiry: () async {
            called++;
          },
          builder: (_, time) => const Text('Sayfa'),
        ),
      ),
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(minutes: 2));
    expect(called, 0);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Buluşma tarihi değişince yeni süre sınırı kullanılır', (
    tester,
  ) async {
    var now = start;
    var calls = 0;
    Widget screen(int seconds) => MaterialApp(
      home: ListingExpiryBoundary(
        items: [social(start.add(Duration(seconds: seconds)))],
        clock: () => now,
        onExpiry: () async {
          calls++;
        },
        builder: (_, time) => const Text('Sayfa'),
      ),
    );
    await tester.pumpWidget(screen(5));
    await tester.pumpWidget(screen(10));
    now = start.add(const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 5));
    expect(calls, 0);
    now = start.add(const Duration(seconds: 10));
    await tester.pump(const Duration(seconds: 5));
    expect(calls, 1);
  });
  testWidgets('Süre dolunca ilan ve sunucu toplam sayısı birlikte yenilenir', (
    tester,
  ) async {
    var now = start;
    final service = TimeService(() => now)
      ..items = [social(start.add(const Duration(seconds: 2)))];
    final provider = ListingsProvider(service: service);
    addTearDown(provider.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ExpiryAwareListingResults(
          provider: provider,
          query: const ListingQuery(activeSocialOnly: true),
          clock: () => now,
          builder: (page, loading, error, refresh) => Column(
            children: [
              Text('Toplam ${page.totalItems}'),
              for (final i in page.items) Text(i.id),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('social'), findsOneWidget);
    expect(find.text('Toplam 1'), findsOneWidget);
    now = start.add(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('social'), findsNothing);
    expect(find.text('Toplam 0'), findsOneWidget);
    expect(service.searches, 2);
  });
}
