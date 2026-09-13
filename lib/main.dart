import 'dart:async';

import 'package:chronologe_poc/dbhelper.dart';
import 'package:chronologe_poc/providers.dart';
import 'package:chronologe_poc/samples.dart';
import 'package:chronologe_poc/screens/preferences.dart';
import 'package:chronologe_poc/screens/summaryview.dart';
import 'package:chronologe_poc/screens/timeline.dart';
import 'package:chronologe_poc/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  // Make Flutter ready
  WidgetsFlutterBinding.ensureInitialized();
  // Make database ready
  await DBHelper.init();

  await SampleEntry.populateDatabase();

  runApp(ProviderScope(child: const MainApp()));

  _prefetchFonts();
}

void _prefetchFonts() {
  GoogleFonts.geist();
  GoogleFonts.literata();
  GoogleFonts.comicNeue();
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      theme: CustomTheme.lightThemeData(context),
      darkTheme: CustomTheme.darkThemeData(context),
      themeMode: ref.watch(themeProvider),
      home: Timeline(),
    );
  }
}
