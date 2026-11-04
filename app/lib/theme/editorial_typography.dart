import 'package:flutter/material.dart';
import 'editorial_colors.dart';

/// Typography hierarchy scale bound directly to EditorialColors
class EditorialTypography {
  static const String fontSerif = 'Merriweather';
  static const String fontSans = 'PlusJakartaSans';
  static const String fontMono = 'JetBrainsMono';

  final TextStyle display;
  final TextStyle headline;
  final TextStyle titleLg;
  final TextStyle titleMd;
  final TextStyle bodyLg;
  final TextStyle bodyMd;
  final TextStyle labelMd;
  final TextStyle caption;
  final TextStyle codeSm;

  const EditorialTypography({
    required this.display,
    required this.headline,
    required this.titleLg,
    required this.titleMd,
    required this.bodyLg,
    required this.bodyMd,
    required this.labelMd,
    required this.caption,
    required this.codeSm,
  });

  factory EditorialTypography.fromColors(EditorialColors colors) {
    return EditorialTypography(
      display: TextStyle(
        fontFamily: fontSerif,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.20,
        letterSpacing: -0.5,
        color: colors.textPrimary,
      ),
      headline: TextStyle(
        fontFamily: fontSerif,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.3,
        color: colors.textPrimary,
      ),
      titleLg: TextStyle(
        fontFamily: fontSerif,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.30,
        letterSpacing: -0.2,
        color: colors.textPrimary,
      ),
      titleMd: TextStyle(
        fontFamily: fontSans,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: colors.textPrimary,
      ),
      bodyLg: TextStyle(
        fontFamily: fontSans,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.50,
        color: colors.textPrimary,
      ),
      bodyMd: TextStyle(
        fontFamily: fontSans,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: colors.textPrimary,
      ),
      labelMd: TextStyle(
        fontFamily: fontSans,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.30,
        letterSpacing: 0.1,
        color: colors.textSecondary,
      ),
      caption: TextStyle(
        fontFamily: fontSans,
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.25,
        letterSpacing: 0.1,
        color: colors.textTertiary,
      ),
      codeSm: TextStyle(
        fontFamily: fontMono,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.50,
        color: colors.codeText,
      ),
    );
  }
}
