import 'package:flutter/material.dart';

import 'text_styles.dart';
import 'tokens.dart';

/// The single theme for PIKIR. There is no dark theme, by product decision:
/// the app must read as a calm public-service tool in the conditions it is
/// actually used in, and a second palette doubles the surface for contrast
/// mistakes.
abstract final class PikirTheme {
  static const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: PikirColors.primary,
    onPrimary: PikirColors.onPrimary,
    primaryContainer: PikirColors.primaryContainer,
    onPrimaryContainer: PikirColors.textPrimary,
    secondary: PikirColors.accent,
    onSecondary: PikirColors.textPrimary,
    secondaryContainer: PikirColors.cautionContainer,
    onSecondaryContainer: PikirColors.textPrimary,
    tertiary: PikirColors.safe,
    onTertiary: PikirColors.onPrimary,
    error: PikirColors.danger,
    onError: PikirColors.onPrimary,
    errorContainer: PikirColors.dangerContainer,
    onErrorContainer: PikirColors.textPrimary,
    surface: PikirColors.surface,
    onSurface: PikirColors.textPrimary,
    onSurfaceVariant: PikirColors.textSecondary,
    outline: PikirColors.outline,
    outlineVariant: PikirColors.outline,
  );

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: PikirColors.background,
      canvasColor: PikirColors.background,
      fontFamily: PikirText.family,

      // Every tappable thing gets at least 48x48.
      materialTapTargetSize: MaterialTapTargetSize.padded,

      textTheme: TextTheme(
        displayLarge: PikirText.displayNumberLarge,
        displayMedium: PikirText.displayNumber,
        headlineLarge: PikirText.headlineLarge,
        headlineMedium: PikirText.headline,
        titleLarge: PikirText.titleLarge,
        titleMedium: PikirText.title,
        bodyLarge: PikirText.body,
        bodyMedium: PikirText.body,
        labelLarge: PikirText.button,
        labelMedium: PikirText.label,
        bodySmall: PikirText.caption,
        labelSmall: PikirText.caption,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: PikirColors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: PikirColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: PikirText.titleLarge,
        iconTheme: const IconThemeData(
          color: PikirColors.textPrimary,
          size: 24,
        ),
      ),

      cardTheme: CardThemeData(
        color: PikirColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PikirRadius.card),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: PikirColors.outline,
        thickness: 1,
        space: 1,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: PikirColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(PikirRadius.sheet),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PikirColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: PikirText.bodySecondary,
        labelStyle: PikirText.label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PikirRadius.input),
          borderSide: const BorderSide(color: PikirColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PikirRadius.input),
          borderSide: const BorderSide(color: PikirColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PikirRadius.input),
          borderSide: const BorderSide(
            color: PikirColors.primary,
            width: 2,
          ),
        ),
      ),

      splashFactory: InkSparkle.splashFactory,
    );
  }
}
