import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final height = compact ? 36.0 : 40.0;
    final color = isSelected ? AppTheme.ink : AppTheme.surface;
    final shape = StadiumBorder(
      side: BorderSide(
        color: isSelected ? AppTheme.ink : AppTheme.line,
        width: 1.5,
      ),
    );

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Semantics(
        selected: isSelected,
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Center(
            child: Ink(
              height: height,
              decoration: ShapeDecoration(color: color, shape: shape),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 16),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    label,
                    style: AppTheme.meta.copyWith(
                      fontSize: compact ? 13 : 14,
                      color: isSelected ? AppTheme.surface : AppTheme.ink,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
