import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _labels = ['Radar', 'Kayıp-Buluntu', 'İlan Ver', 'Profil'];

  @override
  Widget build(BuildContext context) {
    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(AppTheme.navigationRadius),
      ),
      side: BorderSide(color: AppTheme.line),
    );

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(
        left: AppTheme.navigationSideInset,
        right: AppTheme.navigationSideInset,
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.navigationBottomInset),
        child: Container(
          decoration: const ShapeDecoration(
            shape: shape,
            shadows: [AppTheme.navigationShadow],
          ),
          child: Material(
            color: AppTheme.surface,
            shape: shape,
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppTheme.navigationHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    for (var index = 0; index < _labels.length; index++)
                      Expanded(child: _destination(index)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _destination(int index) {
    final selected = selectedIndex == index;
    final isCreate = index == 2;
    final isLost = index == 1;
    final labelColor = switch ((isCreate, selected, isLost)) {
      (true, _, _) => AppTheme.ink,
      (_, false, _) => AppTheme.muted,
      (_, _, true) => AppTheme.lostDark,
      _ => AppTheme.primary,
    };
    final iconBackground = switch ((isCreate, selected, isLost)) {
      (true, true, _) => AppTheme.primary,
      (true, false, _) => AppTheme.ink,
      (_, false, _) => Colors.transparent,
      (_, _, true) => AppTheme.lostTint,
      _ => AppTheme.primaryTint,
    };

    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: () => onSelected(index),
        borderRadius: BorderRadius.circular(AppTheme.iconRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(AppTheme.iconRadius),
                  boxShadow: [
                    if (isCreate && selected)
                      const BoxShadow(
                        color: AppTheme.primaryTint2,
                        spreadRadius: 3,
                      ),
                  ],
                ),
                child: CustomPaint(
                  size: const Size.square(22),
                  painter: _TabIcon(
                    index,
                    isCreate ? AppTheme.surface : labelColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _labels[index],
                textAlign: TextAlign.center,
                style: selected || isCreate
                    ? AppTheme.label.copyWith(color: labelColor)
                    : AppTheme.meta.copyWith(
                        color: labelColor,
                        fontSize: 11,
                        height: 1,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabIcon extends CustomPainter {
  const _TabIcon(this.index, this.color);

  final int index;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = index == 2 ? 2.4 : 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (index) {
      case 0:
        const center = Offset(12, 12);
        canvas.drawCircle(center, 9, stroke);
        canvas.drawCircle(center, 5, stroke);
        canvas.drawLine(center, const Offset(18, 6), stroke);
      case 1:
        canvas.drawCircle(const Offset(11, 11), 7, stroke);
        canvas.drawLine(const Offset(20, 20), const Offset(16, 16), stroke);
        final question = Path()
          ..moveTo(9.3, 9.2)
          ..arcToPoint(
            const Offset(11.9, 10.9),
            radius: const Radius.circular(1.9),
            largeArc: true,
          )
          ..relativeCubicTo(-0.6, 0.3, -0.9, 0.6, -0.9, 1.3)
          ..moveTo(11, 14.6)
          ..relativeLineTo(0.01, 0);
        canvas.drawPath(question, stroke);
      case 2:
        canvas.drawLine(const Offset(12, 5), const Offset(12, 19), stroke);
        canvas.drawLine(const Offset(5, 12), const Offset(19, 12), stroke);
      case 3:
        canvas.drawCircle(const Offset(12, 8), 4, stroke);
        final shoulders = Path()
          ..moveTo(4, 21)
          ..cubicTo(4, 17, 7.6, 14, 12, 14)
          ..cubicTo(16.4, 14, 20, 17, 20, 21);
        canvas.drawPath(shoulders, stroke);
    }
  }

  @override
  bool shouldRepaint(_TabIcon oldDelegate) =>
      oldDelegate.index != index || oldDelegate.color != color;
}
