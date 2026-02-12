import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

ThemeData buildAppTheme() {
  // 1. Create the base theme with all your custom settings
  final baseTheme = ThemeData(
    primaryColor: AppColors.primary,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    
    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.cardBackground,
      error: AppColors.error,
    ),

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 1,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    ),

    // Card Theme (FIXED: Changed from CardThemeData to CardTheme)
    cardTheme: CardThemeData(
      elevation: 2,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderLight, width: 1),
      ),
    ),

    // Button Themes
    buttonTheme: const ButtonThemeData(
      buttonColor: AppColors.primary,
      textTheme: ButtonTextTheme.primary,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: AppTextStyles.buttonMedium,
      ),
    ),

    // Input Decoration (Text Fields)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.borderMedium),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.borderMedium),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: AppColors.textLight),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.borderLight,
      thickness: 1,
      space: 20,
    ),
  );

  // 2. Apply Google Fonts (Poppins) to the entire text theme
  return baseTheme.copyWith(
    textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme),
  );
}