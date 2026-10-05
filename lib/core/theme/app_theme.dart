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
  // A neutral grey: systemGroupedBackground (F2F2F7) reads bluish in light mode. Dark mode
  // keeps the system values, where the tint doesn't show.
  static const background = CupertinoDynamicColor(
    color: Color(0xFFF4F4F4),
    darkColor: Color(0xFF000000),
    highContrastColor: Color(0xFFEBEBEB),
    darkHighContrastColor: Color(0xFF000000),
    elevatedColor: Color(0xFFF4F4F4),
    darkElevatedColor: Color(0xFF1C1C1E),
    highContrastElevatedColor: Color(0xFFEBEBEB),
    darkHighContrastElevatedColor: Color(0xFF242426),
  );
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

/// Spacing on a 4-pt grid. Apple publishes no scale; [md] is the iPhone layout margin and
/// [lg] the content inset of a grouped list row (CupertinoListTile, CupertinoFormRow).
abstract final class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

/// Corner radii by role. Nested elements are rounded less than their container (Apple HIG,
/// Layout). Touch targets use Flutter's kMinInteractiveDimensionCupertino (44 pt).
abstract final class AppRadius {
  /// Text fields and other controls inside cards.
  static const control = BorderRadius.all(Radius.circular(8));

  /// Cards, notices and buttons: the radius iOS inset grouped sections have
  /// (CupertinoListSection clips its rows to it whatever decoration it gets).
  static const card = BorderRadius.all(Radius.circular(10));

  /// Chips and pills.
  static const capsule = BorderRadius.all(Radius.circular(999));
}

/// Lines: separators and control borders.
abstract final class AppStroke {
  /// One physical pixel, like iOS separators: BorderSide paints width 0 as a hairline.
  static const hairline = 0.0;
}

/// Animations. Brief, so nobody waits for them (Apple HIG, Motion).
abstract final class AppMotion {
  /// UIKit's standard short animation.
  static const duration = Duration(milliseconds: 250);
  static const curve = Curves.easeInOut;
}

abstract final class AppIconSize {
  /// Next to text.
  static const small = 20.0;

  /// Navigation bars and list rows.
  static const regular = 24.0;
}

/// A card on the grouped background, shaped like an inset grouped section (continuous corners).
ShapeDecoration cardDecoration(BuildContext context) => ShapeDecoration(
  color: AppColors.surface.resolveFrom(context),
  shape: const RoundedSuperellipseBorder(borderRadius: AppRadius.card),
);

/// A grouped list or form section: the screen's side margins and the gap to what follows.
const sectionMargin = EdgeInsetsDirectional.fromSTEB(
  AppSpacing.md,
  0,
  AppSpacing.md,
  AppSpacing.xl,
);

// The theme's text styles are complete (inherit: false), like Flutter's defaults: on route
// transitions the navigation bar interpolates the title into the back button, and TextStyle.lerp
// fails between styles with different `inherit`.
TextStyle _themeStyle(TextStyle style, Color color) => style.copyWith(
  inherit: false,
  color: color,
  decoration: TextDecoration.none,
);

final appTheme = CupertinoThemeData(
  primaryColor: AppColors.accent,
  primaryContrastingColor: AppColors.onAccent,
  scaffoldBackgroundColor: AppColors.background,
  textTheme: CupertinoTextThemeData(
    primaryColor: AppColors.accent,
    textStyle: _themeStyle(AppTypography.body, AppColors.label),
    actionTextStyle: _themeStyle(AppTypography.body, AppColors.accent),
    navActionTextStyle: _themeStyle(AppTypography.body, AppColors.accent),
    navTitleTextStyle: _themeStyle(AppTypography.headline, AppColors.label),
    navLargeTitleTextStyle: _themeStyle(
      AppTypography.largeTitle,
      AppColors.label,
    ),
  ),
);
