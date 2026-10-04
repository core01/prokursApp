import 'package:flutter/cupertino.dart';

/// The app's palette: every color the UI shows comes from here.
///
/// System colors are used where they meet Apple's contrast minimum (4.5:1 for text up to
/// 17 pt, 3:1 for non-text): they already adapt to Dark Mode, elevated (modal) surfaces and
/// Increase Contrast. Custom colors carry the same light/dark × normal/increased-contrast
/// variants. test/core/theme/app_colors_test.dart checks the ratios.
///
/// Cupertino widgets resolve dynamic colors themselves. Plain widgets (Text, Container,
/// BoxDecoration, Icon, Divider) and CupertinoActivityIndicator.color don't: pass
/// `AppColors.x.resolveFrom(context)` there.
abstract final class AppColors {
  // Backgrounds: the grouped set, since the screens are grouped lists and cards.
  static const background = CupertinoColors.systemGroupedBackground;
  static const surface = CupertinoColors.secondarySystemGroupedBackground;

  // Text.
  static const label = CupertinoColors.label;
  // CupertinoColors.secondaryLabel is 3.3:1 on the light background.
  static const secondaryLabel = CupertinoDynamicColor.withBrightnessAndContrast(
    color: Color(0xFF6C6C70),
    darkColor: Color(0xFFAEAEB2),
    highContrastColor: Color(0xFF48484A),
    darkHighContrastColor: Color(0xFFD1D1D6),
  );
  static const link = CupertinoDynamicColor.withBrightnessAndContrast(
    color: Color(0xFF0062CC),
    darkColor: Color(0xFF4DA6FF),
    highContrastColor: Color(0xFF004A99),
    darkHighContrastColor: Color(0xFF8CC8FF),
  );

  // Lines.
  static const separator = CupertinoColors.separator;
  static const inputBorder = CupertinoDynamicColor.withBrightnessAndContrast(
    color: Color(0xFF86868B),
    darkColor: Color(0xFF8E8E93),
    highContrastColor: Color(0xFF6C6C70),
    darkHighContrastColor: Color(0xFFAEAEB2),
  );

  // Interactive elements: the brand is monochrome.
  static const accent = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF1B1D1E),
    darkColor: Color(0xFFFFFFFF),
  );
  static const onAccent = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFFFFFF),
    darkColor: Color(0xFF1B1D1E),
  );

  // Rates.
  static const buy = CupertinoDynamicColor.withBrightnessAndContrast(
    color: Color(0xFF1A7F37),
    darkColor: Color(0xFF30D158),
    highContrastColor: Color(0xFF0E6B2C),
    darkHighContrastColor: Color(0xFF6BE38A),
  );
  static const sell = CupertinoDynamicColor.withBrightnessAndContrast(
    color: Color(0xFFB8333E),
    darkColor: Color(0xFFFF6B6B),
    highContrastColor: Color(0xFF8F1F2A),
    darkHighContrastColor: Color(0xFFFF9B9B),
  );

  // Status.
  static const success = buy;
  static const error = CupertinoDynamicColor.withBrightnessAndContrast(
    color: Color(0xFFD70015),
    darkColor: Color(0xFFFF6961),
    highContrastColor: Color(0xFFA50011),
    darkHighContrastColor: Color(0xFFFF9A94),
  );
  static const warning = CupertinoDynamicColor.withBrightnessAndContrast(
    color: Color(0xFFB25000),
    darkColor: Color(0xFFFF9F0A),
    highContrastColor: Color(0xFF8A3E00),
    darkHighContrastColor: Color(0xFFFFB84D),
  );
  // A fill behind a white icon, e.g. swipe to delete.
  static const destructive = CupertinoColors.systemRed;
  static const onDestructive = CupertinoColors.white;

  // The brand header on Rates and Point: dark in both appearances.
  static const header = Color(0xFF24292F);
  static const onHeader = Color(0xFFFFFFFF);
  static const onHeaderSecondary = Color(0xFFAEAEB2);
  static const headerFill = Color(0xFF494A4B);
}

/// Apple's Dynamic Type scale at the default (Large) size, set in Manrope.
///
/// Styles carry no color: text takes it from the theme's DefaultTextStyle, or from a
/// resolved AppColors token.
abstract final class AppTypography {
  static const _family = 'Manrope';
  // Manrope has no tenge sign (₸); Montserrat draws it.
  static const _fallback = ['Montserrat'];

  static const largeTitle = TextStyle(
    fontFamily: _family,
    fontFamilyFallback: _fallback,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 41 / 34,
  );

  static const title2 = TextStyle(
    fontFamily: _family,
    fontFamilyFallback: _fallback,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 28 / 22,
  );

  static const title3 = TextStyle(
    fontFamily: _family,
    fontFamilyFallback: _fallback,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 25 / 20,
  );

  static const headline = TextStyle(
    fontFamily: _family,
    fontFamilyFallback: _fallback,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 22 / 17,
  );

  static const body = TextStyle(
    fontFamily: _family,
    fontFamilyFallback: _fallback,
    fontSize: 17,
    fontWeight: FontWeight.w500,
    height: 22 / 17,
  );

  static const callout = TextStyle(
    fontFamily: _family,
    fontFamilyFallback: _fallback,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 21 / 16,
  );

  static const subheadline = TextStyle(
    fontFamily: _family,
    fontFamilyFallback: _fallback,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 20 / 15,
  );

  static const footnote = TextStyle(
    fontFamily: _family,
    fontFamilyFallback: _fallback,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 18 / 13,
  );

  static const caption1 = TextStyle(
    fontFamily: _family,
    fontFamilyFallback: _fallback,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
  );
}

final appTheme = CupertinoThemeData(
  primaryColor: AppColors.accent,
  primaryContrastingColor: AppColors.onAccent,
  scaffoldBackgroundColor: AppColors.background,
  textTheme: CupertinoTextThemeData(
    primaryColor: AppColors.accent,
    textStyle: AppTypography.body.copyWith(color: AppColors.label),
    actionTextStyle: AppTypography.body,
    navTitleTextStyle: AppTypography.headline.copyWith(color: AppColors.label),
    navLargeTitleTextStyle: AppTypography.largeTitle.copyWith(color: AppColors.label),
  ),
);
