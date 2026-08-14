import 'package:flutter/material.dart';

import 'package:design_system/src/tokens/colors.token.dart';
import 'package:design_system/src/tokens/dimensions.token.dart';
import 'package:design_system/src/tokens/typography.token.dart';

class DorakTheme {
  static ThemeData get light => _build(Brightness.light, DorakColors.light);
  static ThemeData get dark => _build(Brightness.dark, DorakColors.dark);

  static ThemeData forLocale(Locale locale, Brightness brightness) {
    final isArabic = locale.languageCode == 'ar';
    return _build(
      brightness,
      brightness == Brightness.dark ? DorakColors.dark : DorakColors.light,
      fontFamily: isArabic
          ? DorakTypography.fontFamilyArabic
          : DorakTypography.fontFamily,
      fontFamilyFallback: isArabic
          ? [DorakTypography.fontFamily, 'Roboto', 'Arial']
          : DorakTypography.fontFamilyFallback,
    );
  }

  static ThemeData _build(
    Brightness brightness,
    DorakColors c, {
    String fontFamily = DorakTypography.fontFamily,
    List<String> fontFamilyFallback = DorakTypography.fontFamilyFallback,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      primaryContainer: c.primaryContainer,
      onPrimaryContainer: c.onPrimaryContainer,
      secondary: c.secondary,
      onSecondary: c.onSecondary,
      secondaryContainer: c.secondaryContainer,
      onSecondaryContainer: c.onSecondaryContainer,
      tertiary: c.tertiary,
      onTertiary: c.onTertiary,
      tertiaryContainer: c.tertiaryContainer,
      onTertiaryContainer: c.onTertiaryContainer,
      error: c.error,
      onError: c.onError,
      errorContainer: c.errorContainer,
      onErrorContainer: c.onErrorContainer,
      surface: c.surface,
      onSurface: c.onSurface,
      surfaceContainerHighest: c.surfaceContainerHighest,
      onSurfaceVariant: c.onSurfaceVariant,
      outline: c.outline,
      outlineVariant: c.outlineVariant,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: c.inverseSurface,
      onInverseSurface: c.inverseOnSurface,
      inversePrimary: c.inversePrimary,
      surfaceTint: c.surfaceTint,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: c.background,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      textTheme: TextTheme(
        displayLarge: DorakTypography.displayLg,
        headlineLarge: DorakTypography.headlineLg,
        headlineMedium: DorakTypography.headlineMd,
        headlineSmall: DorakTypography.headlineSm,
        titleLarge: DorakTypography.titleLg,
        bodyLarge: DorakTypography.bodyLg,
        bodyMedium: DorakTypography.bodyMd,
        labelLarge: DorakTypography.labelLg,
        labelMedium: DorakTypography.labelMd,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: DorakDimensions.radiusFull,
          ),
        ),
      ),
    );
  }
}
