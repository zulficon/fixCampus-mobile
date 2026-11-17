import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge.tur({super.key, required this.tur})
    : durum = null,
      rol = null,
      customLabel = null,
      customBg = null,
      customTextColor = null;

  const StatusBadge.durum({super.key, required this.durum})
    : tur = null,
      rol = null,
      customLabel = null,
      customBg = null,
      customTextColor = null;

  const StatusBadge.rol({super.key, required this.rol})
    : tur = null,
      durum = null,
      customLabel = null,
      customBg = null,
      customTextColor = null;

  const StatusBadge.custom({
    super.key,
    required this.customLabel,
    this.customBg,
    this.customTextColor,
  }) : tur = null,
       durum = null,
       rol = null;

  final IlanTuru? tur;
  final IlanDurumu? durum;
  final KullaniciRolu? rol;
  final String? customLabel;
  final Color? customBg;
  final Color? customTextColor;

  @override
  Widget build(BuildContext context) {
    final (label, background, foreground) = switch ((tur, durum, rol)) {
      (IlanTuru.sosyal, _, _) => (
        'Sosyal',
        AppTheme.primaryTint,
        AppTheme.primaryDark,
      ),
      (IlanTuru.kayip, _, _) => ('Kayıp', AppTheme.lostTint, AppTheme.lostDark),
      (IlanTuru.buluntu, _, _) => (
        'Buluntu',
        AppTheme.primaryTint,
        AppTheme.primaryDark,
      ),
      (_, IlanDurumu.aktif, _) => (
        'Aktif',
        AppTheme.primaryTint,
        AppTheme.primaryDark,
      ),
      (_, IlanDurumu.cozuldu, _) => (
        'Çözüldü',
        AppTheme.foundTint,
        AppTheme.foundDark,
      ),
      (_, IlanDurumu.gizli, _) => (
        'Gizli',
        AppTheme.inactiveBg,
        AppTheme.inactiveText,
      ),
      (_, _, KullaniciRolu.yonetici) => (
        'Yönetici',
        AppTheme.ink,
        AppTheme.surface,
      ),
      (_, _, KullaniciRolu.ogrenci) => (
        'Öğrenci',
        AppTheme.primaryTint,
        AppTheme.primaryDark,
      ),
      _ => (
        customLabel,
        customBg ?? AppTheme.inactiveBg,
        customTextColor ?? AppTheme.inactiveText,
      ),
    };
    if (label == null) return const SizedBox.shrink();

    return Container(
      constraints: const BoxConstraints(minHeight: 26),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppTheme.badgeRadius),
      ),
      child: Align(
        alignment: Alignment.center,
        widthFactor: 1,
        heightFactor: 1,
        child: Text(
          label,
          style: AppTheme.label.copyWith(fontSize: 12, color: foreground),
        ),
      ),
    );
  }
}
