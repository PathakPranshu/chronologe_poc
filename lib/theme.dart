import 'package:flutter/material.dart';


const Color myPrimary = Color(0XFFCB5635);
const Color mySecondary= Color(0XFF758A31);
const Color myOnSurface = Color(0XFF0C172A);
const Color mySurface = Color(0XFFF2F2EA);

class CustomTheme {
  static ThemeData lightThemeData(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      );
  }

  static ThemeData darkThemeData(BuildContext context) {
    return ThemeData(useMaterial3: true);
  }
}
