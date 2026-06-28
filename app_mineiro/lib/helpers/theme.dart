// Light Mode
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

ThemeData themeData(BuildContext context) {
  return ThemeData(
    appBarTheme: AppBarTheme(color: Colors.transparent, elevation: 0),
    primaryColor: kPrimaryLightColor,
    primaryColorDark: kPrimaryDarkColor,
    hintColor: kFontSecondaryLightColor,
    cardColor: kCardLightColor,
    brightness: Brightness.light,
    textSelectionTheme: TextSelectionThemeData(cursorColor: kPrimaryLightColor),
    unselectedWidgetColor: kUnselectedLightColor,
    scaffoldBackgroundColor: kBackgroundLightColor,
    iconTheme: IconThemeData(color: kBackgroundDarkColor),
    primaryIconTheme: IconThemeData(color: kBackgroundDarkColor),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    indicatorColor: kPrimaryLightColor,
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
    ),
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        color: kFontPrimaryLightColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.poppins(
        color: kFontPrimaryLightColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.poppins(
        color: kFontPrimaryLightColor,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: GoogleFonts.poppins(
        color: kFontPrimaryLightColor,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: GoogleFonts.poppins(
        color: kFontPrimaryLightColor,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: GoogleFonts.poppins(
        color: kFontPrimaryLightColor,
        fontSize: 16.0,
      ),
      bodyMedium: GoogleFonts.openSans(
        color: kFontPrimaryLightColor,
        fontSize: 14.0,
      ),
      titleMedium: GoogleFonts.openSans(
        color: kFontSecondaryLightColor,
        fontSize: 14.0,
      ),
      titleSmall: GoogleFonts.openSans(
        color: kFontSecondaryLightColor,
        fontSize: 12.0,
      ),
      labelLarge: GoogleFonts.roboto(
        color: kBackgroundLightColor,
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
      ),
    ),

    //  colorScheme: ColorScheme(surface: kBackgroundLightColor),
    //colorScheme: ColorScheme(error: kErrorLightColor),
    //colorScheme: ColorScheme.fromSwatch().copyWith(surface: kBackgroundLightColor),
  );
}

/// Dark Mode
ThemeData darkThemeData(BuildContext context) {
  return ThemeData(
    appBarTheme: AppBarTheme(color: Colors.transparent, elevation: 0),
    primaryColor: kPrimaryLightColor,
    primaryColorDark: kPrimaryDarkColor,
    hintColor: kFontSecondaryDarkColor,
    cardColor: kCardDarkColor,
    brightness: Brightness.dark,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: kPrimaryDarkColor,
    ),
    unselectedWidgetColor: kUnselectedDarkColor,
    scaffoldBackgroundColor: kBackgroundDarkColor,
    iconTheme: IconThemeData(color: kPrimaryLightColor),
    primaryIconTheme: IconThemeData(color: kPrimaryLightColor),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    indicatorColor: kPrimaryDarkColor,
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
    ),
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        color: kFontPrimaryDarkColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.poppins(
        color: kFontPrimaryDarkColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.poppins(
        color: kFontPrimaryDarkColor,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: GoogleFonts.poppins(
        color: kFontPrimaryDarkColor,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: GoogleFonts.poppins(
        color: kFontPrimaryDarkColor,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: GoogleFonts.poppins(
        color: kFontPrimaryDarkColor,
        fontSize: 16.0,
      ),
      bodyMedium: GoogleFonts.openSans(
        color: kFontPrimaryDarkColor,
        fontSize: 14.0,
      ),
      titleMedium: GoogleFonts.openSans(
        color: kFontSecondaryDarkColor,
        fontSize: 14.0,
      ),
      titleSmall: GoogleFonts.openSans(
        color: kFontSecondaryDarkColor,
        fontSize: 12.0,
      ),
      labelLarge: GoogleFonts.roboto(
        color: kFontPrimaryDarkColor,
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
      ),
    ),
    // colorScheme: ColorScheme(surface: kBackgroundDarkColor),
    //colorScheme: ColorScheme(error: kErrorDarkColor),
    //colorScheme: ColorScheme.fromSwatch().copyWith(surface: kBackgroundDarkColor),
  );
}
