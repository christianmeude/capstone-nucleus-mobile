import 'package:flutter/material.dart';

class AppColors {
  // Modern Primary Gradient Colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8B85FF);
  static const Color primaryDark = Color(0xFF5046E5);
  static const Color primary500 = Color(0xFF6C63FF);
  static const Color primary600 = Color(0xFF5046E5);
  static const Color primary700 = Color(0xFF4338CA);
  
  // Accent Colors
  static const Color accent = Color(0xFF00D9FF);
  static const Color accentLight = Color(0xFF5EE7FF);
  static const Color accentDark = Color(0xFF00B8D9);
  
  // Secondary Colors
  static const Color secondary = Color(0xFFFF6B9D);
  static const Color secondaryLight = Color(0xFFFF8FB3);
  static const Color secondaryDark = Color(0xFFE84A7F);
  
  // Background colors - Modern Glass Effect
  static const Color background = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Text colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Status colors - Vibrant
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  
  // Border colors
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderMedium = Color(0xFFCBD5E1);
  
  // Interactive colors
  static const Color hover = Color(0xFFF1F5F9);
  static const Color pressed = Color(0xFFE2E8F0);
  static const Color disabled = Color(0xFF94A3B8);
  
  // Gradient presets
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF8B85FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00D9FF), Color(0xFF6C63FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Shadows - Single BoxShadow for direct use
  static BoxShadow get softShadow => BoxShadow(
    color: const Color(0xFF6C63FF).withOpacity(0.08),
    blurRadius: 24,
    offset: const Offset(0, 8),
  );
  
  static BoxShadow get cardShadow => BoxShadow(
    color: Colors.black.withOpacity(0.04),
    blurRadius: 16,
    offset: const Offset(0, 4),
  );
}