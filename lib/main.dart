import 'package:chronologe_poc/dbhelper.dart';
import 'package:chronologe_poc/screens/timeline.dart';
import 'package:chronologe_poc/sampleentry.dart';
import 'package:chronologe_poc/theme.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  // Make Flutter ready
  WidgetsFlutterBinding.ensureInitialized();
  // Make database ready
  await DBHelper.init();
  // Populate database with sample data
  await SampleEntry.populateDatabase();
  // Start app
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
