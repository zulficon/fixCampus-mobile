import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Sosyal buluşma ve kampüs ilanları için hızlı kampüs yeri seçici çipler.
/// Seçilen nokta bağlı [controller] metin alanına otomatik yazılır; kullanıcı
/// dilerse metin kutusuna özel bir konum da yazabilir.
class MeetingLocationPicker extends StatelessWidget {
  const MeetingLocationPicker({
    super.key,
    required this.controller,
    this.enabled = true,
    this.presets = defaultCampusLocations,
  });

  final TextEditingController controller;
  final bool enabled;
  final List<String> presets;

  static const List<String> defaultCampusLocations = [
    'Merkez Kütüphane',
    'Öğrenci Merkezi',
    'Güneş Meydanı',
    'Mühendislik Kantini',
    'Spor Salonu Önü',
    'Yemekhane Meydanı',
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final currentText = value.text.trim();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.place_outlined,
                  size: 15,
                  color: AppTheme.muted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Hızlı Kampüs Noktaları',
                    style: AppTheme.meta.copyWith(fontSize: 12),
                  ),
                ),
                if (currentText.isNotEmpty && enabled)
                  InkWell(
                    borderRadius: BorderRadius.circular(AppTheme.badgeRadius),
                    onTap: controller.clear,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      child: Text(
                        'Yeri Temizle',
                        style: AppTheme.label.copyWith(
                          color: AppTheme.primaryDark,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: presets.map((place) {
                final isSelected =
                    currentText.toLowerCase() == place.toLowerCase();
                return ChoiceChip(
                  label: Text(
                    place,
                    style: AppTheme.meta.copyWith(
                      fontSize: 12,
                      color: isSelected ? AppTheme.surface : AppTheme.inkSoft,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppTheme.ink,
                  backgroundColor: AppTheme.surface,
                  checkmarkColor: AppTheme.surface,
                  side: BorderSide(
                    color: isSelected ? AppTheme.ink : AppTheme.lineStrong,
                  ),
                  visualDensity: VisualDensity.compact,
                  onSelected: !enabled
                      ? null
                      : (_) {
                          controller.value = TextEditingValue(
                            text: place,
                            selection: TextSelection.collapsed(
                              offset: place.length,
                            ),
                          );
                        },
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
