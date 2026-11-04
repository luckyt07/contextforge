import 'package:flutter/material.dart';

/// Semantic color tokens based on DESIGN.md
class AppColors {
  AppColors._();

  // Brand Accent (Terracotta)
  static const Color brandPrimary = Color(0xFFC15F3C);
  static const Color brandPrimaryHover = Color(0xFF994121);
  static const Color brandPrimaryContainerLight = Color(0xFFFCECE6);
  static const Color brandPrimaryContainerDark = Color(0xFF432418);
  static const Color brandOnPrimary = Color(0xFFFFFFFF);
  static const Color brandOnPrimaryContainerLight = Color(0xFF712F18);
  static const Color brandOnPrimaryContainerDark = Color(0xFFFFDBCE);

  // Surfaces & Canvas (Light)
  static const Color canvasLight = Color(0xFFFFF8F5);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color surfaceSubduedLight = Color(0xFFFBF2ED);
  static const Color containerLowLight = Color(0xFFF8F1EB);
  static const Color containerHighLight = Color(0xFFEFE6E2);

  // Surfaces & Canvas (Dark)
  static const Color canvasDark = Color(0xFF1A1715);
  static const Color cardDark = Color(0xFF24201D);
  static const Color surfaceSubduedDark = Color(0xFF2B2623);
  static const Color containerLowDark = Color(0xFF201D1A);
  static const Color containerHighDark = Color(0xFF332E2A);

  // Borders & Strokes
  static const Color borderDefaultLight = Color(0xFFE1D8D4);
  static const Color borderSubtleLight = Color(0xFFEFE8E4);
  static const Color borderFocusLight = Color(0xFFC15F3C);

  static const Color borderDefaultDark = Color(0xFF3D3632);
  static const Color borderSubtleDark = Color(0xFF302A27);
  static const Color borderFocusDark = Color(0xFFE07A58);

  // Text & Icons (Light)
  static const Color textPrimaryLight = Color(0xFF2C2523);
  static const Color textSecondaryLight = Color(0xFF796E69);
  static const Color textTertiaryLight = Color(0xFFADA29D);
  static const Color textDisabledLight = Color(0xFFC5BBB6);

  // Text & Icons (Dark)
  static const Color textPrimaryDark = Color(0xFFF5EFEB);
  static const Color textSecondaryDark = Color(0xFFA89F9A);
  static const Color textTertiaryDark = Color(0xFF6E6560);
  static const Color textDisabledDark = Color(0xFF524C48);

  // Code & Technical Elements
  static const Color codeBackgroundLight = Color(0xFFF8F5F2);
  static const Color codeBorderLight = Color(0xFFE8E2DD);
  static const Color codeTextLight = Color(0xFF3A312E);

  static const Color codeBackgroundDark = Color(0xFF1E1B19);
  static const Color codeBorderDark = Color(0xFF332E2A);
  static const Color codeTextDark = Color(0xFFEBE4DF);

  // Status & Semantic
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
}
