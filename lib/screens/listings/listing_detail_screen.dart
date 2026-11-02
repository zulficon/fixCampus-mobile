import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/listing_validator.dart';
import '../../widgets/app_button.dart';
import '../../widgets/status_badge.dart';

/// İlan Detay Ekranı (CRUD Düzenleme, Silme ve Katılım Yönetimi)
class ListingDetailScreen extends StatefulWidget {
  const ListingDetailScreen({
    super.key,
    required this.ilan,
  });

  final Ilan ilan;

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  bool _isDeleting = false;

  Future<void> _handleDelete(Ilan ilan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('İlanı Sil'),
        content: const Text(
          'Bu ilanı silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFDC2626),
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    final provider = context.read<ListingsProvider>();
    final success = await provider.deleteListing(ilan.id);

    if (!mounted) return;
    setState(() => _isDeleting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF18181B),
          content: Text('İlan başarıyla silindi.'),
        ),
      );
      Navigator.pop(context);
    } else {
      final error = provider.errorMessage ?? 'İlan silinemedi.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text(error),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final listingsProvider = context.watch<ListingsProvider>();
    final dateFormat = DateFormat('dd.MM.yyyy, HH:mm');

    // Sağlayıcıdaki güncel ilan verisini al (düzenlenmiş veya çözüldü olabilir)
    final ilan = listingsProvider.getListingById(widget.ilan.id) ?? widget.ilan;
    final currentUser = auth.currentUser;

    // Sahiplik veya Yönetici kontrolü
    final canManage = ListingValidator.canEditOrDelete(
      ilan: ilan,
      user: currentUser,
    );

    // Kategori adı
    final kategori = listingsProvider.kategoriler.where((k) => k.id == ilan.kategoriId);
    final kategoriAdi = kategori.isNotEmpty ? kategori.first.ad : null;

    final isAttending = currentUser != null &&
        listingsProvider.isUserAttending(ilan.id, currentUser.id);
    final attendanceCount = listingsProvider.getAttendanceCount(ilan.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('İlan Detayı'),
        actions: [
          if (canManage) ...[
            IconButton(
              key: const Key('detail_edit_button'),
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'İlanı Düzenle',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.editListing,
                  arguments: ilan,
                );
              },
            ),
            IconButton(
              key: const Key('detail_delete_button'),
              icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
              tooltip: 'İlanı Sil',
              onPressed: _isDeleting ? null : () => _handleDelete(ilan),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rozetler & Kategori
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                StatusBadge.tur(tur: ilan.tur),
                StatusBadge.durum(durum: ilan.durum),
                if (kategoriAdi != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE4E4E7)),
                    ),
                    child: Text(
                      kategoriAdi,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF52525B),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Başlık
            Text(
              ilan.baslik,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF18181B),
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 14),

            // Konum / Yer Bilgisi
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE4E4E7)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: Color(0xFF71717A),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ilan.yer,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF27272A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Sosyal İlan Buluşma Zamanı
            if (ilan.tur == IlanTuru.sosyal && ilan.bulusmaTarihi != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE4E4E7)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule_outlined,
                      size: 18,
                      color: Color(0xFF71717A),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Buluşma: ${dateFormat.format(ilan.bulusmaTarihi!.toLocal())}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF27272A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Açıklama Bölümü
            const Text(
              'Açıklama',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF18181B),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE4E4E7)),
              ),
              child: Text(
                ilan.aciklama,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF3F3F46),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sahiplik Eylem Çubuğu
            if (canManage) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.manage_accounts_outlined,
                            size: 18, color: Color(0xFF0F172A)),
                        const SizedBox(width: 8),
                        Text(
                          currentUser?.rol == KullaniciRolu.yonetici
                              ? 'Yönetici İlan Denetimi'
                              : 'İlanınızı Yönetin',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            key: const Key('detail_action_edit'),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.editListing,
                                arguments: ilan,
                              );
                            },
                            icon: const Icon(Icons.edit_outlined, size: 16),
                            label: const Text('Düzenle'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            key: const Key('detail_action_delete'),
                            onPressed: _isDeleting
                                ? null
                                : () => _handleDelete(ilan),
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 16,
                              color: Color(0xFFDC2626),
                            ),
                            label: const Text(
                              'Sil',
                              style: TextStyle(color: Color(0xFFDC2626)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (ilan.durum == IlanDurumu.aktif &&
                        (ilan.tur == IlanTuru.kayip ||
                            ilan.tur == IlanTuru.buluntu)) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () {
                            listingsProvider.markAsResolved(ilan.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Color(0xFF18181B),
                                content: Text('İlan çözüldü olarak güncellendi.'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_circle_outline, size: 16),
                          label: const Text('Çözüldü Olarak İşaretle'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Katılım Butonu (Sosyal İlanlar İçin)
            if (ilan.tur == IlanTuru.sosyal) ...[
              AppButton(
                key: const Key('detail_attendance_button'),
                label: isAttending
                    ? 'Katıldın ($attendanceCount)'
                    : 'Buluşmaya Katıl ($attendanceCount)',
                icon: isAttending ? Icons.check : Icons.group_add_outlined,
                isOutlined: isAttending,
                onPressed: currentUser == null
                    ? null
                    : () {
                        listingsProvider.toggleAttendance(
                          ilan.id,
                          currentUser.id,
                        );
                      },
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
