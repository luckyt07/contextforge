import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography hierarchy scale from DESIGN.md
/// Configured with clean fallbacks so that if custom fonts (Merriweather, Plus Jakarta Sans/Inter, JetBrains Mono)
/// are added later to pubspec.yaml, they slot right in seamlessly.
class AppTypography {
  AppTypography._();

  // Font family constants mapped to pubspec.yaml declarations
  static const String fontSerif = 'Merriweather';
  static const String fontSans = 'PlusJakartaSans';
  static const String fontMono = 'JetBrainsMono';

  static TextStyle display(bool isDark) => TextStyle(
    fontFamily: fontSerif,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.20,
    letterSpacing: -0.5,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
  );

  static TextStyle headline(bool isDark) => TextStyle(
    fontFamily: fontSerif,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.3,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
  );

  static TextStyle titleLg(bool isDark) => TextStyle(
    fontFamily: fontSerif,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.30,
    letterSpacing: -0.2,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
  );

  static TextStyle titleMd(bool isDark) => TextStyle(
    fontFamily: fontSans,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
  );

  static TextStyle bodyLg(bool isDark) => TextStyle(
    fontFamily: fontSans,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.50,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
  );

  static TextStyle bodyMd(bool isDark) => TextStyle(
    fontFamily: fontSans,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
  );

  static TextStyle labelMd(bool isDark) => TextStyle(
    fontFamily: fontSans,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.30,
    letterSpacing: 0.1,
    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
  );

  static TextStyle caption(bool isDark) => TextStyle(
    fontFamily: fontSans,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.25,
    letterSpacing: 0.1,
    color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
  );

  static TextStyle codeSm(bool isDark) => TextStyle(
    fontFamily: fontMono,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.50,
    color: isDark ? AppColors.codeTextDark : AppColors.codeTextLight,
  );
}
