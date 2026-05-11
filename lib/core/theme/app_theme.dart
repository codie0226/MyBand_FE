import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// Expo Design System — Flutter Token Mapping
class AppColors {
  // Brand
  static const Color primary = Color(0xFF000000);
  static const Color primaryActive = Color(0xFF1A1A1A);

  // Text
  static const Color ink = Color(0xFF171717);
  static const Color body = Color(0xFF60646C);
  static const Color muted = Color(0xFF999999);
  static const Color mutedSoft = Color(0xFFCCCCCC);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onDark = Color(0xFFFFFFFF);
  static const Color onDarkSoft = Color(0xFFB0B4BA);

  // Surface
  static const Color canvas = Color(0xFFFFFFFF);
  static const Color canvasSoft = Color(0xFFFAFAFA);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceStrong = Color(0xFFF0F0F3);
  static const Color surfaceDark = Color(0xFF171717);
  static const Color surfaceDarkElevated = Color(0xFF1A1A1A);

  // Hairlines
  static const Color hairline = Color(0xFFF0F0F3);
  static const Color hairlineSoft = Color(0xFFF5F5F7);
  static const Color hairlineStrong = Color(0xFFDCDEE0);

  // Semantic
  static const Color semanticError = Color(0xFFEB8E90);
  static const Color semanticSuccess = Color(0xFF16A34A);

  // Legacy aliases (used by screens — kept for compatibility during refactor)
  static const Color background = canvas;
  static const Color surface = surfaceStrong;
  static const Color primaryText = ink;
  static const Color secondaryText = body;
  static const Color border = hairlineStrong;
}

