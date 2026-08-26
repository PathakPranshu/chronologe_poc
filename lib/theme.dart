import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


// App colours
const Color myPrimary = Color(0xFFCB5635);
const Color mySecondary = Color(0xFF758A31);
const Color myOnSurface = Color(0xFF0C172A);
const Color mySurface = Color(0xFFF2F2EA);


class CustomTheme {

  static ThemeData lightThemeData(BuildContext context) {
    return ThemeData(
      useMaterial3: true,

      // Main app colours
      scaffoldBackgroundColor: mySurface,

      colorScheme: ColorScheme.fromSeed(
        seedColor: myPrimary,
        primary: myPrimary,
        secondary: mySecondary,
        surface: mySurface,
      ),

      // App fonts
      textTheme: TextTheme(

        // Big diary titles
        displayLarge: GoogleFonts.fraunces(),
        displayMedium: GoogleFonts.fraunces(),
        displaySmall: GoogleFonts.fraunces(),

        // Normal UI text
        headlineLarge: GoogleFonts.geist(),
        headlineMedium: GoogleFonts.geist(),
        headlineSmall: GoogleFonts.geist(),

        titleLarge: GoogleFonts.geist(),
        titleMedium: GoogleFonts.geist(),
        titleSmall: GoogleFonts.geist(),

        bodyLarge: GoogleFonts.geist(),
        bodyMedium: GoogleFonts.geist(),
        bodySmall: GoogleFonts.geist(),

        labelLarge: GoogleFonts.geist(),
        labelMedium: GoogleFonts.geist(),
        labelSmall: GoogleFonts.geist(),
      ),
    );
  }


  static ThemeData darkThemeData(BuildContext context) {
    return lightThemeData(context);
  }


  // Mood colours
  static Color getMoodColor(String mood) {
    if (mood == 'Happy') {
      return const Color(0xFFFFD978);
    }

    if (mood == 'Calm') {
      return const Color(0xFFA8DDF5);
    }

    if (mood == 'Tired') {
      return const Color(0xFFCDD6DA);
    }

    if (mood == 'Excited') {
      return const Color(0xFFF4B4CC);
    }

    if (mood == 'Reflective') {
      return const Color(0xFFCCBDE8);
    }

    return Colors.white;
  }


  // Weather emojis
  static String getWeatherEmoji(String weather) {
    if (weather == 'Sunny') {
      return '☀️';
    }

    if (weather == 'Cloudy') {
      return '☁️';
    }

    if (weather == 'Light rain') {
      return '🌧️';
    }

    if (weather == 'Hot') {
      return '🌡️';
    }

    if (weather == 'Breezy') {
      return '🍃';
    }

    if (weather == 'Snowfall') {
      return '❄️';
    }

    return '';
  }
}