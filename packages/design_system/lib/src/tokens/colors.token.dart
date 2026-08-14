import 'package:flutter/material.dart';

class DorakColors {
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color surfaceBright;
  final Color surfaceDim;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color surfaceVariant;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color inverseSurface;
  final Color inverseOnSurface;
  final Color outline;
  final Color outlineVariant;
  final Color surfaceTint;
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color inversePrimary;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color primaryFixed;
  final Color primaryFixedDim;
  final Color onPrimaryFixed;
  final Color onPrimaryFixedVariant;
  final Color secondaryFixed;
  final Color secondaryFixedDim;
  final Color onSecondaryFixed;
  final Color onSecondaryFixedVariant;
  final Color tertiaryFixed;
  final Color tertiaryFixedDim;
  final Color onTertiaryFixed;
  final Color onTertiaryFixedVariant;
  final Color inputBgSoft;
  final Color inputBgFocus;

  const DorakColors({
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.surfaceBright,
    required this.surfaceDim,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.surfaceVariant,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.inverseSurface,
    required this.inverseOnSurface,
    required this.outline,
    required this.outlineVariant,
    required this.surfaceTint,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.inversePrimary,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.primaryFixed,
    required this.primaryFixedDim,
    required this.onPrimaryFixed,
    required this.onPrimaryFixedVariant,
    required this.secondaryFixed,
    required this.secondaryFixedDim,
    required this.onSecondaryFixed,
    required this.onSecondaryFixedVariant,
    required this.tertiaryFixed,
    required this.tertiaryFixedDim,
    required this.onTertiaryFixed,
    required this.onTertiaryFixedVariant,
    required this.inputBgSoft,
    required this.inputBgFocus,
  });

  static const DorakColors light = DorakColors(
    background: Color(0xFFFDF8FD),
    onBackground: Color(0xFF1C1B1F),
    surface: Color(0xFFFDF8FD),
    surfaceBright: Color(0xFFFDF8FD),
    surfaceDim: Color(0xFFDDD9DE),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF7F2F8),
    surfaceContainer: Color(0xFFF1ECF2),
    surfaceContainerHigh: Color(0xFFEBE7EC),
    surfaceContainerHighest: Color(0xFFE5E1E7),
    surfaceVariant: Color(0xFFE5E1E7),
    onSurface: Color(0xFF1C1B1F),
    onSurfaceVariant: Color(0xFF494551),
    inverseSurface: Color(0xFF313034),
    inverseOnSurface: Color(0xFFF4EFF5),
    outline: Color(0xFF7A7582),
    outlineVariant: Color(0xFFCBC4D2),
    surfaceTint: Color(0xFF6750A4),
    primary: Color(0xFF4F378A),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF6850A4),
    onPrimaryContainer: Color(0xFFE0D2FF),
    inversePrimary: Color(0xFFD0BCFF),
    secondary: Color(0xFF625B71),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE8DEF9),
    onSecondaryContainer: Color(0xFF686177),
    tertiary: Color(0xFF4C435E),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFF645A76),
    onTertiaryContainer: Color(0xFFE0D3F5),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF93000A),
    primaryFixed: Color(0xFFE9DDFF),
    primaryFixedDim: Color(0xFFD0BCFF),
    onPrimaryFixed: Color(0xFF22005C),
    onPrimaryFixedVariant: Color(0xFF4F378A),
    secondaryFixed: Color(0xFFE8DEF9),
    secondaryFixedDim: Color(0xFFCCC2DC),
    onSecondaryFixed: Color(0xFF1E192B),
    onSecondaryFixedVariant: Color(0xFF4A4358),
    tertiaryFixed: Color(0xFFEADDFF),
    tertiaryFixedDim: Color(0xFFCEC1E2),
    onTertiaryFixed: Color(0xFF1F1730),
    onTertiaryFixedVariant: Color(0xFF4B425D),
    inputBgSoft: Color.fromRGBO(234, 221, 255, 0.05),
    inputBgFocus: Color.fromRGBO(234, 221, 255, 0.10),
  );

  static const DorakColors dark = DorakColors(
    background: Color(0xFF141218),
    onBackground: Color(0xFFE6E1E5),
    surface: Color(0xFF141218),
    surfaceBright: Color(0xFF3A383C),
    surfaceDim: Color(0xFF141218),
    surfaceContainerLowest: Color(0xFF0F0D13),
    surfaceContainerLow: Color(0xFF1D1B1F),
    surfaceContainer: Color(0xFF211F24),
    surfaceContainerHigh: Color(0xFF2B292E),
    surfaceContainerHighest: Color(0xFF363439),
    surfaceVariant: Color(0xFF49454F),
    onSurface: Color(0xFFE6E1E5),
    onSurfaceVariant: Color(0xFFCAC4D0),
    inverseSurface: Color(0xFFE6E1E5),
    inverseOnSurface: Color(0xFF313034),
    outline: Color(0xFF938F99),
    outlineVariant: Color(0xFF49454F),
    surfaceTint: Color(0xFFD0BCFF),
    primary: Color(0xFFD0BCFF),
    onPrimary: Color(0xFF381E72),
    primaryContainer: Color(0xFF4F378A),
    onPrimaryContainer: Color(0xFFE0D2FF),
    inversePrimary: Color(0xFF4F378A),
    secondary: Color(0xFFCCC2DC),
    onSecondary: Color(0xFF332D41),
    secondaryContainer: Color(0xFF4A4458),
    onSecondaryContainer: Color(0xFFE8DEF9),
    tertiary: Color(0xFFCEBCE1),
    onTertiary: Color(0xFF38294A),
    tertiaryContainer: Color(0xFF4C435E),
    onTertiaryContainer: Color(0xFFE0D3F5),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    primaryFixed: Color(0xFFE9DDFF),
    primaryFixedDim: Color(0xFFD0BCFF),
    onPrimaryFixed: Color(0xFF22005C),
    onPrimaryFixedVariant: Color(0xFF4F378A),
    secondaryFixed: Color(0xFFE8DEF9),
    secondaryFixedDim: Color(0xFFCCC2DC),
    onSecondaryFixed: Color(0xFF1E192B),
    onSecondaryFixedVariant: Color(0xFF4A4358),
    tertiaryFixed: Color(0xFFEADDFF),
    tertiaryFixedDim: Color(0xFFCEC1E2),
    onTertiaryFixed: Color(0xFF1F1730),
    onTertiaryFixedVariant: Color(0xFF4B425D),
    inputBgSoft: Color.fromRGBO(234, 221, 255, 0.05),
    inputBgFocus: Color.fromRGBO(234, 221, 255, 0.10),
  );

  static DorakColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}
