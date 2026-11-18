import 'package:flutter/material.dart';
import '../providers/listings_provider.dart';
import '../services/listings_service.dart';
import '../utils/listing_search_filter.dart';
import 'server_listing_results.dart';

/// API sayfalamasını korur; süre dolunca toplamlar da sunucudan yenilenir.
class ExpiryAwareListingResults extends StatelessWidget {
  const ExpiryAwareListingResults({
    super.key,
    required this.provider,
    required this.query,
    required this.builder,
    this.onPageCorrected,
    this.clock = DateTime.now,
  });
  final ListingsProvider provider;
  final ListingQuery query;
  final ValueChanged<int>? onPageCorrected;
  final DateTime Function() clock;
  final Widget Function(
    ListingPaginationResult,
    bool,
    String?,
    Future<void> Function(),
  )
  builder;
  @override
  Widget build(BuildContext context) => ServerListingResults(
    provider: provider,
    query: query,
    onPageCorrected: onPageCorrected,
    expiryClock: clock,
    builder: builder,
  );
}
