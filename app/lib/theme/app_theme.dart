import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'editorial_colors.dart';
import 'app_spacing.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => build(EditorialColors.light());
  static ThemeData dark() => build(EditorialColors.dark());

  static ThemeData build(EditorialColors colors) {
    final isDark = colors.isDark;

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: colors.canvas,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: colors.brandPrimary,
        onPrimary: colors.brandOnPrimary,
        primaryContainer: colors.brandPrimaryContainer,
        onPrimaryContainer: colors.brandOnPrimaryContainer,
        secondary: colors.brandPrimary,
        onSecondary: Colors.white,
        error: colors.error,
        onError: Colors.white,
        surface: colors.canvas,
        onSurface: colors.textPrimary,
        surfaceContainerLowest: colors.card,
        surfaceContainerLow: colors.surfaceSubdued,
        surfaceContainer: colors.containerLow,
        surfaceContainerHigh: colors.containerHigh,
        outline: colors.borderDefault,
        outlineVariant: colors.borderSubtle,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: colors.textPrimary),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          side: BorderSide(color: colors.borderDefault, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: colors.borderSubtle,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceSubdued,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: BorderSide(color: colors.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: BorderSide(color: colors.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: BorderSide(color: colors.borderFocus, width: 1.5),
        ),
        hintStyle: TextStyle(color: colors.textTertiary, fontSize: 14),
      ),
    );
  }
}
