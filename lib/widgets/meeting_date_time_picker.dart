import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

/// Sosyal buluşma ilanları için ayrı tarih seçici, ayrı saat seçici,
/// hızlı zaman çipleri ve birleşik buluşma zamanı özeti sunan bileşen.
class MeetingDateTimePicker extends StatelessWidget {
  const MeetingDateTimePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.nowProvider,
  });

  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final bool enabled;
  final DateTime Function()? nowProvider;

  DateTime _now() => nowProvider != null ? nowProvider!() : DateTime.now();

  DateTime _defaultFutureTimeForDate(DateTime date, DateTime now) {
    if (!DateUtils.isSameDay(date, now)) {
      final plusTwo = now.add(const Duration(hours: 2));
      return DateTime(
        date.year,
        date.month,
        date.day,
        plusTwo.hour,
        plusTwo.minute,
      );
    }
    final endOfToday = DateTime(date.year, date.month, date.day, 23, 59);
    final plusTwo = now.add(const Duration(hours: 2));
    if (DateUtils.isSameDay(plusTwo, date)) {
      return plusTwo;
    }
    final plusFifteen = now.add(const Duration(minutes: 15));
    return plusFifteen.isBefore(endOfToday) ? plusFifteen : endOfToday;
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = _now();
    final first = DateTime(now.year, now.month, now.day);
    final last = DateTime(now.year + 5, 12, 31);
    final current = value;
    final initial =
        current != null && !current.isBefore(first) && !current.isAfter(last)
        ? current
        : now;

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
    if (!context.mounted || date == null) return;

    if (current != null) {
      onChanged(
        DateTime(
          date.year,
          date.month,
          date.day,
          current.hour,
          current.minute,
        ),
      );
      return;
    }

    onChanged(_defaultFutureTimeForDate(date, now));
  }

  Future<void> _pickTime(BuildContext context) async {
    final now = _now();
    final current = value;
    final initialTime = current != null
        ? TimeOfDay.fromDateTime(current)
        : TimeOfDay.fromDateTime(now.add(const Duration(hours: 2)));

    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (!context.mounted || time == null) return;

    final baseDate = current ?? now;
    var candidate = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      time.hour,
      time.minute,
    );
    // Kullanıcı henüz tarih seçmeden yalnızca saat seçtiyse ve seçilen saat
    // bugünün geçmişinde kalıyorsa bir sonraki güne taşı.
    if (current == null && !candidate.isAfter(now)) {
      final tomorrow = now.add(const Duration(days: 1));
      candidate = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        time.hour,
        time.minute,
      );
    }
    onChanged(candidate);
  }

  void _applyPreset(DateTime target) {
    if (!enabled) return;
    onChanged(target);
  }

  @override
  Widget build(BuildContext context) {
    final now = _now();
    final tomorrow = now.add(const Duration(days: 1));
    final plusTwoHours = now.add(const Duration(hours: 2));
    final roundedPlusTwo = DateTime(
      plusTwoHours.year,
      plusTwoHours.month,
      plusTwoHours.day,
      plusTwoHours.hour,
      (plusTwoHours.minute ~/ 15) * 15,
    );
    final tomorrowNoon = DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      12,
      0,
    );
    final tomorrowAfternoon = DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      15,
      0,
    );

    final dateText = value != null
        ? DateFormat('dd.MM.yyyy').format(value!)
        : 'Tarih Seç';
    final timeText = value != null
        ? DateFormat('HH:mm').format(value!)
        : 'Saat Seç';

    final pickerButtonStyle = OutlinedButton.styleFrom(
      backgroundColor: AppTheme.surface,
      foregroundColor: AppTheme.ink,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      side: const BorderSide(color: AppTheme.lineStrong),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.controlRadius),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.smallCardRadius),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.event_available_outlined,
                size: 18,
                color: AppTheme.ink,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Buluşma Tarihi ve Saati',
                  style: AppTheme.bodyStrong.copyWith(fontSize: 13),
                ),
              ),
              if (value != null && enabled)
                InkWell(
                  borderRadius: BorderRadius.circular(AppTheme.badgeRadius),
                  onTap: () => onChanged(null),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    child: Text(
                      'Zamanı Sıfırla',
                      style: AppTheme.label.copyWith(color: AppTheme.lostDark),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const ValueKey('meeting_date_button'),
                  onPressed: enabled ? () => _pickDate(context) : null,
                  icon: const Icon(Icons.calendar_today_outlined, size: 16),
                  style: pickerButtonStyle,
                  label: Text(
                    dateText,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.bodyStrong.copyWith(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  key: const ValueKey('meeting_time_button'),
                  onPressed: enabled ? () => _pickTime(context) : null,
                  icon: const Icon(Icons.access_time_outlined, size: 16),
                  style: pickerButtonStyle,
                  label: Text(
                    timeText,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.bodyStrong.copyWith(fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                backgroundColor: AppTheme.primaryTint,
                side: BorderSide.none,
                label: Text(
                  '+2 Saat Sonra',
                  style: AppTheme.label.copyWith(color: AppTheme.primaryDark),
                ),
                visualDensity: VisualDensity.compact,
                onPressed: enabled ? () => _applyPreset(roundedPlusTwo) : null,
              ),
              ActionChip(
                backgroundColor: AppTheme.primaryTint,
                side: BorderSide.none,
                label: Text(
                  'Yarın 12:00',
                  style: AppTheme.label.copyWith(color: AppTheme.primaryDark),
                ),
                visualDensity: VisualDensity.compact,
                onPressed: enabled ? () => _applyPreset(tomorrowNoon) : null,
              ),
              ActionChip(
                backgroundColor: AppTheme.primaryTint,
                side: BorderSide.none,
                label: Text(
                  'Yarın 15:00',
                  style: AppTheme.label.copyWith(color: AppTheme.primaryDark),
                ),
                visualDensity: VisualDensity.compact,
                onPressed: enabled
                    ? () => _applyPreset(tomorrowAfternoon)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: value != null ? AppTheme.foundTint : AppTheme.bg,
              borderRadius: BorderRadius.circular(AppTheme.controlRadius),
              border: Border.all(
                color: value != null
                    ? AppTheme.found.withValues(alpha: 0.35)
                    : AppTheme.line,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  value != null ? Icons.check_circle_outline : Icons.schedule,
                  size: 16,
                  color: value != null ? AppTheme.foundDark : AppTheme.muted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value == null
                        ? 'Buluşma tarihi ve saati seçin'
                        : DateFormat('dd.MM.yyyy HH:mm').format(value!),
                    style: AppTheme.meta.copyWith(
                      fontSize: 12,
                      color: value != null
                          ? AppTheme.foundDark
                          : AppTheme.inkSoft,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
