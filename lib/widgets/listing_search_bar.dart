import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_text_field.dart';

/// İlan akışları ve arama ekranı için minimalist arama çubuğu ve aktif filtre özeti.
class ListingSearchBar extends StatelessWidget {
  const ListingSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.hintText = 'Başlık, açıklama veya konum ara...',
    this.hasActiveFilters = false,
    this.totalResults,
    this.onResetFilters,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String hintText;
  final bool hasActiveFilters;
  final int? totalResults;
  final VoidCallback? onResetFilters;

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            controller: controller,
            onChanged: onChanged,
            hint: hintText,
            search: true,
            trailing: hasText
                ? IconButton(
                    tooltip: 'Aramayı temizle',
                    icon: const Icon(
                      Icons.close,
                      size: 20,
                      color: AppTheme.muted,
                    ),
                    onPressed: onClear,
                  )
                : null,
          ),
          if (hasActiveFilters && totalResults != null) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '$totalResults ilan bulundu',
                    style: AppTheme.meta.copyWith(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onResetFilters != null)
                  TextButton.icon(
                    onPressed: onResetFilters,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.filter_alt_off_outlined, size: 14),
                    label: const Text(
                      'Filtreleri Temizle',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
