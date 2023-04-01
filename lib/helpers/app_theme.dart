import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightTheme() {
  return ThemeData().copyWith(
    colorScheme: lightColorScheme(),
    scaffoldBackgroundColor: const Color.fromARGB(255, 235, 235, 230),
    dividerTheme: const DividerThemeData(color: Colors.black26, thickness: 1),
    textTheme: GoogleFonts.ubuntuTextTheme(), // Ubuntu and Cabin Font finalized
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.black26),
      ),
    ),
    appBarTheme: const AppBarTheme(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(
        color: Colors.black.withAlpha(150),
      ),
      labelStyle: TextStyle(color: Colors.black.withAlpha(150)),
      floatingLabelStyle: TextStyle(color: lightColorScheme().primary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}

ThemeData darkTheme() {
  return ThemeData().copyWith(
    colorScheme: darkColorScheme(),
    scaffoldBackgroundColor: const Color.fromARGB(255, 27, 27, 39),
    dividerTheme: const DividerThemeData(color: Colors.white30, thickness: 1),
    textTheme: GoogleFonts.ubuntuTextTheme().apply(
      bodyColor: Colors.white.withAlpha(220),
      displayColor: Colors.white.withAlpha(220),
    ), // Ubuntu and Cabin Font finalized
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white30),
      ),
    ),
    appBarTheme: const AppBarTheme(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(
        color: Colors.white.withAlpha(150),
      ),
      labelStyle: TextStyle(color: Colors.white.withAlpha(150)),
      floatingLabelStyle: TextStyle(color: darkColorScheme().primary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}

ColorScheme lightColorScheme() {
  return const ColorScheme(
    brightness: Brightness.dark,
    primary: Color.fromARGB(255, 95, 90, 230),
    onPrimary: Colors.white,
    secondary: Colors.orange,
    onSecondary: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    background: Colors.white,
    onBackground: Colors.black,
    surface: Colors.white,
    onSurface: Colors.black,
  );
}

ColorScheme darkColorScheme() {
  return const ColorScheme(
    brightness: Brightness.dark,
    // primary: Color.fromARGB(255, 115, 110, 235),
    primary: Color.fromARGB(255, 95, 90, 230),
    onPrimary: Colors.white,
    secondary: Colors.orange,
    onSecondary: Colors.white,
    error: Colors.red,
    onError: Colors.white70,
    background: Colors.black,
    onBackground: Colors.white,
    surface: Colors.black,
    onSurface: Colors.white,
  );
}
