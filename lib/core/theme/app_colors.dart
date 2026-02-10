import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0A0E27);
  static const Color primary = Color(0xFF0A0E27);
  static const Color accent = Color(0xFF00F0FF);
  static const Color secondaryAccent = Color(0xFF7B61FF);
  static const Color success = Color(0xFF00FFA3);
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFFF4757);
  static const Color surface = Color(0xFF141829);
  static const Color card = Color(0xFF1E2336);
  static const Color divider = Color(0xFF2A3045);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8B92B0);
  static const Color textTertiary = Color(0xFF5A617A);
  static const Color overlay = Color(0x800A0E27);
  static const Color shadow = Color(0x1A000000);

  static const Color modeCool = Color(0xFF00F0FF);
  static const Color modeHeat = Color(0xFFFF6B6B);
  static const Color modeFan = Color(0xFF4ECDC4);
  static const Color modeDry = Color(0xFF95E1D3);

  static const Color speedLow = Color(0xFF4ECDC4);
  static const Color speedMedium = Color(0xFF7B61FF);
  static const Color speedHigh = Color(0xFFFF6B6B);
  static const Color speedAuto = Color(0xFF00F0FF);

  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}
