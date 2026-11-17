import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AvatarStack extends StatelessWidget {
  const AvatarStack({
    super.key,
    required this.initials,
    this.compact = false,
    this.currentUserIndex,
  });

  final List<String> initials;
  final bool compact;
  final int? currentUserIndex;

  @override
  Widget build(BuildContext context) {
    if (initials.isEmpty) return const SizedBox.shrink();

    final diameter = compact ? 30.0 : 32.0;
    final step = diameter - 8;
    return SizedBox(
      width: step * (initials.length - 1) + diameter,
      height: diameter,
      child: Stack(
        children: [
          for (final (index, text) in initials.indexed)
            PositionedDirectional(
              start: step * index,
              child: Container(
                width: diameter,
                height: diameter,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: index == currentUserIndex
                      ? AppTheme.ink
                      : AppTheme.avatarPastels[index %
                            AppTheme.avatarPastels.length],
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.surface, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      text,
                      style: AppTheme.label.copyWith(
                        color: index == currentUserIndex
                            ? AppTheme.surface
                            : AppTheme.ink,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
