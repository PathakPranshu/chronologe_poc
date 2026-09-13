import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Info extends StatefulWidget {
  const Info({super.key});

  @override
  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            leading: IconButton(
              icon: Icon(Icons.close_rounded),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    "ChronoLoge PoC v1.1.0-beta",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Text.rich(
                    TextSpan(
                      text: "This app is an extended PoC for the main ChronoLoge app. The updated version (v1.1.0-beta) is built over the basic PoC(v0.1.0-alpha), and provide bug fixes, some improvements and optimization, and following additional features over the basic app: ",
                      style: Theme.of(context).textTheme.bodyLarge,
                      children: <TextSpan>[
                        TextSpan(text: "\n\t \u2022 Searching through the entries (e.g, title, content, moods)"),
                        TextSpan(text: "\n\t \u2022 Create Weekly Summaries (AI Generated)"),
                        TextSpan(text: "\n\t \u2022 Preferences settings (Theme, and Fonts customization)"),
                        TextSpan(text: "\n\t \u2022 Calendar View shows month's data"),
                        TextSpan(text: "\n\nImprovements and optimization: "),
                        TextSpan(text: "\n \u2022 Menu for photo deletion (prevent accidental clicks)"),
                        TextSpan(text: "\n \u2022 Storage Optimizations"),
                        TextSpan(text: "\n \u2022 Improved and optimized fullscreen image previewer"),
                        TextSpan(text: "\n \u2022 CarouselView image resizing fixed"),
                        TextSpan(text: "\n \u2022 Color Schema correction"),
                        TextSpan(text: "\n\nThankyou for testing the App!"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32,),
                  Text(
                    "Designed by:",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12,),
                  Text(
                    "devlabs_",
                    style: GoogleFonts.instrumentSerif(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize,
                    ),
                  ),
                  const SizedBox(height: 4,),
                  Text(
                    "Lavi Chahar (The Lead)\nMahidhar S Gowda (The Captain)\nPranshu Pathak",
                    style: GoogleFonts.instrumentSerif(
                      color: Theme.of(context).colorScheme.primary,
                      fontStyle: FontStyle.italic,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8,),
                  Text(
                    "\u2022JJSHH \u2022 2026\u2022 v1.1.0 \u2022 ChronoLoge PoC",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.instrumentSerif(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 18,
                    ),
                  ),
const SizedBox(height: 48,),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
