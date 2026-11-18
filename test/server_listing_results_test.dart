import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixcampus_mobile/providers/listings_provider.dart';
import 'package:fixcampus_mobile/models/models.dart';
import 'package:fixcampus_mobile/services/api_exception.dart';
import 'package:fixcampus_mobile/services/listings_service.dart';
import 'package:fixcampus_mobile/widgets/server_listing_results.dart';
import 'support/listings_fakes.dart';

class DeferredSearch extends FakeListingsService {
  final pending = <String, Completer<ListingPage>>{};
  @override
  Future<ListingPage> searchListings(ListingQuery query) =>
      (pending[query.text ?? ''] = Completer<ListingPage>()).future;
}

class ScriptedSearch extends FakeListingsService {
  ScriptedSearch(this.responses);
  final List<ListingPage> responses;
  final requests = <ListingQuery>[];

  @override
  Future<ListingPage> searchListings(ListingQuery query) async {
    requests.add(query);
    return responses.removeAt(0);
  }
}

void main() {
  ListingPage result({
    required int page,
    required int total,
    int size = 6,
    int count = 0,
  }) => ListingPage(
    items: List.generate(
      count,
      (index) => Ilan.fromJson(listingJson(id: 'row-$index')),
    ),
    totalCount: total,
    page: page,
    pageSize: size,
    totalPages: total == 0 ? 1 : (total + size - 1) ~/ size,
  );

  testWidgets(
    'Silinen son sayfa duzeltilir; yenileme ve tekrar sayfa secimi calisir',
    (tester) async {
      final service = ScriptedSearch([
        result(page: 2, total: 6),
        result(page: 1, total: 6, count: 6),
        result(page: 1, total: 6, count: 6),
        result(page: 2, total: 7, count: 1),
      ]);
      final provider = ListingsProvider(service: service);
      addTearDown(provider.dispose);
      var selectedPage = 2;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, changePage) => ServerListingResults(
              provider: provider,
              query: ListingQuery(
                page: selectedPage,
                pageSize: 6,
                text: 'kulaklık',
                tur: IlanTuru.kayip,
                kategoriId: 'category',
                lostFoundOnly: true,
              ),
              onPageCorrected: (page) => changePage(() {
                selectedPage = page;
              }),
              builder: (page, loading, error, refresh) => Column(
                children: [
                  Text(
                    loading
                        ? 'Yukleniyor'
                        : error ??
                              '${page.currentPage}:${page.items.length}:${page.totalItems}',
                  ),
                  TextButton(onPressed: refresh, child: const Text('Yenile')),
                  TextButton(
                    onPressed: () => changePage(() {
                      selectedPage = 2;
                    }),
                    child: const Text('Sayfa 2'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('1:6:6'), findsOneWidget);
      expect(selectedPage, 1);
      expect(service.requests.map((q) => q.page), [2, 1]);
      expect(service.requests.last.toQueryParameters(), {
        'tur': 'Kayip',
        'kategoriId': 'category',
        'q': 'kulaklık',
        'kayipBuluntu': true,
        'sayfa': 1,
        'sayfaBoyutu': 6,
      });
      await tester.tap(find.text('Yenile'));
      await tester.pumpAndSettle();
      expect(service.requests.map((q) => q.page), [2, 1, 1]);
      await tester.tap(find.text('Sayfa 2'));
      await tester.pumpAndSettle();
      expect(find.text('2:1:7'), findsOneWidget);
    },
  );

  testWidgets('Gercek bos listede yeniden sorgu dongusu baslamaz', (
    tester,
  ) async {
    final service = ScriptedSearch([result(page: 2, total: 0)]);
    final provider = ListingsProvider(service: service);
    addTearDown(provider.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ServerListingResults(
          provider: provider,
          query: const ListingQuery(page: 2, pageSize: 6),
          builder: (page, loading, error, refresh) =>
              Text(loading ? 'Yukleniyor' : '${page.totalItems} sonuc'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('0 sonuc'), findsOneWidget);
    expect(service.requests, hasLength(1));
  });

  testWidgets('Duzeltme sirasinda tekrar silinirse son gecerli sayfaya iner', (
    tester,
  ) async {
    final service = ScriptedSearch([
      result(page: 3, total: 4, size: 2),
      result(page: 2, total: 1, size: 2),
      result(page: 1, total: 1, size: 2, count: 1),
    ]);
    final provider = ListingsProvider(service: service);
    addTearDown(provider.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ServerListingResults(
          provider: provider,
          query: const ListingQuery(page: 3, pageSize: 2),
          builder: (page, loading, error, refresh) => Text(
            loading ? 'Yukleniyor' : '${page.currentPage}:${page.items.length}',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(service.requests.map((q) => q.page), [3, 2, 1]);
    expect(find.text('1:1'), findsOneWidget);
  });

  testWidgets('Eski aramanin sayfa duzeltmesi yeni aramayi ezmez', (
    tester,
  ) async {
    final service = DeferredSearch();
    final provider = ListingsProvider(service: service);
    addTearDown(provider.dispose);
    Future<void> mount(String text) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ServerListingResults(
            provider: provider,
            query: ListingQuery(text: text, page: 2, pageSize: 6),
            builder: (page, loading, error, refresh) => Text(
              loading ? 'Yukleniyor' : '${page.currentPage}:${page.totalItems}',
            ),
          ),
        ),
      );
      await tester.pump();
    }

    await mount('eski');
    service.pending['eski']!.complete(result(page: 2, total: 6));
    await tester.pump();
    final oldRecovery = service.pending['eski']!;
    await mount('yeni');
    service.pending['yeni']!.complete(result(page: 2, total: 7, count: 1));
    await tester.pumpAndSettle();
    expect(find.text('2:7'), findsOneWidget);
    oldRecovery.complete(result(page: 1, total: 6, count: 6));
    await tester.pumpAndSettle();
    expect(find.text('2:7'), findsOneWidget);
  });

  ListingPage page(int total) => ListingPage(
    items: const [],
    totalCount: total,
    page: 1,
    pageSize: 12,
    totalPages: total == 0 ? 1 : (total + 11) ~/ 12,
  );

  testWidgets('Eski arama yaniti yeni filtre sonucunu ezmez', (tester) async {
    final service = DeferredSearch();
    final provider = ListingsProvider(service: service);
    addTearDown(provider.dispose);
    Future<void> mount(String text) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ServerListingResults(
            provider: provider,
            query: ListingQuery(text: text),
            builder: (page, loading, error, refresh) => Text(
              loading ? 'Yukleniyor' : error ?? '${page.totalItems} sonuc',
            ),
          ),
        ),
      );
      await tester.pump();
    }

    await mount('eski');
    await mount('yeni');
    service.pending['yeni']!.complete(page(3));
    await tester.pumpAndSettle();
    expect(find.text('3 sonuc'), findsOneWidget);
    service.pending['eski']!.complete(page(9));
    await tester.pumpAndSettle();
    expect(find.text('3 sonuc'), findsOneWidget);
    expect(find.text('9 sonuc'), findsNothing);
  });

  testWidgets('Ag hatasi bos sonuc olarak sunulmaz', (tester) async {
    final service = DeferredSearch();
    final provider = ListingsProvider(service: service);
    addTearDown(provider.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ServerListingResults(
          provider: provider,
          query: const ListingQuery(),
          builder: (page, loading, error, refresh) => Text(
            loading ? 'Yukleniyor' : error ?? '${page.totalItems} sonuc',
          ),
        ),
      ),
    );
    await tester.pump();
    service.pending['']!.completeError(
      const ApiException(ApiFailure.connection, 'Baglanti yok'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Baglanti yok'), findsOneWidget);
    expect(find.text('0 sonuc'), findsNothing);
  });
  testWidgets('İlk yükleme biterken sayfalı sorgu yalnızca bir kez yapılır', (
    tester,
  ) async {
    final service = FakeListingsService()
      ..pendingList = Completer<List<Ilan>>();
    final provider = ListingsProvider(service: service)..setSession(ownerId);
    addTearDown(provider.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ServerListingResults(
          provider: provider,
          query: const ListingQuery(),
          builder: (page, loading, error, refresh) =>
              Text(loading ? 'Bekleniyor' : '${page.items.length} kayıt'),
        ),
      ),
    );
    await tester.pump();
    expect(service.queries, isEmpty);
    service.pendingList!.complete(service.items);
    await tester.pumpAndSettle();
    expect(service.queries, hasLength(1));
    expect(find.text('1 kayıt'), findsOneWidget);
  });

  testWidgets('Katıl ve geri al sayfayı boşaltmaz veya yeniden sorgulamaz', (
    tester,
  ) async {
    final service = FakeListingsService();
    final provider = ListingsProvider(service: service);
    addTearDown(provider.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ServerListingResults(
          provider: provider,
          query: const ListingQuery(),
          builder: (page, loading, error, refresh) => Column(
            children: [
              for (final listing in page.items)
                Text(
                  '${listing.id}:${listing.katilimciSayisi}:${listing.katiliyor}',
                ),
              TextButton(onPressed: refresh, child: const Text('Yenile')),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final attending in [true, false]) {
      await provider.setParticipation(listingId, attending: attending);
      await tester.pumpAndSettle();
      expect(
        find.text('$listingId:${attending ? 1 : 0}:$attending'),
        findsOneWidget,
      );
      expect(service.queries, hasLength(1));
    }
    await tester.tap(find.text('Yenile'));
    await tester.pumpAndSettle();
    expect(service.queries, hasLength(2));
  });

  testWidgets('Arka plan yenilemesi başarısızsa görünen kart korunur', (
    tester,
  ) async {
    final service = FakeListingsService();
    final provider = ListingsProvider(service: service);
    addTearDown(provider.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ServerListingResults(
          provider: provider,
          query: const ListingQuery(),
          builder: (page, loading, error, refresh) => Column(
            children: [
              for (final listing in page.items) Text(listing.baslik),
              if (error != null) Text(error),
              TextButton(onPressed: refresh, child: const Text('Yenile')),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    service.error = const ApiException(ApiFailure.connection, 'Çevrimdışı');
    await tester.tap(find.text('Yenile'));
    await tester.pumpAndSettle();
    expect(find.text('API ilanı'), findsOneWidget);
    expect(find.text('Çevrimdışı'), findsOneWidget);
  });
}
