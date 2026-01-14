import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF2B4BEE);

  // Backgrounds
  static const Color backgroundLight = Color(0xFFF6F6F8);
  static const Color backgroundDark = Color(0xFF101322);

  // Text
  static const Color textPrimary = Color(0xFF111218);
  static const Color textSecondary = Color(0xFF616889);

  // Borders & Dividers
  static const Color border = Color(0xFFDBDDE6);
  static const Color borderDark = Color(
    0xFF374151,
  ); // tailored for dark mode based on gray-700

  // Gradients
  static const LinearGradient pastelGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFDFCFB), Color(0xFFE2D1C3)],
  );

  static const LinearGradient pastelGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1C2C), Color(0xFF101322)],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF2B4BEE), Color(0xFF5A75F5)],
  );
}
