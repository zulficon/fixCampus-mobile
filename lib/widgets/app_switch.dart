import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppSwitch extends StatelessWidget {
  const AppSwitch({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final bool value;
  final String label;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final action = onChanged;
    const duration = Duration(milliseconds: 150);

    return Semantics(
      label: label,
      toggled: value,
      enabled: action != null,
      child: InkWell(
        onTap: action == null ? null : () => action(!value),
        borderRadius: BorderRadius.circular(AppTheme.pillRadius),
        child: SizedBox(
          width: 52,
          height: AppTheme.tapSize,
          child: Center(
            child: AnimatedContainer(
              duration: duration,
              width: 52,
              height: 32,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: value ? AppTheme.primary : AppTheme.switchOff,
                borderRadius: BorderRadius.circular(AppTheme.pillRadius),
              ),
              child: AnimatedAlign(
                duration: duration,
                alignment: value
                    ? AlignmentDirectional.centerEnd
                    : AlignmentDirectional.centerStart,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppTheme.surface,
                    shape: BoxShape.circle,
                    boxShadow: [AppTheme.switchThumbShadow],
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