class AppTypography {
  static TextStyle _inter({
    required double size,
    required FontWeight weight,
    double height = 1.5,
    double letterSpacing = 0,
    Color color = AppColors.ink,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  // Display
  static TextStyle displayMega = _inter(size: 64, weight: FontWeight.w600, height: 1.05, letterSpacing: -1.92);
  static TextStyle displayXl = _inter(size: 48, weight: FontWeight.w600, height: 1.1, letterSpacing: -1.44);
  static TextStyle displayLg = _inter(size: 36, weight: FontWeight.w600, height: 1.15, letterSpacing: -1.08);
  static TextStyle displayMd = _inter(size: 28, weight: FontWeight.w600, height: 1.2, letterSpacing: -0.84);
  static TextStyle displaySm = _inter(size: 22, weight: FontWeight.w600, height: 1.25, letterSpacing: -0.5);

  // Title
  static TextStyle titleMd = _inter(size: 18, weight: FontWeight.w600, height: 1.4);
  static TextStyle titleSm = _inter(size: 16, weight: FontWeight.w600, height: 1.4);

  // Body
  static TextStyle bodyMd = _inter(size: 16, weight: FontWeight.w400, height: 1.5);
  static TextStyle bodySm = _inter(size: 14, weight: FontWeight.w400, height: 1.5, color: AppColors.body);

  // Utility
  static TextStyle caption = _inter(size: 13, weight: FontWeight.w400, height: 1.4, color: AppColors.body);
  static TextStyle captionUppercase = _inter(size: 11, weight: FontWeight.w600, height: 1.4, letterSpacing: 0.88, color: AppColors.ink);
  static TextStyle button = _inter(size: 14, weight: FontWeight.w500, height: 1.0);
  static TextStyle navLink = _inter(size: 14, weight: FontWeight.w500, height: 1.4);
}

class AppTheme {
  static ThemeData get lightTheme {
    // Inter as primary, system font as Korean fallback
    final baseTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.canvas,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.ink,
        surface: AppColors.canvas,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onPrimary,
        onSurface: AppColors.ink,
        outline: AppColors.hairlineStrong,
        surfaceContainerHighest: AppColors.surfaceStrong,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: AppColors.ink),
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.ink,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(color: AppColors.ink, fontWeight: FontWeight.w600, letterSpacing: -1.92),
        displayMedium: baseTextTheme.displayMedium?.copyWith(color: AppColors.ink, fontWeight: FontWeight.w600, letterSpacing: -1.08),
        displaySmall: baseTextTheme.displaySmall?.copyWith(color: AppColors.ink, fontWeight: FontWeight.w600, letterSpacing: -0.5),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(color: AppColors.ink, fontWeight: FontWeight.w600, letterSpacing: -0.84),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(color: AppColors.ink, fontWeight: FontWeight.w600),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(color: AppColors.ink, fontWeight: FontWeight.w600),
        titleLarge: baseTextTheme.titleLarge?.copyWith(color: AppColors.ink, fontWeight: FontWeight.w600, letterSpacing: -0.5),
        titleMedium: baseTextTheme.titleMedium?.copyWith(color: AppColors.ink, fontWeight: FontWeight.w600),
        titleSmall: baseTextTheme.titleSmall?.copyWith(color: AppColors.ink, fontWeight: FontWeight.w600),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: AppColors.ink, letterSpacing: -0.3),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: AppColors.ink, letterSpacing: -0.2),
        bodySmall: baseTextTheme.bodySmall?.copyWith(color: AppColors.body),
        labelLarge: baseTextTheme.labelLarge?.copyWith(color: AppColors.ink, fontWeight: FontWeight.w500),
        labelMedium: baseTextTheme.labelMedium?.copyWith(color: AppColors.body),
        labelSmall: baseTextTheme.labelSmall?.copyWith(color: AppColors.muted, letterSpacing: 0.88),
      ),

      // Cards — white, hairline border, 12px radius
      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.hairlineStrong),
        ),
        margin: EdgeInsets.zero,
      ),

      // Divider — hairline
      dividerTheme: const DividerThemeData(
        color: AppColors.hairline,
        space: 1,
        thickness: 1,
      ),

      // Elevated Button — black pill, white text
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.surfaceStrong,
          disabledForegroundColor: AppColors.muted,
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, height: 1.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          minimumSize: const Size(0, 40),
        ),
      ),

      // Outlined Button — white card with hairline border
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surfaceCard,
          foregroundColor: AppColors.ink,
          disabledForegroundColor: AppColors.muted,
          elevation: 0,
          side: const BorderSide(color: AppColors.hairlineStrong),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, height: 1.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 9),
          minimumSize: const Size(0, 40),
        ),
      ),

      // Text Button — transparent, ink text
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.ink,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),

      // Filled Button — same as elevated
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.surfaceStrong,
          disabledForegroundColor: AppColors.muted,
          elevation: 0,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, height: 1.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          minimumSize: const Size(0, 40),
        ),
      ),

      // Input — white bg, hairline border, 8px radius
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: GoogleFonts.inter(color: AppColors.muted, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: AppColors.body, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.hairlineStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.hairlineStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.ink, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.semanticError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.semanticError, width: 2),
        ),
      ),

      // Bottom Sheet — white, 16px top radius
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),

      // Bottom Navigation Bar — white bg, hairline top, black selected
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.canvas,
        selectedItemColor: AppColors.ink,
        unselectedItemColor: AppColors.muted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.onPrimary),
        side: const BorderSide(color: AppColors.hairlineStrong, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.onPrimary;
          return AppColors.muted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.surfaceStrong;
        }),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceStrong,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.surfaceStrong,
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.ink),
        secondaryLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.onPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: const StadiumBorder(),
        elevation: 0,
        pressElevation: 0,
        side: BorderSide.none,
      ),

      // ListTile
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        iconColor: AppColors.ink,
        textColor: AppColors.ink,
      ),

      // FloatingActionButton — black
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        shape: CircleBorder(),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        contentTextStyle: GoogleFonts.inter(color: AppColors.onDark, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // PopupMenu
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.canvas,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.hairlineStrong),
        ),
        textStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.ink),
      ),
    );
  }
}
