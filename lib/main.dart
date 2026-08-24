import 'package:chronologe_poc/screens/timeline.dart';
import 'package:chronologe_poc/theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: CustomTheme.lightThemeData(context),
      darkTheme: CustomTheme.darkThemeData(context),
      home: Timeline(),
    );
  }
}
