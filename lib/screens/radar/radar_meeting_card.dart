import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';

class RadarMeetingCard extends StatelessWidget {
  const RadarMeetingCard({
    super.key,
    required this.listing,
    required this.category,
    required this.onOpen,
    required this.onParticipation,
  });

  final Ilan listing;
  final String category;
  final VoidCallback onOpen;
  final VoidCallback? onParticipation;

  @override
  Widget build(BuildContext context) {
    final date = listing.bulusmaTarihi?.toLocal();
    final now = DateTime.now();
    final time = date == null
        ? ''
        : DateUtils.isSameDay(date, now)
        ? 'Bugün ${DateFormat('HH:mm').format(date)}'
        : DateUtils.isSameDay(date, DateUtils.addDaysToDate(now, 1))
        ? 'Yarın ${DateFormat('HH:mm').format(date)}'
        : DateFormat('dd.MM.yyyy · HH:mm').format(date);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.cardInset),
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                constraints: const BoxConstraints(minHeight: 28),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTint,
                  borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 6,
                  children: [
                    Icon(
                      _categoryIcon(category),
                      size: 14,
                      color: AppTheme.primaryDark,
                    ),
                    Flexible(
                      child: Text(
                        category,
                        style: AppTheme.label.copyWith(
                          color: AppTheme.primaryDark,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(listing.baslik, style: AppTheme.cardTitle),
              Column(
                spacing: 4,
                children: [
                  if (time.isNotEmpty)
                    _MeetingMeta(icon: Icons.schedule_outlined, text: time),
                  if (listing.yer.trim().isNotEmpty)
                    _MeetingMeta(
                      icon: Icons.location_on_outlined,
                      text: listing.yer,
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  spacing: 12,
                  children: [
                    Expanded(
                      child: Row(
                        spacing: 8,
                        children: [
                          if (listing.katilimciSayisi > 0)
                            const CircleAvatar(
                              radius: 15,
                              backgroundColor: AppTheme.primaryTint2,
                              foregroundColor: AppTheme.primaryDark,
                              child: Icon(
                                Icons.people_outline_rounded,
                                size: 16,
                              ),
                            ),
                          Flexible(
                            child: Text(
                              '${listing.katilimciSayisi} kişi',
                              style: AppTheme.meta.copyWith(
                                color: AppTheme.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppButton(
                      label: listing.katiliyor ? 'Katıldın' : 'Katıl',
                      icon: listing.katiliyor ? Icons.check : null,
                      onPressed: onParticipation,
                      fullWidth: false,
                      horizontalPadding: 22,
                      variant: listing.katiliyor
                          ? AppButtonVariant.joined
                          : AppButtonVariant.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    final label = category.toLowerCase();
    if (label.contains('kahve')) return Icons.coffee_outlined;
    if (label.contains('ders') || label.contains('çalışma')) {
      return Icons.menu_book_outlined;
    }
    if (label.contains('spor')) return Icons.sports_basketball_outlined;
    if (label.contains('yemek')) return Icons.restaurant_outlined;
    return Icons.event_outlined;
  }
}

class _MeetingMeta extends StatelessWidget {
  const _MeetingMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    spacing: 6,
    children: [
      Icon(icon, size: 14, color: AppTheme.muted),
      Expanded(
        child: Text(
          text,
          style: AppTheme.body.copyWith(
            fontSize: 13,
            height: 1.25,
            color: AppTheme.muted,
          ),
        ),
      ),
    ],
  );
}
