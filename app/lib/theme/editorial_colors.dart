import 'package:flutter/material.dart';

/// Semantic colors token model based on DESIGN.md
class EditorialColors {
  // Brand
  final Color brandPrimary;
  final Color brandPrimaryHover;
  final Color brandPrimaryContainer;
  final Color brandOnPrimary;
  final Color brandOnPrimaryContainer;

  // Surfaces & Canvas
  final Color canvas;
  final Color card;
  final Color surfaceSubdued;
  final Color containerLow;
  final Color containerHigh;

  // Borders & Strokes
  final Color borderDefault;
  final Color borderSubtle;
  final Color borderFocus;

  // Text & Iconography
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;

  // Code & Technical Elements
  final Color codeBackground;
  final Color codeBorder;
  final Color codeText;

  // Status
  final Color error;
  final Color errorContainer;

  final bool isDark;

  const EditorialColors({
    required this.brandPrimary,
    required this.brandPrimaryHover,
    required this.brandPrimaryContainer,
    required this.brandOnPrimary,
    required this.brandOnPrimaryContainer,
    required this.canvas,
    required this.card,
    required this.surfaceSubdued,
    required this.containerLow,
    required this.containerHigh,
    required this.borderDefault,
    required this.borderSubtle,
    required this.borderFocus,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.codeBackground,
    required this.codeBorder,
    required this.codeText,
    required this.error,
    required this.errorContainer,
    required this.isDark,
  });

  factory EditorialColors.light() {
    return const EditorialColors(
      brandPrimary: Color(0xFFC15F3C),
      brandPrimaryHover: Color(0xFF994121),
      brandPrimaryContainer: Color(0xFFFCECE6),
      brandOnPrimary: Color(0xFFFFFFFF),
      brandOnPrimaryContainer: Color(0xFF712F18),
      canvas: Color(0xFFFFF8F5),
      card: Color(0xFFFFFFFF),
      surfaceSubdued: Color(0xFFFBF2ED),
      containerLow: Color(0xFFF8F1EB),
      containerHigh: Color(0xFFEFE6E2),
      borderDefault: Color(0xFFE1D8D4),
      borderSubtle: Color(0xFFEFE8E4),
      borderFocus: Color(0xFFC15F3C),
      textPrimary: Color(0xFF2C2523),
      textSecondary: Color(0xFF796E69),
      textTertiary: Color(0xFFADA29D),
      textDisabled: Color(0xFFC5BBB6),
      codeBackground: Color(0xFFF8F5F2),
      codeBorder: Color(0xFFE8E2DD),
      codeText: Color(0xFF3A312E),
      error: Color(0xFFBA1A1A),
      errorContainer: Color(0xFFFFDAD6),
      isDark: false,
    );
  }

  factory EditorialColors.dark() {
    return const EditorialColors(
      brandPrimary: Color(0xFFC15F3C),
      brandPrimaryHover: Color(0xFF994121),
      brandPrimaryContainer: Color(0xFF432418),
      brandOnPrimary: Color(0xFFFFFFFF),
      brandOnPrimaryContainer: Color(0xFFFFDBCE),
      canvas: Color(0xFF1A1715),
      card: Color(0xFF24201D),
      surfaceSubdued: Color(0xFF2B2623),
      containerLow: Color(0xFF201D1A),
      containerHigh: Color(0xFF332E2A),
      borderDefault: Color(0xFF3D3632),
      borderSubtle: Color(0xFF302A27),
      borderFocus: Color(0xFFE07A58),
      textPrimary: Color(0xFFF5EFEB),
      textSecondary: Color(0xFFA89F9A),
      textTertiary: Color(0xFF6E6560),
      textDisabled: Color(0xFF524C48),
      codeBackground: Color(0xFF1E1B19),
      codeBorder: Color(0xFF332E2A),
      codeText: Color(0xFFEBE4DF),
      error: Color(0xFFBA1A1A),
      errorContainer: Color(0xFFFFDAD6),
      isDark: true,
    );
  }

  /// Linearly interpolates between two EditorialColors instances for silky smooth theme changes.
  static EditorialColors lerp(EditorialColors a, EditorialColors b, double t) {
    return EditorialColors(
      brandPrimary: Color.lerp(a.brandPrimary, b.brandPrimary, t)!,
      brandPrimaryHover: Color.lerp(
        a.brandPrimaryHover,
        b.brandPrimaryHover,
        t,
      )!,
      brandPrimaryContainer: Color.lerp(
        a.brandPrimaryContainer,
        b.brandPrimaryContainer,
        t,
      )!,
      brandOnPrimary: Color.lerp(a.brandOnPrimary, b.brandOnPrimary, t)!,
      brandOnPrimaryContainer: Color.lerp(
        a.brandOnPrimaryContainer,
        b.brandOnPrimaryContainer,
        t,
      )!,
      canvas: Color.lerp(a.canvas, b.canvas, t)!,
      card: Color.lerp(a.card, b.card, t)!,
      surfaceSubdued: Color.lerp(a.surfaceSubdued, b.surfaceSubdued, t)!,
      containerLow: Color.lerp(a.containerLow, b.containerLow, t)!,
      containerHigh: Color.lerp(a.containerHigh, b.containerHigh, t)!,
      borderDefault: Color.lerp(a.borderDefault, b.borderDefault, t)!,
      borderSubtle: Color.lerp(a.borderSubtle, b.borderSubtle, t)!,
      borderFocus: Color.lerp(a.borderFocus, b.borderFocus, t)!,
      textPrimary: Color.lerp(a.textPrimary, b.textPrimary, t)!,
      textSecondary: Color.lerp(a.textSecondary, b.textSecondary, t)!,
      textTertiary: Color.lerp(a.textTertiary, b.textTertiary, t)!,
      textDisabled: Color.lerp(a.textDisabled, b.textDisabled, t)!,
      codeBackground: Color.lerp(a.codeBackground, b.codeBackground, t)!,
      codeBorder: Color.lerp(a.codeBorder, b.codeBorder, t)!,
      codeText: Color.lerp(a.codeText, b.codeText, t)!,
      error: Color.lerp(a.error, b.error, t)!,
      errorContainer: Color.lerp(a.errorContainer, b.errorContainer, t)!,
      isDark: t > 0.5 ? b.isDark : a.isDark,
    );
  }
}
