import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neuroaid/src/core/theme/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: false);
    final textTheme = GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.poppins(fontWeight: FontWeight.w700),
      displayMedium: GoogleFonts.poppins(fontWeight: FontWeight.w700),
      displaySmall: GoogleFonts.poppins(fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.poppins(color: AppColors.textPrimary),
      bodyMedium: GoogleFonts.poppins(color: AppColors.textSecondary),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      textTheme: textTheme,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.card,
        background: AppColors.background,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: AppColors.textPrimary,
          fontSize: 18,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.card,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
