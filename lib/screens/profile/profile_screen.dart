import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/listing_card.dart';

/// Profil bilgileri API'den okunur; ad soyad API üzerinden güncellenir.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _editProfile(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final name = await showDialog<String>(
      context: context,
      builder: (_) =>
          _EditProfileDialog(initialName: auth.currentUser?.adSoyad ?? ''),
    );
    if (name == null || !context.mounted) return;
    final success = await auth.updateProfile(name);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? 'Profil güncellendi.'
            : auth.message ?? 'Profil güncellenemedi.')));
  }

  Future<void> _logout(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final success = await auth.logout();
    if (!context.mounted) return;
    if (success) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.message ?? 'Çıkış yapılamadı.')));
    }
  }

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
                          user?.adSoyad ?? 'Profil bilgisi yüklenemedi',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF18181B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          auth.isAdmin ? 'Yönetici' : 'Öğrenci',
                          style: const TextStyle(
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

            if (auth.email != null)
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(auth.email!)),
            if (auth.message != null)
              Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(auth.message!)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(spacing: 12, children: [
                TextButton(
                    onPressed:
                        auth.isLoading ? null : () => _editProfile(context),
                    child: const Text('Profili düzenle')),
                if (user == null)
                  TextButton(
                      onPressed:
                          auth.isLoading ? null : () => auth.initialize(),
                      child: const Text('Tekrar dene')),
                TextButton(
                    onPressed: auth.isLoading ? null : () => _logout(context),
                    child: const Text('Çıkış yap')),
              ]),
            ),
            if (auth.isLoading) const LinearProgressIndicator(),

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
                description:
                    'Oluşturduğunuz ilanlar bu bölümde listelenecektir.',
              )
            else
              ...userListings.map((item) {
                final isAttending = listingsProvider.isUserAttending(
                  item.id,
                  user?.id ?? '',
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
              }),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({required this.initialName});
  final String initialName;
  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Profili düzenle'),
        content: TextField(
            controller: _controller,
            maxLength: 100,
            decoration: const InputDecoration(labelText: 'Ad soyad')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Vazgeç')),
          TextButton(
              onPressed: () => Navigator.pop(context, _controller.text),
              child: const Text('Kaydet')),
        ],
      );
}
