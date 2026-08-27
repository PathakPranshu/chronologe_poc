import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color myPrimary = Color(0XFFCB5635);
const Color mySecondary = Color(0XFF758A31);
const Color myOnSurface = Color(0XFF0C172A);
const Color mySurface = Color(0XFFF2F2EA);

class CustomTheme {
  static ThemeData lightThemeData(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      textTheme: buildTextTheme(),
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xffa2391a),
        surfaceTint: Color(0xffa53b1c),
        onPrimary: Color(0xffffffff),
        primaryContainer: Color(0xffc35030),
        onPrimaryContainer: Color(0xfffffbff),
        secondary: Color(0xff50630a),
        onSecondary: Color(0xffffffff),
        secondaryContainer: Color(0xff687c25),
        onSecondaryContainer: Color(0xfffbffe4),
        tertiary: Color(0xff715c00),
        onTertiary: Color(0xffffffff),
        tertiaryContainer: Color(0xffc7a93a),
        onTertiaryContainer: Color(0xff4d3e00),
        error: Color(0xffba1a1a),
        onError: Color(0xffffffff),
        errorContainer: Color(0xffffdad6),
        onErrorContainer: Color(0xff93000a),
        surface: Color(0xfffff8f6),
        onSurface: Color(0xff241916),
        onSurfaceVariant: Color(0xff57423c),
        outline: Color(0xff8b716b),
        outlineVariant: Color(0xffdfc0b8),
        shadow: Color(0xff000000),
        scrim: Color(0xff000000),
        inverseSurface: Color(0xff3a2d2a),
        inversePrimary: Color(0xffffb5a0),
        primaryFixed: Color(0xffffdbd1),
        onPrimaryFixed: Color(0xff3b0900),
        primaryFixedDim: Color(0xffffb5a0),
        onPrimaryFixedVariant: Color(0xff852406),
        secondaryFixed: Color(0xffd4ed87),
        onSecondaryFixed: Color(0xff171e00),
        secondaryFixedDim: Color(0xffb9d06f),
        onSecondaryFixedVariant: Color(0xff3d4d00),
        tertiaryFixed: Color(0xffffe17a),
        onTertiaryFixed: Color(0xff231b00),
        tertiaryFixedDim: Color(0xffe4c453),
        onTertiaryFixedVariant: Color(0xff554500),
        surfaceDim: Color(0xffebd5d0),
        surfaceBright: Color(0xfffff8f6),
        surfaceContainerLowest: Color(0xffffffff),
        surfaceContainerLow: Color(0xfffff1ed),
        surfaceContainer: Color(0xffffe9e4),
        surfaceContainerHigh: Color(0xfffae3de),
        surfaceContainerHighest: Color(0xfff4ded8),
      ),
    );
  }

  static ThemeData darkThemeData(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      textTheme: buildTextTheme(),
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xff6a1700),
        surfaceTint: Color(0xffa53b1c),
        onPrimary: Color(0xffffffff),
        primaryContainer: Color(0xffb94929),
        onPrimaryContainer: Color(0xffffffff),
        secondary: Color(0xff2e3b00),
        onSecondary: Color(0xffffffff),
        secondaryContainer: Color(0xff61751d),
        onSecondaryContainer: Color(0xffffffff),
        tertiary: Color(0xff423500),
        onTertiary: Color(0xffffffff),
        tertiaryContainer: Color(0xff826b00),
        onTertiaryContainer: Color(0xffffffff),
        error: Color(0xff740006),
        onError: Color(0xffffffff),
        errorContainer: Color(0xffcf2c27),
        onErrorContainer: Color(0xffffffff),
        surface: Color(0xfffff8f6),
        onSurface: Color(0xff190f0c),
        onSurfaceVariant: Color(0xff45312c),
        outline: Color(0xff644d47),
        outlineVariant: Color(0xff806761),
        shadow: Color(0xff000000),
        scrim: Color(0xff000000),
        inverseSurface: Color(0xff3a2d2a),
        inversePrimary: Color(0xffffb5a0),
        primaryFixed: Color(0xffb94929),
        onPrimaryFixed: Color(0xffffffff),
        primaryFixedDim: Color(0xff983213),
        onPrimaryFixedVariant: Color(0xffffffff),
        secondaryFixed: Color(0xff61751d),
        onSecondaryFixed: Color(0xffffffff),
        secondaryFixedDim: Color(0xff495c01),
        onSecondaryFixedVariant: Color(0xffffffff),
        tertiaryFixed: Color(0xff826b00),
        onTertiaryFixed: Color(0xffffffff),
        tertiaryFixedDim: Color(0xff665300),
        onTertiaryFixedVariant: Color(0xffffffff),
        surfaceDim: Color(0xffd7c2bd),
        surfaceBright: Color(0xfffff8f6),
        surfaceContainerLowest: Color(0xffffffff),
        surfaceContainerLow: Color(0xfffff1ed),
        surfaceContainer: Color(0xfffae3de),
        surfaceContainerHigh: Color(0xffeed8d3),
        surfaceContainerHighest: Color(0xffe2cdc8),
      ),
    );
  }

  // Text Theme

  static TextTheme buildTextTheme() {
    return TextTheme(
      displayMedium: TextStyle(
          fontFamily: "Fraunces",
          fontWeight: FontWeight(450),
          fontVariations: [
            FontVariation.opticalSize(80),
            FontVariation('SOFT', 24),
            FontVariation("WONK", 0)
          ],
        ),
      displaySmall: TextStyle(
          fontFamily: "Fraunces",
          fontWeight: FontWeight(450),
          fontVariations: [
            FontVariation.opticalSize(76), 
            FontVariation("WONK", 0)
          ],
      ),
      headlineLarge: GoogleFonts.geist(),
      headlineMedium: GoogleFonts.geist(),
      headlineSmall: GoogleFonts.geist(),
      titleLarge: GoogleFonts.geist(),
      titleMedium: GoogleFonts.geist(),
      titleSmall: GoogleFonts.geist(),
      labelLarge: GoogleFonts.geist(),
      labelMedium: GoogleFonts.geist(),
      labelSmall: GoogleFonts.geist(),
      bodyLarge: GoogleFonts.geist(),
      bodyMedium: GoogleFonts.geist(),
      bodySmall: GoogleFonts.geist(),
    );
  }

  static TextStyle? toRobotoItalic(TextStyle? inheritedBase) {
    return inheritedBase?.copyWith(
          fontFamily: "RobotoFlex",
          fontVariations: [
            FontVariation("slnt", -8),
            FontVariation("XTRA", 500),
          ],
    );
  }

  // Mood colours
  static Color getMoodColor(String mood) {
    if (mood == 'Happy') {
      return const Color.fromARGB(255, 255, 203, 70);
    }

    if (mood == 'Calm') {
      return const Color.fromARGB(255, 151, 222, 255);
    }

    if (mood == 'Tired') {
      return const Color.fromARGB(255, 153, 176, 186);
    }

    if (mood == 'Excited') {
      return const Color.fromARGB(255, 245, 148, 184);
    }

    if (mood == 'Reflective') {
      return const Color.fromARGB(255, 188, 156, 247);
    }

    return Colors.white;
  }

}
