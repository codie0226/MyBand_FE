import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8F8F8);
  static const Color primaryText = Color(0xFF111111);
  static const Color secondaryText = Color(0xFF757575);
  static const Color border = Color(0xFFEAEAEA);
  static const Color primary = Color(0xFF111111);
  static const Color point = Color(0xFF0038FF); // Vibrant Electric Blue
}

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.notoSansKrTextTheme();
    
    return ThemeData(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.point,
        surface: AppColors.background,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.primaryText,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryText),
        titleTextStyle: GoogleFonts.notoSansKr(
          color: AppColors.primaryText,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      textTheme: baseTextTheme.copyWith(
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: AppColors.primaryText, letterSpacing: -0.5),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: AppColors.primaryText, letterSpacing: -0.5),
        bodySmall: baseTextTheme.bodySmall?.copyWith(color: AppColors.secondaryText, letterSpacing: -0.3),
        titleLarge: baseTextTheme.titleLarge?.copyWith(color: AppColors.primaryText, letterSpacing: -0.5, fontWeight: FontWeight.bold),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.background,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        space: 1,
        thickness: 1,
      ),
    );
  }
}
