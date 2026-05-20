
import 'package:flutter/material.dart';

class ReportaYaTheme {
  final TextTheme textTheme;

  const ReportaYaTheme(this.textTheme);

  static const _primary = Color(0xFFA27EFF);
  static const _secondary = Color(0xFF6A9FFF);
  static const _accent = Color(0xFF00D1D1);
  static const _success = Color(0xFF4CAF50);
  static const _warning = Color(0xFFFFA500);
  static const _background = Color(0xFFF9F7FF);
  static const _surface = Color(0xFFFFFFFF);
  static const _surfaceVariant = Color(0xFFF0EAFF);
  static const _outline = Color(0xFFCBD5DD);
  static const _textPrimary = Color(0xFF1F1F29);
  static const _textSecondary = Color(0xFF6C757D);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,

      // Brand Colors
      primary: _primary,
      surfaceTint: _primary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE0D0FF),
      onPrimaryContainer: Color(0xFF341A66),

      secondary: _secondary,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFDCEBFF),
      onSecondaryContainer: Color(0xFF0E3C75),

      tertiary: _accent,
      onTertiary: Color(0xFF002929),
      tertiaryContainer: Color(0xFFB7FFFF),
      onTertiaryContainer: Color(0xFF003D3D),

      // Status
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF93000A),

      // Surfaces
      surface: _surface,
      onSurface: _textPrimary,
      onSurfaceVariant: _textSecondary,
      outline: _outline,
      outlineVariant: Color(0xFFE8EEF5),

      shadow: Color(0x1A000000),
      scrim: Color(0x66000000),

      inverseSurface: Color(0xFF2D2D3A),
      onInverseSurface: Color(0xFFF5F5F7),
      inversePrimary: Color(0xFFD5BEFF),

      // Fixed Colors
      primaryFixed: Color(0xFFE0D0FF),
      onPrimaryFixed: Color(0xFF22004D),
      primaryFixedDim: Color(0xFFC7A8FF),
      onPrimaryFixedVariant: Color(0xFF5B32B0),

      secondaryFixed: Color(0xFFDCEBFF),
      onSecondaryFixed: Color(0xFF001C3A),
      secondaryFixedDim: Color(0xFFABCFFF),
      onSecondaryFixedVariant: Color(0xFF245A99),

      tertiaryFixed: Color(0xFFB7FFFF),
      onTertiaryFixed: Color(0xFF001F1F),
      tertiaryFixedDim: Color(0xFF7DF4F4),
      onTertiaryFixedVariant: Color(0xFF006666),

      // Background Layers
      surfaceDim: Color(0xFFEAE7F2),
      surfaceBright: Colors.white,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: Color(0xFFFDFCFF),
      surfaceContainer: Color(0xFFF9F7FF),
      surfaceContainerHigh: Color(0xFFF3EEFF),
      surfaceContainerHighest: Color(0xFFEDE6FF),
    );
  }

  ThemeData light() {
    final scheme = lightScheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      textTheme: textTheme.apply(
        bodyColor: _textPrimary,
        displayColor: _textPrimary,
      ),
      scaffoldBackgroundColor: _background,
      canvasColor: _background,

      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),

      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 1,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(double.infinity, 56),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(double.infinity, 56),
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: scheme.primary,
            width: 2,
          ),
        ),
        hintStyle: TextStyle(
          color: scheme.onSurfaceVariant,
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        selectedColor: scheme.primaryContainer,
        disabledColor: scheme.surfaceContainerLow,
        labelStyle: TextStyle(color: scheme.onSurface),
        secondaryLabelStyle: TextStyle(color: scheme.onPrimaryContainer),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          );
        }),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(
          color: scheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
