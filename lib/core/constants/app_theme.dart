import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

ThemeData buildAppTheme() {
  final interTextTheme = GoogleFonts.interTextTheme();

  final baseTheme = ThemeData(
    primaryColor: AppColors.primary,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.background,
    cardColor: AppColors.cardBackground,
    fontFamily: GoogleFonts.inter().fontFamily,
    visualDensity: VisualDensity.standard,

    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.cardBackground,
      error: AppColors.error,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: const Color(0x12000000),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: AppTextStyles.heading4.copyWith(
        fontWeight: FontWeight.w700,
      ),
    ),

    iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 20),

    popupMenuTheme: PopupMenuThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      textStyle: AppTextStyles.bodyMedium,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceLight,
      selectedColor: AppColors.primary.withOpacity(0.12),
      secondarySelectedColor: AppColors.primary.withOpacity(0.12),
      disabledColor: AppColors.borderLight,
      labelStyle: AppTextStyles.labelMedium,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      side: const BorderSide(color: AppColors.borderLight),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      brightness: Brightness.light,
    ),

    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      iconColor: AppColors.primary,
      textColor: AppColors.textPrimary,
      minLeadingWidth: 24,
    ),

    cardTheme: CardThemeData(
      color: AppColors.cardBackground,
      elevation: 0.5,
      shadowColor: const Color(0x14000000),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderLight, width: 1),
      ),
    ),

    buttonTheme: const ButtonThemeData(
      buttonColor: AppColors.primary,
      textTheme: ButtonTextTheme.primary,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        shadowColor: Colors.transparent,
        textStyle: AppTextStyles.buttonMedium,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        minimumSize: const Size(0, 48),
        side: const BorderSide(color: AppColors.borderMedium),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: AppTextStyles.buttonMedium.copyWith(
          color: AppColors.primary,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTextStyles.buttonMedium.copyWith(
          color: AppColors.primary,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
      labelStyle: AppTextStyles.labelMedium.copyWith(
        color: AppColors.textSecondary,
      ),
      floatingLabelStyle: AppTextStyles.labelMedium.copyWith(
        color: AppColors.primary,
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      modalBackgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.primaryDark,
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.borderLight,
      thickness: 0.8,
      space: 24,
    ),
  );

  final themedText = interTextTheme.copyWith(
    displayLarge: AppTextStyles.display,
    displayMedium: AppTextStyles.heading1,
    displaySmall: AppTextStyles.heading2,
    headlineLarge: AppTextStyles.heading1,
    headlineMedium: AppTextStyles.heading2,
    headlineSmall: AppTextStyles.heading3,
    titleLarge: AppTextStyles.heading4,
    titleMedium: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
    titleSmall: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
    bodyLarge: AppTextStyles.bodyLarge,
    bodyMedium: AppTextStyles.bodyMedium,
    bodySmall: AppTextStyles.bodySmall,
    labelLarge: AppTextStyles.labelLarge,
    labelMedium: AppTextStyles.labelMedium,
    labelSmall: AppTextStyles.labelSmall,
  );

  return baseTheme.copyWith(
    textTheme: themedText.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    primaryTextTheme: GoogleFonts.interTextTheme(baseTheme.primaryTextTheme)
        .apply(
          bodyColor: AppColors.textOnPrimary,
          displayColor: AppColors.textOnPrimary,
        ),
  );
}
