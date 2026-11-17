import 'package:flutter/material.dart';

class AppTheme {
  static const ink = Color(0xFF12142B);
  static const inkSoft = Color(0xFF3A3F58);
  static const muted = Color(0xFF5B6078);
  static const placeholder = Color(0xFF6A6F86);
  static const bg = Color(0xFFF3F5FA);
  static const surface = Color(0xFFFFFFFF);
  static const line = Color(0xFFE3E6EF);
  static const lineStrong = Color(0xFFD5D9E6);
  static const segmentBg = Color(0xFFE4E7F0);
  static const primary = Color(0xFF3B4FE0);
  static const primaryDark = Color(0xFF2A3BB8);
  static const primaryTint = Color(0xFFE8EBFF);
  static const primaryTint2 = Color(0xFFD7DDFF);
  static const lost = Color(0xFFFF7A2F);
  static const lostDark = Color(0xFFA8400A);
  static const lostTint = Color(0xFFFFE9DB);
  static const lostTint2 = Color(0xFFFFEFE3);
  static const found = Color(0xFF1C7D4D);
  static const foundDark = Color(0xFF146B41);
  static const foundTint = Color(0xFFE1F4EA);
  static const inactiveBg = Color(0xFFECEEF3);
  static const inactiveText = Color(0xFF4A4F68);
  static const switchOff = Color(0xFFC9CDDB);
  static const avatarPastels = [
    Color(0xFFFFD9C2),
    primaryTint2,
    Color(0xFFCFEFDF),
    Color(0xFFFFE7A8),
  ];

  static const primaryBlack = ink;
  static const darkBg = Color(0xFF09090B);
  static const darkSurface = Color(0xFF18181B);
  static const darkBorder = Color(0xFF27272A);

  static const bodyFont = 'Inter';
  static const headingFont = 'Bricolage Grotesque';

