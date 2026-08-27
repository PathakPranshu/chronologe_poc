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
                    "ChronoLoge PoC",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Text.rich(
                    TextSpan(
                      text: "This app is an MVP(Minimal Viable Product)/PoC(Proof of Concept) for Chronologe (The Digital Diary application). This app tests basic main functionalities of a Diary application and provide following features: ",
                      style: Theme.of(context).textTheme.bodyLarge,
                      children: <TextSpan>[
                        TextSpan(text: "\n\t \u2022 Basic Diary creation capability (Adding title and contents for a day)"),
                        TextSpan(text: "\n\t \u2022 Upload and manage 'Photos' for the day"),
                        TextSpan(text: "\n\t \u2022 View and edit diary entries (including photos)"),
                        TextSpan(text: "\n\t \u2022 Calendar view for finding entries of specific day"),
                        TextSpan(text: "\n\t \u2022 Autosaving data capability"),
                        TextSpan(text: "\n\nThis app also explores various challenges and concepts, like setting up and interacting with Database, real-time data storage and modification in the app's internal storage(for photos), setting up calendar view for entries retrieval."),
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
                    "team devlabs_",
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
                    "______ JJSHH \u2022 2026 ______",
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
