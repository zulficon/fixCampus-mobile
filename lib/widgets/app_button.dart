import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum AppButtonVariant { primary, create, lost, found, secondary, joined }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.foregroundColor,
    this.fullWidth = true,
    this.variant = AppButtonVariant.primary,
    this.large = false,
    this.horizontalPadding,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool fullWidth;
  final AppButtonVariant variant;
  final bool large;
  final double? horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final effectiveVariant = isOutlined ? AppButtonVariant.secondary : variant;
    final (background, foreground) = switch (effectiveVariant) {
      AppButtonVariant.primary => (AppTheme.primary, AppTheme.surface),
      AppButtonVariant.create => (AppTheme.ink, AppTheme.surface),
      AppButtonVariant.lost => (AppTheme.lost, AppTheme.ink),
      AppButtonVariant.found => (AppTheme.found, AppTheme.surface),
      AppButtonVariant.secondary => (AppTheme.surface, AppTheme.ink),
      AppButtonVariant.joined => (AppTheme.primaryTint, AppTheme.primaryDark),
    };
    final outlined = effectiveVariant == AppButtonVariant.secondary;
    final style = AppTheme.buttonStyle(
      backgroundColor: backgroundColor ?? background,
      foregroundColor: foregroundColor ?? foreground,
      outlined: outlined,
      large: large,
      horizontalPadding: horizontalPadding,
    );
    final Widget child;
    if (isLoading) {
      child = SizedBox.square(
        dimension: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppTheme.placeholder,
          semanticsLabel: label,
        ),
      );
    } else if (icon case final icon?) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Flexible(child: Text(label, textAlign: TextAlign.center)),
        ],
      );
    } else {
      child = Text(label, textAlign: TextAlign.center);
    }

    final action = isLoading ? null : onPressed;
    final button = outlined
        ? OutlinedButton(onPressed: action, style: style, child: child)
        : ElevatedButton(onPressed: action, style: style, child: child);
    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
