import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightTheme() {
  return ThemeData(
    colorScheme: lightColorScheme(),
    scaffoldBackgroundColor: const Color.fromARGB(255, 235, 235, 230),
    dividerTheme: const DividerThemeData(color: Colors.black26, thickness: 1),
    textTheme: GoogleFonts.ubuntuTextTheme(), // Ubuntu and Cabin Font finalized
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: lightColorScheme().primary,
          // color: Colors.black26,
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.black),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.black.withOpacity(.05),
      hintStyle: TextStyle(
        color: Colors.black.withAlpha(150),
      ),
      labelStyle: TextStyle(color: Colors.black.withAlpha(150)),
      floatingLabelStyle: TextStyle(color: lightColorScheme().primary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: const Color.fromARGB(255, 235, 235, 230),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
    ),
  );
}

ThemeData darkTheme() {
  return ThemeData(
    colorScheme: darkColorScheme(),
    scaffoldBackgroundColor: const Color.fromARGB(255, 27, 27, 39),
    dividerTheme: const DividerThemeData(color: Colors.white30, thickness: 1),
    textTheme: GoogleFonts.ubuntuTextTheme().apply(
      bodyColor: Colors.white.withAlpha(220),
      displayColor: Colors.white.withAlpha(220),
    ), // Ubuntu and Cabin Font finalized
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: darkColorScheme().primary,
          // color: Colors.white30,
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.white.withOpacity(.1),
      hintStyle: TextStyle(
        color: Colors.white.withAlpha(150),
      ),
      labelStyle: TextStyle(color: Colors.white.withAlpha(150)),
      floatingLabelStyle: TextStyle(color: darkColorScheme().primary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: const Color.fromARGB(255, 27, 27, 39),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
    ),
  );
}

ColorScheme lightColorScheme() {
  return const ColorScheme(
      brightness: Brightness.light,
      primary: Color.fromARGB(255, 110, 80, 210),
      onPrimary: Colors.white,
      secondary: Colors.orange,
      onSecondary: Colors.white,
      error: Colors.red,
      onError: Colors.white,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black);
}

ColorScheme darkColorScheme() {
  return const ColorScheme(
    brightness: Brightness.dark,
    // primary: Color.fromARGB(255, 110, 80, 210),
    primary: Color.fromARGB(255, 120, 100, 220),
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
