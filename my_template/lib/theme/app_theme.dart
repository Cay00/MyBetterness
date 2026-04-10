import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFFBCA9ED);
  static const Color background = Color(0xFFE9EEEA);
  static const Color textDark = Color(0xFF03070C);

  static const String fontFamily = 'Roboto';

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.fromSeed(seedColor: primary),
      scaffoldBackgroundColor: background,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textDark),
        bodyMedium: TextStyle(color: textDark),
        bodySmall: TextStyle(color: textDark),
        titleLarge: TextStyle(color: textDark, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: textDark, fontWeight: FontWeight.w600),
        labelLarge: TextStyle(color: textDark, fontWeight: FontWeight.normal),
      ),
    );
  }
}
