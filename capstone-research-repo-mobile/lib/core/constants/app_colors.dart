import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - NU Blue
  static const Color primary = Color(0xFF1A3263);
  static const Color primaryLight = Color(0xFF2E4A7D);
  static const Color primaryDark = Color(0xFF0F1D3A);
  static const Color primary500 = Color(0xFF1A3263);
  static const Color primary600 = Color(0xFF152851);
  static const Color primary700 = Color(0xFF0F1F3D);

  // Secondary Colors - Lighter Blue
  static const Color secondary = Color(0xFF4A6FA5);
  static const Color secondaryLight = Color(0xFF6B8FC5);
  static const Color secondaryDark = Color(0xFF3A5A8A);

  // Accent Colors - NU Gold/Yellow
  static const Color accent = Color(0xFFFFCC00);
  static const Color accentLight = Color(0xFFFFE066);
  static const Color accentDark = Color(0xFFE6B800);

  // Background Colors
  static const Color background = Color(0xFFF5F7FA);
  static const Color backgroundDark = Color(0xFF1A3263);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F2F5);
  static const Color surfaceLight = Color(0xFFFAFBFC);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE1E5EB);

  // Text colors
  static const Color textPrimary = Color(0xFF1A1D26);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status colors
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Border colors
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderMedium = Color(0xFFD1D5DB);

  // Interactive colors
  static const Color hover = Color(0xFFF5F3F0);
  static const Color pressed = Color(0xFFE8E6E3);
  static const Color disabled = Color(0xFFD1D5DB);

  // Gradient presets
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A3263), Color(0xFF2E4A7D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFAB95B), Color(0xFFE5A23D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFAF9F7)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFAB95B), Color(0xFFE5A23D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows - Single BoxShadow for direct use
  static BoxShadow get softShadow => BoxShadow(
    color: const Color(0xFF1A3263).withOpacity(0.06),
    blurRadius: 16,
    offset: const Offset(0, 4),
  );

  static BoxShadow get cardShadow => BoxShadow(
    color: const Color(0xFF1A3263).withOpacity(0.04),
    blurRadius: 12,
    offset: const Offset(0, 2),
  );

  static BoxShadow get elevatedShadow => BoxShadow(
    color: const Color(0xFF1A3263).withOpacity(0.08),
    blurRadius: 24,
    offset: const Offset(0, 8),
  );
}
