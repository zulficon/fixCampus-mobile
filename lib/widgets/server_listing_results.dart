import 'dart:convert';

import 'package:flutter/material.dart';
import '../providers/listings_provider.dart';
import '../services/api_exception.dart';
import '../services/listings_service.dart';
import '../utils/listing_search_filter.dart';
import 'listing_expiry_boundary.dart';

/// Her ekran kendi sorgusunu tutar; eski filtre/hesap yanıtı yeni sonucu ezemez.
class ServerListingResults extends StatefulWidget {
  const ServerListingResults({
    super.key,
    required this.provider,
    required this.query,
    required this.builder,
    this.onPageCorrected,
    this.expiryClock,
  });

  final ListingsProvider provider;
  final ListingQuery query;
  final ValueChanged<int>? onPageCorrected;
  final DateTime Function()? expiryClock;
  final Widget Function(
    ListingPaginationResult page,
    bool loading,
    String? error,
    Future<void> Function() refresh,
  )
  builder;

  @override
  State<ServerListingResults> createState() => _ServerListingResultsState();
}

class _ServerListingResultsState extends State<ServerListingResults> {
  ListingPage? _page;
  String? _error;
  bool _loading = true;
  int _request = 0;
  int? _pageOverride;
  late String _signature;
  bool _waitingForInitialLoad = false;

  String get _currentSignature => jsonEncode([
    widget.query.copyWith(page: _pageOverride).toQueryParameters(),
    widget.provider.queryRevision,
    widget.provider.sessionRevision,
  ]);

  @override
  void initState() {
    super.initState();
    _signature = _currentSignature;
    widget.provider.addListener(_providerChanged);
    _scheduleFetch();
  }

  void _scheduleFetch() {
    _waitingForInitialLoad = widget.provider.isInitializing;
    if (_waitingForInitialLoad) return;
    final scheduled = ++_request;
    Future.microtask(() {
      if (mounted && scheduled == _request) _fetch();
    });
  }

  void _providerChanged() {
    if (!mounted) return;
    final changed = _signature != _currentSignature;
    if (changed) {
      _signature = _currentSignature;
      ++_request;
      _page = null;
      _loading = true;
      _error = null;
      _scheduleFetch();
    } else if (_waitingForInitialLoad && !widget.provider.isInitializing) {
      _scheduleFetch();
    }
    setState(() {});
  }

  @override
  void dispose() {
    widget.provider.removeListener(_providerChanged);
    ++_request;
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ServerListingResults oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (jsonEncode(oldWidget.query.toQueryParameters()) !=
        jsonEncode(widget.query.toQueryParameters())) {
      _pageOverride = null;
    }
    if (widget.provider != oldWidget.provider) {
      oldWidget.provider.removeListener(_providerChanged);
      widget.provider.addListener(_providerChanged);
    }
    final next = _currentSignature;
    if (next != _signature || widget.provider != oldWidget.provider) {
      _signature = next;
      ++_request;
      _page = null;
      _error = null;
      _loading = true;
      _scheduleFetch();
    }
  }

  Future<void> _fetch({bool discardPage = false}) async {
    if (!mounted) return;
    final version = ++_request;
    final provider = widget.provider;
    var query = widget.query.copyWith(page: _pageOverride);
    setState(() {
      _loading = true;
      _error = null;
      if (discardPage) _page = null;
    });
    try {
      var page = await provider.searchListings(query);
      if (!mounted || version != _request) return;
      // Silme sırasında son sayfa kaybolabilir. Hedef her turda küçülür;
      // boş veri kümesinde veya geçerli bir sayfada yeniden sorgulama yapılmaz.
      while (page.items.isEmpty &&
          page.totalCount > 0 &&
          page.totalPages >= 1 &&
          query.page > page.totalPages) {
        query = query.copyWith(page: page.totalPages);
        page = await provider.searchListings(query);
        if (!mounted || version != _request) return;
      }
      if (query.page != widget.query.page) {
        _pageOverride = query.page;
        _signature = _currentSignature;
      }
      setState(() {
        _page = page;
      });
      if (query.page != widget.query.page) {
        widget.onPageCorrected?.call(query.page);
      }
    } catch (error) {
      if (!mounted || version != _request) return;
      setState(() {
        _error = error is ApiException
            ? error.message
            : 'İlanlar yüklenemedi. Tekrar deneyin.';
      });
    } finally {
      if (mounted && version == _request) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _refresh() => _fetch();

  Future<void> _refreshAfterExpiry() async {
    if (_page == null && _loading) return;
    // Kartlar, toplamlar ve sayfa bilgisi aynı API yanıtından gelir.
    await _fetch(discardPage: true);
  }

  @override
  Widget build(BuildContext context) {
    final page = _page;
    final result = ListingPaginationResult(
      items:
          page?.items.map(widget.provider.withCurrentParticipation).toList() ??
          const [],
      currentPage: page?.page ?? 1,
      totalPages: page?.totalPages ?? 1,
      totalItems: page?.totalCount ?? 0,
      pageSize: page?.pageSize ?? widget.query.pageSize,
    );
    final clock = widget.expiryClock;
    if (clock == null) {
      return widget.builder(result, _loading, _error, _refresh);
    }
    return ListingExpiryBoundary(
      items: result.items,
      clock: clock,
      onExpiry: _refreshAfterExpiry,
      builder: (_, _) => widget.builder(result, _loading, _error, _refresh),
    );
  }
}

class ListingQueryStatus extends StatelessWidget {
  const ListingQueryStatus({
    super.key,
    required this.loading,
    required this.error,
    required this.onRetry,
  });
  final bool loading;
  final String? error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Flexible(child: Text('İlanlar yükleniyor…')),
          ],
        ),
      );
    }
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(error!, textAlign: TextAlign.center),
          TextButton(onPressed: onRetry, child: const Text('Tekrar dene')),
        ],
      ),
    );
  }
}
