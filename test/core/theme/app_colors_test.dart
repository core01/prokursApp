import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prokurs/core/theme/app_theme.dart';

// Apple's minimum contrast (HIG, Accessibility): 4.5:1 for text up to 17 pt, 3:1 for non-text.
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (max(la, lb) + 0.05) / (min(la, lb) + 0.05);
}

// Each appearance a dynamic color can take: light/dark × normal/Increase Contrast, and the
// elevated variants dark mode uses in sheets and popovers.
typedef Variant = Color Function(CupertinoDynamicColor);

final Map<String, Variant> variants = {
  'light': (c) => c.color,
  'dark': (c) => c.darkColor,
  'light HC': (c) => c.highContrastColor,
  'dark HC': (c) => c.darkHighContrastColor,
  'dark elevated': (c) => c.darkElevatedColor,
  'dark HC elevated': (c) => c.darkHighContrastElevatedColor,
};

void main() {
  const text = {
    'label': AppColors.label,
    'secondaryLabel': AppColors.secondaryLabel,
    'link': AppColors.link,
    'buy': AppColors.buy,
    'sell': AppColors.sell,
    'success': AppColors.success,
    'error': AppColors.error,
    'warning': AppColors.warning,
  };
  const backgrounds = {'background': AppColors.background, 'surface': AppColors.surface};

  test('text colors reach 4.5:1 on every background, in every appearance', () {
    for (final MapEntry(key: name, value: color) in text.entries) {
      for (final MapEntry(key: bgName, value: bg) in backgrounds.entries) {
        for (final MapEntry(key: variant, value: pick) in variants.entries) {
          expect(contrast(pick(color), pick(bg)), greaterThanOrEqualTo(4.5),
              reason: '$name on $bgName, $variant');
        }
      }
    }
  });

  // The wholesale badge: semibold warning text on its own 12% tint. Bold text needs 3:1.
  test('bold warning text reaches 3:1 on its own tint, in every appearance', () {
    for (final MapEntry(key: bgName, value: bg) in backgrounds.entries) {
      for (final MapEntry(key: variant, value: pick) in variants.entries) {
        final warning = pick(AppColors.warning);
        final tint = Color.alphaBlend(warning.withValues(alpha: 0.12), pick(bg));
        expect(contrast(warning, tint), greaterThanOrEqualTo(3),
            reason: 'warning on its tint over $bgName, $variant');
      }
    }
  });

  test('input borders reach 3:1 on every background, in every appearance', () {
    for (final MapEntry(key: bgName, value: bg) in backgrounds.entries) {
      for (final MapEntry(key: variant, value: pick) in variants.entries) {
        expect(contrast(pick(AppColors.inputBorder), pick(bg)), greaterThanOrEqualTo(3),
            reason: 'inputBorder on $bgName, $variant');
      }
    }
  });

  test('header text reaches 4.5:1 on the header', () {
    expect(contrast(AppColors.onHeader, AppColors.header), greaterThanOrEqualTo(4.5));
    expect(contrast(AppColors.onHeaderSecondary, AppColors.header), greaterThanOrEqualTo(4.5));
    expect(contrast(AppColors.onHeader, AppColors.headerFill), greaterThanOrEqualTo(4.5));
  });
}
