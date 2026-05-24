import 'package:flutter/material.dart';

import 'colors.dart';
import 'dimensions.dart';

class ReportaYaTheme {
  final TextTheme textTheme;

  const ReportaYaTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,

      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE7DBFF),
      onPrimaryContainer: Color(0xFF3E1D78),

      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFDDE9FF),
      onSecondaryContainer: Color(0xFF133B73),

      tertiary: AppColors.accent,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFB8FFFF),
      onTertiaryContainer: Color(0xFF003737),

      error: AppColors.error,
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),

      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,

      outline: AppColors.outline,
      outlineVariant: Color(0xFFF0F0F5),

      shadow: Color(0x14000000),
      scrim: Color(0x66000000),

      inverseSurface: Color(0xFF2A2A35),
      onInverseSurface: Colors.white,
      inversePrimary: Color(0xFFD6C2FF),

      surfaceTint: AppColors.primary,

      primaryFixed: Color(0xFFE7DBFF),
      onPrimaryFixed: Color(0xFF22004D),
      primaryFixedDim: Color(0xFFC6A9FF),
      onPrimaryFixedVariant: Color(0xFF5B32B0),

      secondaryFixed: Color(0xFFDDE9FF),
      onSecondaryFixed: Color(0xFF001D3A),
      secondaryFixedDim: Color(0xFFA9CCFF),
      onSecondaryFixedVariant: Color(0xFF245A99),

      tertiaryFixed: Color(0xFFB8FFFF),
      onTertiaryFixed: Color(0xFF001F1F),
      tertiaryFixedDim: Color(0xFF77F0F0),
      onTertiaryFixedVariant: Color(0xFF006666),

      surfaceDim: Color(0xFFEAE7F2),
      surfaceBright: Colors.white,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: Color(0xFFFCFBFF),
      surfaceContainer: AppColors.background,
      surfaceContainerHigh: Color(0xFFF2EEFA),
      surfaceContainerHighest: Color(0xFFECE7F7),
    );
  }

  ThemeData light() {

    final scheme = lightScheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,

      textTheme: textTheme.copyWith(

        headlineLarge: textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),

        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),

        titleLarge: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),

        bodyLarge: textTheme.bodyLarge?.copyWith(
          color: AppColors.textPrimary,
        ),

        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(double.infinity, 56),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusLarge,
            ),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F7),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),

        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusMedium,
          ),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusMedium,
          ),
          borderSide: const BorderSide(
            color: AppColors.outline,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusMedium,
          ),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusXL,
          ),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}