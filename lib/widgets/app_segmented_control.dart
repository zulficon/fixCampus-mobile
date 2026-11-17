import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppSegmentedControl extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.segmentBg,
        borderRadius: BorderRadius.circular(AppTheme.largeControlRadius),
      ),
      child: Row(
        spacing: 4,
        children: [
          for (final (index, label) in labels.indexed)
            Expanded(
              child: Semantics(
                selected: index == selectedIndex,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.iconRadius),
                    boxShadow: [
                      if (index == selectedIndex) AppTheme.segmentShadow,
                    ],
                  ),
                  child: TextButton(
                    onPressed: () => onSelected(index),
                    style: TextButton.styleFrom(
                      backgroundColor: index == selectedIndex
                          ? AppTheme.surface
                          : Colors.transparent,
                      foregroundColor: index == selectedIndex
                          ? AppTheme.ink
                          : AppTheme.muted,
                      minimumSize: const Size.square(AppTheme.tapSize),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.iconRadius,
                        ),
                      ),
                      textStyle: AppTheme.bodyStrong,
                    ),
                    child: Text(label, textAlign: TextAlign.center),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
