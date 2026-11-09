import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixcampus_mobile/providers/listings_provider.dart';
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

void main() {
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
}
