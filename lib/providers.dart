import 'package:chronologe_poc/screens/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  static final _themekey = 'selected_theme_mode';
  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.system;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeKey = prefs.getInt(_themekey);
    if (savedThemeKey != null) {
      state = ThemeMode.values[savedThemeKey];
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themekey, mode.index);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  () => ThemeNotifier(),
);

@immutable
class CustomFonts {
  const CustomFonts({this.title, this.body, this.value});

  final TextStyle? title;

  final TextStyle? body;

  final ChosenFont? value;
}

class CustomFontNotifier extends Notifier<CustomFonts> {
  static final _fontKey = 'selected_font_style';

  CustomFonts defaultFonts = CustomFonts(value: ChosenFont.DEFAULT);
  CustomFonts fancyFonts = CustomFonts(
    title: GoogleFonts.literata(fontStyle: FontStyle.italic),
    body: GoogleFonts.comicNeue(),
    value: ChosenFont.FANCY
  );

  @override
  CustomFonts build() {
    _loadDefaultFonts();
    return defaultFonts;
  }

  Future<void> _loadDefaultFonts() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedFonts = prefs.getString(_fontKey);
    state = selectedFonts == 'FANCY' ? fancyFonts : defaultFonts;
  }

  Future<void> setCustomFonts(ChosenFont font) async {
    state = font.name == 'FANCY' ? fancyFonts : defaultFonts;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontKey, font.name);
  }
}

final customFontsProvider = NotifierProvider<CustomFontNotifier, CustomFonts>(
  () => CustomFontNotifier(),
);