  static const display = TextStyle(
    fontVariations: [FontVariation('wght', 800), FontVariation('opsz', 30)],
    fontFamily: headingFont,
    fontSize: 30,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -0.6,
    color: ink,
  );
  static const logo = TextStyle(
    fontVariations: [FontVariation('wght', 800), FontVariation('opsz', 26)],
    fontFamily: headingFont,
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: ink,
  );
  static const heroTitle = TextStyle(
    fontVariations: [FontVariation('wght', 800), FontVariation('opsz', 26)],
    fontFamily: headingFont,
    fontSize: 26,
    fontWeight: FontWeight.w800,
    height: 1.15,
    letterSpacing: -0.4,
    color: surface,
  );
  static const section = TextStyle(
    fontVariations: [FontVariation('wght', 800), FontVariation('opsz', 20)],
    fontFamily: headingFont,
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: ink,
  );
  static const cardTitle = TextStyle(
    fontVariations: [FontVariation('wght', 700), FontVariation('opsz', 18)],
    fontFamily: headingFont,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: ink,
  );
  static const statNumber = TextStyle(
    fontVariations: [FontVariation('wght', 800), FontVariation('opsz', 22)],
    fontFamily: headingFont,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    height: 1,
    color: ink,
  );
  static const body = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: ink,
  );
  static const bodyStrong = TextStyle(
    fontVariations: [FontVariation('wght', 700)],
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: ink,
  );
  static const meta = TextStyle(
    fontVariations: [FontVariation('wght', 600)],
    fontFamily: bodyFont,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: muted,
  );
  static const label = TextStyle(
    fontVariations: [FontVariation('wght', 700)],
    fontFamily: bodyFont,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: ink,
  );

  static const fieldText = TextStyle(
    fontFamily: bodyFont,
    color: ink,
    fontSize: 15,
  );
  static const adminLabel = TextStyle(
    fontFamily: bodyFont,
    fontVariations: [FontVariation('wght', 700)],
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: surface,
  );

  static const pillRadius = 999.0;
  static const badgeRadius = 8.0;
  static const iconRadius = 12.0;
  static const controlRadius = 14.0;
  static const largeControlRadius = 16.0;
  static const smallCardRadius = 18.0;
  static const gridCardRadius = 20.0;
  static const cardRadius = 22.0;
  static const bannerRadius = 24.0;
  static const navigationRadius = 26.0;
  static const radarRadius = 28.0;
  static const tapSize = 44.0;
  static const largeButtonHeight = 52.0;
  static const fieldHeight = 50.0;
  static const pageInset = 20.0;
  static const safeTopGap = 12.0;
  static const sectionGap = 16.0;
  static const listGap = 12.0;
  static const cardInset = 16.0;
  static const navigationHeight = 76.0;
  static const navigationSideInset = 12.0;
  static const navigationBottomInset = 14.0;
  static const overlaidNavigationClearance = 120.0;

  static const navigationShadow = BoxShadow(
    color: Color(0x1A12142B),
    offset: Offset(0, 10),
    blurRadius: 30,
  );
  static const segmentShadow = BoxShadow(
    color: Color(0x1A12142B),
    offset: Offset(0, 2),
    blurRadius: 8,
  );
  static const switchThumbShadow = BoxShadow(
    color: Color(0x33000000),
    offset: Offset(0, 1),
    blurRadius: 3,
  );

  static const fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(controlRadius)),
    borderSide: BorderSide(color: lineStrong),
  );
  static const searchBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(largeControlRadius)),
    borderSide: BorderSide(color: line),
  );

  static ButtonStyle buttonStyle({
    Color? backgroundColor,
    Color? foregroundColor,
    bool outlined = false,
    bool large = false,
    double? horizontalPadding,
  }) {
    final height = large ? largeButtonHeight : tapSize;
    final radius = large ? largeControlRadius : controlRadius;
    final foreground = foregroundColor ?? (outlined ? ink : surface);
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? (outlined ? surface : primary),
      foregroundColor: foreground,
      disabledBackgroundColor: segmentBg,
      disabledForegroundColor: placeholder,
      elevation: 0,
      minimumSize: Size(tapSize, height),
      tapTargetSize: MaterialTapTargetSize.padded,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding ?? (large ? 24 : 18),
        vertical: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      side: outlined ? BorderSide(color: foreground, width: 1.5) : null,
      textStyle: bodyStrong.copyWith(fontSize: large ? 15 : 14),
    ).copyWith(
      side: outlined
          ? WidgetStateProperty.resolveWith(
              (states) => BorderSide(
                color: states.contains(WidgetState.disabled)
                    ? lineStrong
                    : foreground,
                width: 1.5,
              ),
            )
          : null,
    );
  }

  static ThemeData get lightTheme {
    final theme = ThemeData(
      useMaterial3: true,
      fontFamily: bodyFont,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: ink,
        surface: surface,
        onPrimary: surface,
        onSecondary: surface,
        onSurface: ink,
        onSurfaceVariant: muted,
        outline: lineStrong,
        outlineVariant: line,
        primaryContainer: primaryTint,
        onPrimaryContainer: primaryDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: cardTitle,
      ),
      cardTheme: const CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(cardRadius)),
          side: BorderSide(color: line),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: buttonStyle()),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: buttonStyle(outlined: true),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        constraints: const BoxConstraints(minHeight: fieldHeight),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: fieldBorder,
        enabledBorder: fieldBorder,
        focusedBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        labelStyle: bodyStrong.copyWith(fontSize: 13, color: muted),
        hintStyle: body.copyWith(fontSize: 15, color: placeholder),
      ),
      dividerTheme: const DividerThemeData(color: line, thickness: 1, space: 1),
    );
    return theme.copyWith(
      textTheme: theme.textTheme.copyWith(
        displaySmall: display,
        headlineSmall: section,
        titleMedium: cardTitle,
        bodyLarge: fieldText,
        bodyMedium: body,
        bodySmall: body.copyWith(fontSize: 12, color: muted, height: 1.35),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        secondary: Color(0xFFA1A1AA),
        surface: darkSurface,
        onPrimary: Colors.black,
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
    );
  }
}
