import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_button.dart';
import 'sticker_slot.dart';

/// Boş Veri Durumu Bileşeni
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    this.sticker,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final StickerSlot? sticker;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            sticker ??
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryTint,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 48, color: AppTheme.primaryDark),
                ),
            const SizedBox(height: 20),
            Text(title, textAlign: TextAlign.center, style: AppTheme.cardTitle),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: AppTheme.body.copyWith(color: AppTheme.muted),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              AppButton(
                onPressed: onAction,
                label: actionLabel!,
                fullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
