import 'package:flutter/material.dart';
import 'package:chronologe_poc/dbhelper.dart';
import 'package:chronologe_poc/theme.dart';
import 'package:chronologe_poc/screens/entry.dart';

class Timeline extends StatefulWidget {
  const Timeline({super.key});

  @override
  State<Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Map> monthData = [];

  @override
  void initState() {
    super.initState();

    // Load August 2026 from database
    monthData = DBHelper.getMonthData(2026, 8);
  }

  @override
  Widget build(BuildContext context) {

    // Find which weekday August 1 starts on
    int blankSpaces = DateTime(2026, 8, 1).weekday - 1;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App title
              Center(child: Text('Your ChronoLoge', style: Theme.of(context).textTheme.displaySmall)),

              const SizedBox(height: 35),

              // Month title
              Text('August 2026', style: Theme.of(context).textTheme.headlineLarge),

              const SizedBox(height: 10),

              // Test case description
              Text(
                'Select a day to open its diary test case.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),

              const SizedBox(height: 30),

              // Weekday names
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Mon', style: Theme.of(context).textTheme.titleSmall),
                  Text('Tue', style: Theme.of(context).textTheme.titleSmall),
                  Text('Wed', style: Theme.of(context).textTheme.titleSmall),
                  Text('Thu', style: Theme.of(context).textTheme.titleSmall),
                  Text('Fri', style: Theme.of(context).textTheme.titleSmall),
                  Text('Sat', style: Theme.of(context).textTheme.titleSmall),
                  Text('Sun', style: Theme.of(context).textTheme.titleSmall),
                ],
              ),

              const SizedBox(height: 15),

              // Calendar
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),

                crossAxisCount: 7,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.7,

                children: [
                  // Add empty boxes before the first day of the month
                  for (int i = 0; i < blankSpaces; i++)
                    const SizedBox(),

                  // Loop through every diary entry in the month
                  for (Map entry in monthData)
                    GestureDetector(
                    // Open the entry page when the day is clicked
                    onTap: () async{
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Entry(
                            date: entry['date'],
                          ),
                        ),
                      );
                      // Reload the calendar data when we return
                      setState(() {
                        monthData = DBHelper.getMonthData(2026, 8);
                      });
                    },
                    // One calendar day box
                    child: Container(
                      decoration: BoxDecoration(
                        // Background colour is based on the mood
                        color: CustomTheme.getMoodColor(entry['mood']),
                        // Rounded corners
                        borderRadius: BorderRadius.circular(15),
                        // Small border around each day
                        border: Border.all(
                          color: Colors.black12,
                        ),
                      ),

                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Show the day number
                          Text(
                            DateTime.parse(entry['date']).day.toString(),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),

                          const SizedBox(height: 8),

                          // Show weather emoji based on the weather category
                          Text(
                            CustomTheme.getWeatherEmoji(entry['weather']['category']),
                            style: const TextStyle(
                              fontSize: 22,
                            ),
                          ),
                        ]
                      ),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 50),

              const Divider(),

              // Mood Text
              Text('Mood', style: Theme.of(context).textTheme.titleLarge,),

              const SizedBox(height: 10),

              // Mood legend
              Wrap(
                spacing: 15,
                runSpacing: 10,

                children: [
                  for (String mood in [
                    'Happy',
                    'Calm',
                    'Tired',
                    'Excited',
                    'Reflective',
                  ])
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 16,
                          height: 16,

                          decoration: BoxDecoration(
                            color: CustomTheme.getMoodColor(mood),
                            shape: BoxShape.circle,
                          ),
                        ),

                        const SizedBox(width: 5),

                        Text(mood),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 20),

              // Mood Text
              Text('Weather', style: Theme.of(context).textTheme.titleLarge),

              const SizedBox(height: 10),

              // Weather legend
              Wrap(
                spacing: 18,
                runSpacing: 12,

                children: [
                  for (String weather in [
                    'Sunny',
                    'Cloudy',
                    'Light rain',
                    'Hot',
                    'Breezy',
                    'Snowfall',
                  ])
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          CustomTheme.getWeatherEmoji(weather),
                        ),

                        const SizedBox(width: 5),

                        Text(weather),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}