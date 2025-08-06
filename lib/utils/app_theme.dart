import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF00639B),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFCDE5FF),
    onPrimaryContainer: Color(0xFF001D33),
    secondary: Color(0xFF51606F),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFD4E4F6),
    onSecondaryContainer: Color(0xFF0D1D2A),
    tertiary: Color(0xFF67587A),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFEDDDFF),
    onTertiaryContainer: Color(0xFF221534),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    background: Color(0xFFFEFBFF),
    onBackground: Color(0xFF1A1C1E),
    surface: Color(0xFFFEFBFF),
    onSurface: Color(0xFF1A1C1E),
    surfaceVariant: Color(0xFFDEE3EB),
    onSurfaceVariant: Color(0xFF42474E),
    outline: Color(0xFF72787E),
    inversePrimary: Color(0xFF96CCFF),
    shadow: Color(0xFF000000),
  );

  static const _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFD0BCFF),
    // Ungu Lavender utama
    onPrimary: Color(0xFF381E72),
    primaryContainer: Color(0xFF4F378B),
    onPrimaryContainer: Color(0xFFEADDFF),
    secondary: Color(0xFFCCC2DC),
    onSecondary: Color(0xFF332D41),
    secondaryContainer: Color(0xFF4A4458),
    onSecondaryContainer: Color(0xFFE8DEF8),
    tertiary: Color(0xFFEFB8C8),
    onTertiary: Color(0xFF492532),
    tertiaryContainer: Color(0xFF633B48),
    onTertiaryContainer: Color(0xFFFFD8E4),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    background: Color(0xFF1C1B1F),
    // Background utama
    onBackground: Color(0xFFE6E1E5),
    surface: Color(0xFF1C1B1F),
    // Warna dasar untuk Card, BottomSheet
    onSurface: Color(0xFFE6E1E5),
    surfaceVariant: Color(0xFF49454F),
    onSurfaceVariant: Color(0xFFCAC4D0),
    outline: Color(0xFF938F99),
    inversePrimary: Color(0xFF6750A4),
    shadow: Color(0xFF000000),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _lightColorScheme,
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
    scaffoldBackgroundColor: _lightColorScheme.background,
    appBarTheme: AppBarTheme(
      backgroundColor: _lightColorScheme.primary,
      foregroundColor: _lightColorScheme.onPrimary,
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _darkColorScheme,
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    scaffoldBackgroundColor: _darkColorScheme.background,
    appBarTheme: AppBarTheme(
      backgroundColor: _darkColorScheme.primaryContainer,
      foregroundColor: _darkColorScheme.onPrimaryContainer,
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}
