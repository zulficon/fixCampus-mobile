import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/sticker_slot.dart';

class RadarSummary extends StatefulWidget {
  const RadarSummary({
    super.key,
    required this.meetings,
    required this.lostItems,
  });

  final int? meetings;
  final int? lostItems;

  @override
  State<RadarSummary> createState() => _RadarSummaryState();
}

class _RadarSummaryState extends State<RadarSummary>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _sweep.stop();
    } else if (!_sweep.isAnimating) {
      _sweep.repeat();
    }
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const pigeon = CampusSticker.pigeon;
    final scale = MediaQuery.textScalerOf(context).scale(13) / 13;
    return LayoutBuilder(
      builder: (context, constraints) {
        final diameter = math.min(196.0, constraints.maxWidth * .56);
        final height = math.max(196.0, 108 * scale + 88);
        return Container(
          height: height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppTheme.primaryTint,
            borderRadius: BorderRadius.circular(AppTheme.radarRadius),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 14,
                top: (height - diameter) / 2,
                child: RepaintBoundary(
                  child: CustomPaint(
                    size: Size.square(diameter),
                    painter: _RadarPainter(
                      _sweep,
                      widget.meetings ?? 0,
                      (widget.lostItems ?? 0) > 0,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: diameter + 22,
                top: 22,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      'Kampüs genelinde',
                      style: AppTheme.meta.copyWith(fontSize: 12),
                    ),
                    Text(
                      widget.meetings?.toString() ?? '—',
                      style: AppTheme.statNumber.copyWith(
                        fontSize: 34,
                        fontVariations: const [
                          FontVariation('wght', 800),
                          FontVariation('opsz', 34),
                        ],
                      ),
                    ),
                    Text(
                      'aktif buluşma',
                      style: AppTheme.meta.copyWith(color: AppTheme.ink),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.lost,
                          ),
                          child: SizedBox.square(dimension: 8),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            widget.lostItems == null
                                ? 'Kayıp eşya'
                                : '${widget.lostItems} kayıp eşya',
                            style: AppTheme.meta.copyWith(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                right: pigeon.right,
                bottom: pigeon.bottom,
                child: const StickerSlot(sticker: pigeon),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter(this.progress, this.meetings, this.hasLost)
    : super(repaint: progress);

  final Animation<double> progress;
  final int meetings;
  final bool hasLost;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 196);
    const center = Offset(98, 98);
    for (final (radius, opacity) in [
      (97.25, .18),
      (67.25, .24),
      (35.25, .32),
    ]) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = AppTheme.primary.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    const angle = math.pi * 70 / 180;
    final start = -math.pi / 2 + progress.value * 2 * math.pi;
    final bounds = Rect.fromCircle(center: center, radius: 98);
    final sweep = SweepGradient(
      endAngle: angle,
      colors: [AppTheme.primary.withValues(alpha: .22), Colors.transparent],
      transform: GradientRotation(start),
    );
    canvas.drawArc(
      bounds,
      start,
      angle,
      true,
      Paint()..shader = sweep.createShader(bounds),
    );

    final pulse = (progress.value * 2) % 1;
    canvas.drawCircle(
      center,
      10 + pulse * 7,
      Paint()..color = AppTheme.ink.withValues(alpha: .25 * (1 - pulse)),
    );
    _point(canvas, center, AppTheme.ink);

    const locations = [Offset(139, 53), Offset(51, 77), Offset(157, 135)];
    for (final location in locations.take(meetings)) {
      _point(canvas, location, AppTheme.primary);
    }
    if (hasLost) _point(canvas, const Offset(77, 157), AppTheme.lost);
    if (meetings > locations.length) {
      canvas.drawCircle(
        const Offset(27, 125),
        5,
        Paint()..color = AppTheme.primary.withValues(alpha: .6),
      );
    }
  }

  void _point(Canvas canvas, Offset position, Color color) {
    canvas.drawCircle(position, 7, Paint()..color = AppTheme.surface);
    canvas.drawCircle(position, 5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_RadarPainter oldDelegate) =>
      oldDelegate.meetings != meetings || oldDelegate.hasLost != hasLost;
}
