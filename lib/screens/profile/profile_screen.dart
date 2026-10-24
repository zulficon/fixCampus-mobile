import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/listing_card.dart';

/// Sadeleştirilmiş Profil Ekranı (Yönetici Paneli ve Rol Geçişleri Kaldırıldı)
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final listingsProvider = context.watch<ListingsProvider>();
    final user = auth.currentUser;
    final userListings = listingsProvider.getUserListings(user?.id ?? '');

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sade Profil Kartı
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE4E4E7)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFF4F4F5),
                    child: Text(
                      user != null && user.adSoyad.isNotEmpty
                          ? user.adSoyad.substring(0, 1).toUpperCase()
                          : 'B',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF18181B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.adSoyad ?? 'Berke Mahmut Acar',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF18181B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Öğrenci',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF71717A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // İlanlarım Başlığı
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'İlanlarım',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF18181B),
                    ),
                  ),
                  Text(
                    '${userListings.length} İlan',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF71717A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // İlan Listesi
            if (userListings.isEmpty)
              const EmptyState(
                icon: Icons.post_add_outlined,
                title: 'Henüz İlanınız Yok',
                description: 'Oluşturduğunuz ilanlar bu bölümde listelenecektir.',
              )
            else
              ...userListings.map(
                (item) => ListingCard(
                  ilan: item,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.listingDetail,
                      arguments: item,
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
