import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_pandaa/theme/app_colors.dart';

abstract final class AppTheme {
  // Tighter radii than a consumer app — ThokBazaar reads like a ledger /
  // business dashboard, so surfaces are more rectangular and data-dense.
  static const double radiusSm = 10;
  static const double radiusLg = 16;
  static const double radiusCard = 14;
  static const double spacingMd = 16;
  static const double spacingLg = 24;

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgBottom,
      colorScheme: ColorScheme.light(
        primary: AppColors.teal,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        onSurface: AppColors.text,
        outline: AppColors.borderInput,
        error: AppColors.danger,
      ),
    );

    return base.copyWith(
      textTheme: _textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.header,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.ibmPlexSans(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: AppColors.borderInput),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: AppColors.borderInput),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
        ),
        hintStyle: GoogleFonts.ibmPlexSans(color: AppColors.textLight, fontSize: 14),
        labelStyle: GoogleFonts.ibmPlexSans(color: AppColors.textLight, fontSize: 12),
        floatingLabelStyle: GoogleFonts.ibmPlexSans(
          color: AppColors.teal,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.tealDark,
        contentTextStyle: GoogleFonts.ibmPlexSans(color: Colors.white, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
      ),
    );
  }

  static TextTheme get _textTheme {
    return TextTheme(
      headlineLarge: GoogleFonts.ibmPlexSans(
        fontSize: 27,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
        letterSpacing: -0.4,
      ),
      titleLarge: GoogleFonts.ibmPlexSans(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
      titleMedium: GoogleFonts.ibmPlexSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      bodyLarge: GoogleFonts.ibmPlexSans(fontSize: 16, color: AppColors.text, height: 1.5),
      bodyMedium: GoogleFonts.ibmPlexSans(fontSize: 14, color: AppColors.textMuted, height: 1.55),
      bodySmall: GoogleFonts.ibmPlexSans(fontSize: 12, color: AppColors.textLight, height: 1.5),
      labelLarge: GoogleFonts.ibmPlexSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  /// Brand wordmark style. (Name kept for continuity; ThokBazaar's wordmark is
  /// IBM Plex Sans, not a serif.)
  static TextStyle get brandSerif => GoogleFonts.ibmPlexSans(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
        letterSpacing: -0.4,
      );

  static TextStyle get link => GoogleFonts.ibmPlexSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.teal,
      );

  /// Monospace style for numeric/ledger data — prices, quantities, order
  /// numbers, running balances. Tabular figures keep columns aligned.
  static TextStyle mono({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.text,
    double? letterSpacing,
  }) {
    return GoogleFonts.ibmPlexMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }
}
