import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitflow/core/theme/hf_colors.dart';
import 'package:habitflow/core/theme/hf_radius.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/core/theme/hf_typography.dart';
import 'package:habitflow/core/theme/theme_extensions.dart';

/// [HFTheme] is the entry point for the HabitFlow theme system.
class HFTheme {
  static TextTheme _buildTextTheme(Color color) {
    return TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: HFTypography.headingXL,
        fontWeight: HFTypography.weightBold,
        color: color,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: HFTypography.headingL,
        fontWeight: HFTypography.weightBold,
        color: color,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: HFTypography.headingM,
        fontWeight: HFTypography.weightSemiBold,
        color: color,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: HFTypography.headingS,
        fontWeight: HFTypography.weightSemiBold,
        color: color,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: HFTypography.body,
        fontWeight: HFTypography.weightRegular,
        color: color,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: HFTypography.caption,
        fontWeight: HFTypography.weightRegular,
        color: color,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: HFTypography.small,
        fontWeight: HFTypography.weightMedium,
        color: color,
      ),
    );
  }

  static const HFThemeExtension _sharedExtension = HFThemeExtension(
    lifeAreaHealth: Color(0xFFEF4444),
    lifeAreaLearning: Color(0xFF3B82F6),
    lifeAreaDiscipline: Color(0xFF6B7280),
    lifeAreaFamily: Color(0xFF10B981),
    lifeAreaFinance: Color(0xFF22C55E),
    lifeAreaFitness: Color(0xFFF97316),
    lifeAreaSpiritual: Color(0xFF8B5CF6),
    lifeAreaCreativity: Color(0xFFF59E0B),
    lifeAreaSocial: Color(0xFF14B8A6),
    xpColor: Color(0xFF6366F1),
    levelColor: Color(0xFFF59E0B),
    rewardColor: Color(0xFFFACC15),
  );

  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark => _buildTheme(Brightness.dark);
  static ThemeData get kids => _buildKidsTheme();

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: HFColors.primary,
      brightness: brightness,
      primary: HFColors.primary,
      secondary: HFColors.secondary,
      surface: isDark ? HFColors.darkSurface : HFColors.surface,
      error: HFColors.error,
      onPrimary: HFColors.textOnPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? HFColors.darkBackground : HFColors.background,
      textTheme: _buildTextTheme(isDark ? Colors.white : HFColors.textPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? HFColors.darkBackground : HFColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: HFTypography.headingS,
          fontWeight: HFTypography.weightSemiBold,
          color: isDark ? Colors.white : HFColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: HFRadius.cardBorderRadius,
        ),
        color: colorScheme.surface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: HFColors.primary,
          foregroundColor: HFColors.textOnPrimary,
          minimumSize: const Size(double.infinity, 48),
          shape: const RoundedRectangleBorder(
            borderRadius: HFRadius.buttonBorderRadius,
          ),
          textStyle: GoogleFonts.inter(
            fontSize: HFTypography.body,
            fontWeight: HFTypography.weightMedium,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark 
          ? Colors.white.withAlpha(13) // ~0.05 opacity
          : Colors.black.withAlpha(5),  // ~0.02 opacity
        border: const OutlineInputBorder(
          borderRadius: HFRadius.buttonBorderRadius,
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: HFSpacing.m,
          vertical: HFSpacing.m,
        ),
      ),
      extensions: const [_sharedExtension],
    );
  }

  static ThemeData _buildKidsTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFFFEB3B), // Vibrant Yellow
      brightness: Brightness.light,
      primary: const Color(0xFFFFC107), // Amber
      secondary: const Color(0xFF4CAF50), // Green
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFFFFDE7), // Light Yellow
      textTheme: _buildTextTheme(HFColors.textPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFFFFDE7),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: HFTypography.headingM,
          fontWeight: HFTypography.weightBold,
          color: HFColors.textPrimary,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32)), // More rounded
        ),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 56),
          shape: const StadiumBorder(),
          elevation: 4,
        ),
      ),
      extensions: const [_sharedExtension],
    );
  }
}
