import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../widgets/app_button.dart';
import '../../widgets/status_badge.dart';

/// Sadeleştirilmiş İlan Detay Ekranı (İskelet Görünümü)
class ListingDetailScreen extends StatelessWidget {
  const ListingDetailScreen({
    super.key,
    required this.ilan,
  });

  final Ilan ilan;

  void _showSkeletonNotice(BuildContext context, String actionName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF18181B),
        content: Text('"$actionName" işlemi yakında kullanıma sunulacaktır.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('İlan Detayı'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rozetler
            Row(
              children: [
                StatusBadge.tur(tur: ilan.tur),
                const SizedBox(width: 8),
                StatusBadge.durum(durum: ilan.durum),
              ],
            ),
            const SizedBox(height: 12),

            // Başlık
            Text(
              ilan.baslik,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF18181B),
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 14),

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
                    const Icon(Icons.schedule_outlined, size: 16, color: Color(0xFF71717A)),
                    const SizedBox(width: 8),
                    Text(
                      dateFormat.format(ilan.bulusmaTarihi!.toLocal()),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF27272A)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Açıklama
            const Text(
              'Açıklama',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF18181B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              ilan.aciklama,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF3F3F46),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),

            // Butonlar (İskelet olarak duruyor)
            if (ilan.tur == IlanTuru.sosyal) ...[
              AppButton(
                label: 'Geliyorum (İskelet Buton)',
                onPressed: () => _showSkeletonNotice(context, 'Geliyorum'),
              ),
              const SizedBox(height: 10),
            ],

            AppButton(
              label: 'İlanı Şikâyet Et (İskelet)',
              isOutlined: true,
              onPressed: () => _showSkeletonNotice(context, 'Şikâyet Et'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
