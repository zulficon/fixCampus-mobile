import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/listings_provider.dart';
import '../../theme/app_theme.dart';

/// Yönetici Paneli İskeleti (Şikâyet ve Kategori Yönetimi Taslağı)
class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listingsProvider = context.watch<ListingsProvider>();

    final ornekSikayetler = [
      Sikayet(
        id: 'sikayet-1',
        ilanId: 'ilan-2',
        bildirenId: '00000000-0000-0000-0000-000000000005',
        neden: 'Etkinlik yeri yanlış belirtilmiş veya spam içerik.',
        durum: SikayetDurumu.bekliyor,
        olusturulmaTarihi: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Yönetici Paneli (Taslak)'),
          bottom: const TabBar(
            indicatorColor: AppTheme.primaryBlack,
            labelColor: AppTheme.primaryBlack,
            unselectedLabelColor: Color(0xFF71717A),
            tabs: [
              Tab(text: 'Şikâyetler'),
              Tab(text: 'Kategoriler'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Şikâyetler Sekmesi
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ornekSikayetler.length,
              itemBuilder: (context, index) {
                final s = ornekSikayetler[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Şikâyet (İlan: ${s.ilanId})',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          s.neden,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF3F3F46)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Kategoriler Sekmesi
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: listingsProvider.kategoriler.length,
              itemBuilder: (context, index) {
                final k = listingsProvider.kategoriler[index];
                return ListTile(
                  title: Text(k.ad, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: Text('Tür: ${k.tur.apiValue}', style: const TextStyle(fontSize: 12)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
