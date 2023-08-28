import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData ligthThemeData = ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme,
    textTheme: TextTheme(
        bodyLarge: GoogleFonts.lato(color: Colors.black),
        displaySmall: GoogleFonts.lato(color: Colors.black),
        titleLarge: GoogleFonts.lato(color: Colors.black),
        headlineLarge: GoogleFonts.lato(color: Colors.black),
        headlineMedium: GoogleFonts.lato(color: Colors.black),
        headlineSmall: GoogleFonts.lato(color: Colors.black),
        displayMedium: GoogleFonts.comicNeue(color: Colors.black)));
ThemeData darktThemeData = ThemeData(
    useMaterial3: true,
    colorScheme: darkColorScheme,
    textTheme: TextTheme(
        bodyLarge: GoogleFonts.lato(color: Colors.white),
        displaySmall: GoogleFonts.lato(color: Colors.white),
        titleLarge: GoogleFonts.lato(color: Colors.white),
        headlineLarge: GoogleFonts.lato(color: Colors.white),
        headlineMedium: GoogleFonts.lato(color: Colors.white),
        headlineSmall: GoogleFonts.lato(color: Colors.white),
        displayMedium: GoogleFonts.comicNeue(color: Colors.white)));

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF9B00CB),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFFAD7FF),
  onPrimaryContainer: Color(0xFF330045),
  secondary: Color(0xFF6A596C),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFF2DCF3),
  onSecondaryContainer: Color(0xFF241727),
  tertiary: Color(0xFF82524F),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFFFDAD7),
  onTertiaryContainer: Color(0xFF33110F),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  background: Color(0xFFFFFBFF),
  onBackground: Color(0xFF1E1B1E),
  outline: Color(0xFF7E747D),
  onInverseSurface: Color(0xFFF7EFF3),
  inverseSurface: Color(0xFF332F33),
  inversePrimary: Color(0xFFEEB0FF),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF9B00CB),
  outlineVariant: Color(0xFFCFC3CD),
  scrim: Color(0xFF000000),
  surface: Color(0xFFFFF7FB),
  onSurface: Color(0xFF1E1B1E),
  surfaceVariant: Color(0xFFEBDFE9),
  onSurfaceVariant: Color(0xFF4C444C),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFEEB0FF),
  onPrimary: Color(0xFF53006F),
  primaryContainer: Color(0xFF76009B),
  onPrimaryContainer: Color(0xFFFAD7FF),
  secondary: Color(0xFFD5C0D7),
  onSecondary: Color(0xFF3A2C3D),
  secondaryContainer: Color(0xFF514254),
  onSecondaryContainer: Color(0xFFF2DCF3),
  tertiary: Color(0xFFF5B7B3),
  onTertiary: Color(0xFF4C2523),
  tertiaryContainer: Color(0xFF663B38),
  onTertiaryContainer: Color(0xFFFFDAD7),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  background: Color(0xFF1E1B1E),
  onBackground: Color(0xFFE8E0E5),
  outline: Color(0xFF988E97),
  onInverseSurface: Color(0xFF1E1B1E),
  inverseSurface: Color(0xFFE8E0E5),
  inversePrimary: Color(0xFF9B00CB),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFFEEB0FF),
  outlineVariant: Color(0xFF4C444C),
  scrim: Color(0xFF000000),
  surface: Color(0xFF151215),
  onSurface: Color(0xFFCCC4C9),
  surfaceVariant: Color(0xFF4C444C),
  onSurfaceVariant: Color(0xFFCFC3CD),
);
