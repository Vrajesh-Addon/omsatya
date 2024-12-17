import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFfdf0e2);
  static const Color gradient = Color(0xffd4dec8);

  // static const Color primary = Color(0xFF1753FC);
  static const Color primary = Color(0xFF243D7C);
  static const Color onPrimary = Colors.white;
  // static const Color secondary = Color(0xFF1753FC);
  static const Color secondary = Color(0xFF243D7C);
  static const Color onSecondary = Colors.white;

  static const Color success = Color(0xFF43a047);
  static const Color info = Color(0xFF2196f3);
  static const Color warning = Color(0xFFef6c00);
  static const Color danger = Color(0xFFef5350);
  static const Color error = Color(0xffb00020);
  static const Color green = Color(0XFF03A685);

  static const Color grey153 = Color(0XFF999999);
  static const Color darkGrey = Color(0XFF6B7377);

  static Color appBarBg = const Color(0XFFF9F9F9);

  // static Color shimmerBase = Colors.grey.shade50;
  // static Color shimmerHighlighted = Colors.grey.shade200;
  static Color shimmerBase = Colors.grey[300]!;
  static Color shimmerHighlighted = Colors.grey[100]!;

  static ColorScheme colorSchemeLight = const ColorScheme.light(
    primary: primary,
    secondary: secondary,
  );

  static ColorScheme colorSchemeDark = ColorScheme.dark(
    primary: lighten(primary),
    secondary: lighten(secondary),
  );

  static Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}
