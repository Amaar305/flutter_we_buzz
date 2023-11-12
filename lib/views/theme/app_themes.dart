import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/constants.dart';

class AppThemes {
  static final _appBarTheme = AppBarTheme(
    elevation: 0,
    backgroundColor: Colors.transparent,
    shadowColor: Colors.transparent,
    titleTextStyle: GoogleFonts.lato(
      fontSize: 20, // Adjust the font size as needed
      fontWeight: FontWeight.bold,
      letterSpacing: 1.5,
      height: 1.5,
    ),
  );
  static final _textTheme = TextTheme(
    bodyLarge: GoogleFonts.lato(
      fontSize: 17, // Adjust the font size as needed
      fontWeight: FontWeight.normal,
      letterSpacing: 1.5,
      height: 1.5,
    ),
  );

  // DarkTheme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    appBarTheme: _appBarTheme,
    hintColor: Colors.white,
    textTheme: _textTheme,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: kPrimary,
    ),
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: kPrimary,
      secondary: kSecondary,
    ),
  );

  // LightTheme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    appBarTheme: _appBarTheme.copyWith(
      titleTextStyle: GoogleFonts.lato(
        fontSize: 20, // Adjust the font size as needed
        letterSpacing: 1.5,
        height: 1.5,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: _textTheme,

    // BottomNavigationBar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: kDefaultGrey,
      selectedItemColor: kPrimary,
      unselectedItemColor: Colors.black,
    ),
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      background: kDefaultGrey,
      primary: kPrimary,
      secondary: kDefaultGrey,
    ),
  );
}
