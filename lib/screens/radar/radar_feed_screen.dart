import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/listing_card.dart';

/// Sadeleştirilmiş Sosyal Radar Akış Ekranı
class RadarFeedScreen extends StatefulWidget {
  const RadarFeedScreen({super.key});

  @override
  State<RadarFeedScreen> createState() => _RadarFeedScreenState();
}

class _RadarFeedScreenState extends State<RadarFeedScreen> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final listingsProvider = context.watch<ListingsProvider>();
    final auth = context.watch<AuthProvider>();
    final currentUserId = auth.currentUser?.id ?? '';

    final categories = listingsProvider.kategoriler
        .where((k) => k.tur == IlanTuru.sosyal)
        .toList();

    var items = listingsProvider.radarListings;
    if (_selectedCategoryId != null) {
      items = items.where((i) => i.kategoriId == _selectedCategoryId).toList();
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Sade Başlık
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sosyal Radar',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF18181B),
                      letterSpacing: -0.4,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Kampüsteki buluşma ve çalışma ilanları',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF71717A),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Kategori Filtreleme Çipleri
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
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = null;
                      });
                    },
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

          // İlan Listesi
          if (items.isEmpty)
            const SliverFillRemaining(
              child: EmptyState(
                icon: Icons.event_busy_outlined,
                title: 'Buluşma Bulunamadı',
                description: 'Seçilen kategoride henüz aktif bir buluşma bulunmuyor.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 24, top: 4),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = items[index];
                    final isAttending = listingsProvider.isUserAttending(
                      item.id,
                      currentUserId,
                    );
                    final count = listingsProvider.getAttendanceCount(item.id);

                    return ListingCard(
                      ilan: item,
                      isAttending: isAttending,
                      attendanceCount: count,
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
