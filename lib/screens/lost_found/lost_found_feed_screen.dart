import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/listings_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/listing_card.dart';

/// Sadeleştirilmiş Kayıp & Buluntu Akış Ekranı
class LostFoundFeedScreen extends StatefulWidget {
  const LostFoundFeedScreen({super.key});

  @override
  State<LostFoundFeedScreen> createState() => _LostFoundFeedScreenState();
}

class _LostFoundFeedScreenState extends State<LostFoundFeedScreen> {
  IlanTuru? _filterTur;
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final listingsProvider = context.watch<ListingsProvider>();

    final categories = listingsProvider.kategoriler
        .where((k) => k.tur == IlanTuru.kayip || k.tur == IlanTuru.buluntu)
        .toList();

    var items = listingsProvider.getLostFoundListings(turFilter: _filterTur);
    if (_selectedCategoryId != null) {
      items = items.where((i) => i.kategoriId == _selectedCategoryId).toList();
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Sade Başlık
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kayıp & Buluntu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF18181B),
                      letterSpacing: -0.4,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Kayıp ve bulunan eşya bildirimleri',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF71717A),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sade Segment Seçici
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    Expanded(
                      child: _SimpleSegment(
                        label: 'Tümü',
                        isSelected: _filterTur == null,
                        onTap: () => setState(() => _filterTur = null),
                      ),
                    ),
                    Expanded(
                      child: _SimpleSegment(
                        label: 'Kayıp',
                        isSelected: _filterTur == IlanTuru.kayip,
                        onTap: () => setState(() => _filterTur = IlanTuru.kayip),
                      ),
                    ),
                    Expanded(
                      child: _SimpleSegment(
                        label: 'Bulunan',
                        isSelected: _filterTur == IlanTuru.buluntu,
                        onTap: () => setState(() => _filterTur = IlanTuru.buluntu),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Kategori Çipleri
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  CategoryChip(
                    label: 'Tümü',
                    isSelected: _selectedCategoryId == null,
                    onTap: () => setState(() => _selectedCategoryId = null),
                  ),
                  ...categories.map(
                    (cat) => CategoryChip(
                      label: cat.ad,
                      isSelected: _selectedCategoryId == cat.id,
                      onTap: () {
                        setState(() {
                          _selectedCategoryId =
                              _selectedCategoryId == cat.id ? null : cat.id;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Liste
          if (items.isEmpty)
            const SliverFillRemaining(
              child: EmptyState(
                icon: Icons.search_off_outlined,
                title: 'İlan Bulunamadı',
                description: 'Kriterlere uygun ilan bulunmuyor.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 24, top: 4),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = items[index];
                    return ListingCard(
                      ilan: item,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.listingDetail,
                          arguments: item,
                        );
                      },
                    );
                  },
                  childCount: items.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SimpleSegment extends StatelessWidget {
  const _SimpleSegment({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.black : const Color(0xFF71717A),
            ),
          ),
        ),
      ),
    );
  }
}
