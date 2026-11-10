import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';

import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/role_session_guard.dart';

/// Geçerli API profilinin ilanları; yönetici de yalnız kendi ilanlarını görür.
class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const RoleSessionGuard(child: _MyListingsContent());
}

class _MyListingsContent extends StatefulWidget {
  const _MyListingsContent();

  @override
  State<_MyListingsContent> createState() => _MyListingsContentState();
}

class _MyListingsContentState extends State<_MyListingsContent> {
  IlanTuru? _type;
  String? _profileId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = context.watch<AuthProvider>().currentUser?.id;
    if (_profileId != id) {
      _profileId = id;
      _type = null;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<ListingsProvider>();
      if (!provider.isLoading) provider.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<ListingsProvider>();
    final ownItems = provider.getUserListings(auth.currentUser!.id);
    final items =
        ownItems.where((item) => _type == null || item.tur == _type).toList()
          ..sort((a, b) {
            final date = b.olusturulmaTarihi.compareTo(a.olusturulmaTarihi);
            return date != 0 ? date : a.id.compareTo(b.id);
          });
    final error = provider.error;
    return Scaffold(
      appBar: AppBar(
        title: const Text('İlanlarım'),
        actions: [
          IconButton(
            tooltip: 'İlanlarımı yenile',
            onPressed: provider.isLoading ? null : provider.load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await provider.load();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in const <IlanTuru?, String>{
                    null: 'Tümü',
                    IlanTuru.sosyal: 'Sosyal',
                    IlanTuru.kayip: 'Kayıp',
                    IlanTuru.buluntu: 'Buluntu',
                  }.entries)
                    ChoiceChip(
                      label: Text(entry.value),
                      selected: _type == entry.key,
                      onSelected: (_) => setState(() => _type = entry.key),
                    ),
                ],
              ),
            ),
            if (provider.isLoading) const LinearProgressIndicator(),
            if (error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(error, textAlign: TextAlign.center),
                    TextButton(
                      onPressed: provider.isLoading ? null : provider.load,
                      child: const Text('Tekrar dene'),
                    ),
                  ],
                ),
              ),
            if (!provider.isLoading && error == null && items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.post_add_outlined, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      ownItems.isEmpty
                          ? 'Henüz ilanınız yok'
                          : 'Bu türde ilanınız yok',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ownItems.isEmpty
                          ? 'Oluşturduğunuz ilanlar burada listelenir.'
                          : 'Diğer ilanlarınız için Tümü filtresini seçin.',
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.createListing),
                      child: const Text('İlan oluştur'),
                    ),
                  ],
                ),
              ),
            if (items.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${items.length} ilan',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              for (final item in items)
                ListingCard(
                  key: ValueKey(item.id),
                  ilan: item,
                  isAttending: provider.isUserAttending(
                    item.id,
                    auth.currentUser!.id,
                  ),
                  attendanceCount: provider.getAttendanceCount(item.id),
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.listingDetail,
                    arguments: item,
                  ),
                ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
