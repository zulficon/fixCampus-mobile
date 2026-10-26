import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/status_badge.dart';

/// Profil Yönetimi, Bilgi Düzenleme, Rol Yetkileri ve Çıkış İşlemi
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const List<String> _sinifSecenekleri = [
    'Hazırlık',
    '1. Sınıf',
    '2. Sınıf',
    '3. Sınıf',
    '4. Sınıf',
    'Yüksek Lisans / Doktora',
    'Mezun',
  ];

  void _showEditProfileDialog(BuildContext context, AuthProvider auth) {
    final user = auth.currentUser;
    final nameController = TextEditingController(text: user?.adSoyad ?? '');
    final bolumController = TextEditingController(text: user?.bolum ?? 'Bilgisayar Mühendisliği');
    String secilenSinif = user?.sinif ?? '4. Sınıf';
    if (!_sinifSecenekleri.contains(secilenSinif)) {
      secilenSinif = _sinifSecenekleri[3]; // 4. Sınıf
    }

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            'Profili Düzenle',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ad Soyad
                  const Text(
                    'Ad ve Soyad',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF27272A)),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: 'Ad Soyad',
                      isDense: true,
                      prefixIcon: Icon(Icons.person_outline, size: 20),
                    ),
                    validator: (val) {
                      final text = val?.trim() ?? '';
                      if (text.isEmpty) return 'Ad Soyad boş bırakılamaz.';
                      if (text.length < 2) return 'En az 2 karakter olmalıdır.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Bölüm
                  const Text(
                    'Bölüm',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF27272A)),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: bolumController,
                    decoration: const InputDecoration(
                      hintText: 'Örn: Bilgisayar Mühendisliği',
                      isDense: true,
                      prefixIcon: Icon(Icons.school_outlined, size: 20),
                    ),
                    validator: (val) {
                      final text = val?.trim() ?? '';
                      if (text.isEmpty) return 'Bölüm bilgisi boş bırakılamaz.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Sınıf
                  const Text(
                    'Sınıf',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF27272A)),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: secilenSinif,
                    isDense: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.badge_outlined, size: 20),
                    ),
                    items: _sinifSecenekleri
                        .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13))))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          secilenSinif = val;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal', style: TextStyle(color: Color(0xFF71717A))),
            ),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await auth.updateProfile(
                    adSoyad: nameController.text,
                    bolum: bolumController.text,
                    sinif: secilenSinif,
                  );
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profil bilgileriniz başarıyla güncellendi.'),
                        backgroundColor: AppTheme.primaryBlack,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryBlack,
              ),
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç', style: TextStyle(color: Color(0xFF71717A))),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              auth.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final listingsProvider = context.watch<ListingsProvider>();
    final user = auth.currentUser;
    final userListings = listingsProvider.getUserListings(user?.id ?? '');

    final isAdmin = auth.isAdmin;
    final roleText = isAdmin ? 'Yönetici' : 'Öğrenci';

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profil Kartı
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE4E4E7)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x05000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: isAdmin ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
                        child: Text(
                          user != null && user.adSoyad.isNotEmpty
                              ? user.adSoyad.substring(0, 1).toUpperCase()
                              : 'K',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isAdmin ? Colors.white : const Color(0xFF18181B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.adSoyad ?? 'Giriş Yapılmadı',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF18181B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              auth.currentEmail ?? 'kampus@ogr.edu.tr',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF71717A),
                              ),
                            ),
                            const SizedBox(height: 6),
                            StatusBadge.rol(
                              rol: user?.rol ?? KullaniciRolu.ogrenci,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Profili Düzenle',
                        icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF52525B)),
                        onPressed: () => _showEditProfileDialog(context, auth),
                      ),
                    ],
                  ),

                  // Bölüm ve Sınıf Detay Alanı
                  if (user != null && (user.bolum != null || user.sinif != null)) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.school_outlined, size: 16, color: Color(0xFF64748B)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    user.bolum ?? 'Bölüm Belirtilmedi',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF334155),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 16, color: const Color(0xFFCBD5E1), margin: const EdgeInsets.symmetric(horizontal: 8)),
                          Row(
                            children: [
                              const Icon(Icons.badge_outlined, size: 16, color: Color(0xFF64748B)),
                              const SizedBox(width: 6),
                              Text(
                                user.sinif ?? '-',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const Divider(height: 22, color: Color(0xFFF4F4F5)),

                  // Hızlı Rol Geçiş Çipi
                  Row(
                    children: [
                      Icon(
                        isAdmin ? Icons.admin_panel_settings : Icons.school,
                        size: 16,
                        color: const Color(0xFF71717A),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mevcut Yetki: $roleText',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF71717A), fontWeight: FontWeight.w500),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => auth.toggleRoleForDemo(),
                        icon: const Icon(Icons.swap_horiz, size: 16),
                        label: Text(
                          isAdmin ? 'Öğrenciye Geç' : 'Yöneticiye Geç',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Yönetici Paneli Erişimi (Yalnızca Yönetici Görür)
            if (isAdmin)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF09090B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.shield, color: Colors.white),
                  title: const Text(
                    'Yönetici Paneli',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Şikâyetler ve kategori denetimleri',
                    style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 12),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.adminPanel);
                  },
                ),
              ),

            const SizedBox(height: 16),

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

            const SizedBox(height: 24),

            // Çıkış Yap Butonu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: () => _handleLogout(context, auth),
                icon: const Icon(Icons.logout, size: 18, color: Color(0xFFDC2626)),
                label: const Text(
                  'Çıkış Yap',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDC2626),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: const Color(0xFFFEF2F2),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
