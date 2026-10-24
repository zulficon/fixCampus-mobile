import 'package:flutter/material.dart';
import '../models/models.dart';

/// Sadeleştirilmiş Minimalist Rozet
class StatusBadge extends StatelessWidget {
  const StatusBadge.tur({
    super.key,
    required this.tur,
  })  : durum = null,
        isTur = true;

  const StatusBadge.durum({
    super.key,
    required this.durum,
  })  : tur = null,
        isTur = false;

  final IlanTuru? tur;
  final IlanDurumu? durum;
  final bool isTur;

  @override
  Widget build(BuildContext context) {
    if (isTur && tur != null) {
      String label;
      switch (tur!) {
        case IlanTuru.sosyal:
          label = 'Sosyal';
          break;
        case IlanTuru.kayip:
          label = 'Kayıp';
          break;
        case IlanTuru.buluntu:
          label = 'Buluntu';
          break;
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F5),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE4E4E7), width: 1),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF18181B),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (durum != null) {
      String label;
      switch (durum!) {
        case IlanDurumu.aktif:
          label = 'Aktif';
          break;
        case IlanDurumu.cozuldu:
          label = 'Çözüldü';
          break;
        case IlanDurumu.gizli:
          label = 'Gizli';
          break;
      }

      final isResolved = durum == IlanDurumu.cozuldu;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isResolved ? const Color(0xFFF4F4F5) : Colors.black,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isResolved ? const Color(0xFF71717A) : Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
