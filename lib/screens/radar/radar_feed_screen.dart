import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../routes/app_routes.dart';
import '../../security/listing_expiry_policy.dart';
import '../../services/api_exception.dart';
import '../../services/listings_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/listing_search_filter.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/expiry_aware_listing_results.dart';
import '../../widgets/listing_expiry_boundary.dart';
import '../../widgets/listing_search_bar.dart';
import '../../widgets/pagination_controls.dart';
import '../../widgets/server_listing_results.dart';
import '../listings/listing_search_screen.dart';
import 'radar_meeting_card.dart';
import 'radar_summary.dart';

enum _RadarMenu { notifications, search, detailedSearch, myListings }

class RadarFeedScreen extends StatefulWidget {
  const RadarFeedScreen({
    super.key,
    this.pageSize = ListingSearchFilter.defaultPageSize,
    this.bottomClearance = 20,
  });

  final int pageSize;
  final double bottomClearance;

  @override
  State<RadarFeedScreen> createState() => _RadarFeedScreenState();
}

class _RadarFeedScreenState extends State<RadarFeedScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String? _selectedCategoryId;
  int _currentPage = 1;
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters =>
      _searchController.text.trim().isNotEmpty || _selectedCategoryId != null;

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategoryId = null;
      _currentPage = 1;
    });
  }

  void _handleMenu(_RadarMenu option, String? categoryId) {
    switch (option) {
      case _RadarMenu.notifications:
        _message('Kampüs bildirimleri henüz kullanıma açık değil.');
      case _RadarMenu.search:
        setState(() => _showSearch = true);
        if (_scrollController.hasClients) _scrollController.jumpTo(0);
      case _RadarMenu.detailedSearch:
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => ListingSearchScreen(
              initialTur: IlanTuru.sosyal,
              initialCategoryId: categoryId,
              initialQuery: _searchController.text,
            ),
          ),
        );
      case _RadarMenu.myListings:
        Navigator.pushNamed(context, AppRoutes.myListings);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _toggleParticipation(Ilan listing) async {
    final provider = context.read<ListingsProvider>();
    if (provider.isSaving ||
        context.read<AuthProvider>().currentUser == null ||
        const ListingExpiryPolicy().isExpired(listing, DateTime.now())) {
      return;
    }

    final session = provider.sessionRevision;
    try {
      await provider.setParticipation(
        listing.id,
        attending: !listing.katiliyor,
      );
    } catch (error) {
      if (mounted && session == provider.sessionRevision) {
        _message(
          error is ApiException
              ? error.message
              : 'Katılım güncellenemedi. Tekrar deneyin.',
        );
      }
    }
  }

  void _showLocations(List<Ilan> meetings) {
    final locations = <String, Uri>{};
    for (final listing in meetings) {
      if (listing.haritaBaglantisi case final uri?) {
        locations.putIfAbsent(listing.yer.trim(), () => uri);
      }
    }
    if (locations.isEmpty) {
      _message('Haritada açılabilecek buluşma konumu bulunamadı.');
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.pageInset),
              child: Text('Buluşma konumları', style: AppTheme.section),
            ),
            for (final location in locations.entries)
              ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: Text(location.key),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () async {
                  try {
                    if (await launchUrl(
                      location.value,
                      mode: LaunchMode.externalApplication,
                    )) {
                      return;
                    }
                  } catch (_) {
                    // The address remains visible if the device has no map handler.
                  }
                  if (mounted) _message('Harita açılamadı.');
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingsProvider>();
    final auth = context.watch<AuthProvider>();
    final allListings = provider.ilanlar;
    final socialMeetings = provider.radarListings;
    final categories = provider.kategoriler
        .where((category) => category.tur == IlanTuru.sosyal)
        .toList();
    final categoryNames = {
      for (final category in categories) category.id: category.ad,
    };
    final selectedCategory = categoryNames.containsKey(_selectedCategoryId)
        ? _selectedCategoryId
        : null;

    return ExpiryAwareListingResults(
      provider: provider,
      query: ListingQuery(
        tur: IlanTuru.sosyal,
        kategoriId: selectedCategory,
        text: _searchController.text,
        page: _currentPage,
        pageSize: widget.pageSize,
        activeSocialOnly: true,
      ),
      onPageCorrected: (page) => setState(() => _currentPage = page),
      builder: (page, loading, error, refresh) {
        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: refresh,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.pageInset,
                      AppTheme.safeTopGap,
                      AppTheme.pageInset,
                      18,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 20,
                        children: [
                          _RadarHeader(
                            isAdmin: auth.isAdmin,
                            onSelected: (option) =>
                                _handleMenu(option, selectedCategory),
                          ),
                          const Text(
                            'Bugün kampüste\nkimler buluşuyor?',
                            style: AppTheme.display,
                          ),
                          ListingExpiryBoundary(
                            items: socialMeetings,
                            builder: (context, now) {
                              final active = socialMeetings
                                  .where(
                                    (listing) => !const ListingExpiryPolicy()
                                        .isExpired(listing, now),
                                  )
                                  .length;
                              final lostCount = allListings
                                  .where(
                                    (listing) =>
                                        listing.tur == IlanTuru.kayip &&
                                        listing.durum == IlanDurumu.aktif,
                                  )
                                  .length;
                              final pending =
                                  allListings.isEmpty &&
                                  (provider.isLoading ||
                                      provider.error != null);
                              return RadarSummary(
                                meetings: pending ? null : active,
                                lostItems: pending ? null : lostCount,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showSearch || _searchController.text.isNotEmpty)
                    SliverToBoxAdapter(
                      child: ListingSearchBar(
                        controller: _searchController,
                        hintText:
                            'Sosyal ilanlarda başlık, açıklama veya yer ara...',
                        hasActiveFilters: _hasActiveFilters,
                        totalResults: loading || error != null
                            ? null
                            : page.totalItems,
                        onResetFilters: _resetFilters,
                        onChanged: (_) => setState(() => _currentPage = 1),
                        onClear: () => setState(() {
                          _searchController.clear();
                          _currentPage = 1;
                        }),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: AppTheme.tapSize,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.pageInset,
                        ),
                        children: [
                          CategoryChip(
                            label: 'Tümü',
                            isSelected: selectedCategory == null,
                            onTap: () => setState(() {
                              _selectedCategoryId = null;
                              _currentPage = 1;
                            }),
                          ),
                          for (final category in categories)
                            CategoryChip(
                              label: category.ad,
                              isSelected: selectedCategory == category.id,
                              onTap: () => setState(() {
                                _selectedCategoryId =
                                    selectedCategory == category.id
                                    ? null
                                    : category.id;
                                _currentPage = 1;
                              }),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.pageInset,
                      12,
                      AppTheme.pageInset,
                      10,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        spacing: 8,
                        children: [
                          const Expanded(
                            child: Text(
                              'Yakındaki buluşmalar',
                              style: AppTheme.section,
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              textStyle: AppTheme.meta,
                            ),
                            onPressed: () => _showLocations(page.items),
                            child: const Text('Haritada gör'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: ListingQueryStatus(
                      loading: loading || provider.isLoading,
                      error: error ?? provider.error,
                      onRetry: refresh,
                    ),
                  ),
                  if (page.items.isEmpty &&
                      !loading &&
                      error == null &&
                      !provider.isLoading &&
                      provider.error == null)
                    SliverToBoxAdapter(
                      child: EmptyState(
                        icon: Icons.event_busy_outlined,
                        title: 'Buluşma Bulunamadı',
                        description: _hasActiveFilters
                            ? 'Arama veya kategori kriterlerine uygun buluşma bulunmuyor.'
                            : 'Henüz aktif bir buluşma bulunmuyor.',
                        actionLabel: _hasActiveFilters
                            ? 'Filtreleri Temizle'
                            : null,
                        onAction: _hasActiveFilters ? _resetFilters : null,
                      ),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.pageInset,
                    ),
                    sliver: SliverList.separated(
                      itemCount: page.items.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppTheme.listGap),
                      itemBuilder: (context, index) {
                        final listing = page.items[index];
                        return RadarMeetingCard(
                          listing: listing,
                          category:
                              categoryNames[listing.kategoriId] ?? 'Buluşma',
                          onOpen: () => Navigator.pushNamed(
                            context,
                            AppRoutes.listingDetail,
                            arguments: listing,
                          ),
                          onParticipation:
                              auth.currentUser == null ||
                                  auth.hasSessionError ||
                                  provider.isSaving
                              ? null
                              : () => _toggleParticipation(listing),
                        );
                      },
                    ),
                  ),
                  if (page.items.isNotEmpty)
                    SliverToBoxAdapter(
                      child: PaginationControls(
                        pagination: page,
                        onPageChanged: (next) =>
                            setState(() => _currentPage = next),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: SizedBox(height: widget.bottomClearance),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RadarHeader extends StatelessWidget {
  const _RadarHeader({required this.isAdmin, required this.onSelected});

  final bool isAdmin;
  final ValueChanged<_RadarMenu> onSelected;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2,
          children: [
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'fix'),
                  TextSpan(
                    text: 'Campus',
                    style: TextStyle(color: AppTheme.primary),
                  ),
                ],
              ),
              style: AppTheme.logo,
              semanticsLabel: 'fixCampus',
            ),
            Text.rich(
              TextSpan(
                children: [
                  const WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppTheme.muted,
                    ),
                  ),
                  const TextSpan(text: ' Merkez Kampüs'),
                  if (isAdmin) const TextSpan(text: ' · Yönetici'),
                ],
              ),
              style: AppTheme.meta,
            ),
          ],
        ),
      ),
      PopupMenuButton<_RadarMenu>(
        tooltip: 'Bildirimler ve menü',
        onSelected: onSelected,
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: _RadarMenu.notifications,
            child: Text('Bildirimler'),
          ),
          PopupMenuItem(value: _RadarMenu.search, child: Text('Radar’da ara')),
          PopupMenuItem(
            value: _RadarMenu.detailedSearch,
            child: Text('Detaylı Arama'),
          ),
          PopupMenuItem(value: _RadarMenu.myListings, child: Text('İlanlarım')),
        ],
        child: Container(
          width: AppTheme.tapSize,
          height: AppTheme.tapSize,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.controlRadius),
            border: Border.all(color: AppTheme.line),
          ),
          child: const Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                size: 23,
                color: AppTheme.ink,
              ),
              Positioned(
                top: 10,
                right: 11,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppTheme.lost,
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(
                      BorderSide(color: AppTheme.surface, width: 1.5),
                    ),
                  ),
                  child: SizedBox.square(dimension: 9),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
