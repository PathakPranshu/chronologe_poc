import 'package:chronologe_poc/dbhelper.dart';

class SampleEntry {
  static Future<void> populateDatabase() async {
    List<Map> samples = [
      {
        'date': '2026-08-20',
        'mood': 'Reflective',
        'title': 'Planning Ahead (sample 1)',
        'text': "I left home at 9:00 AM and worked from a cafe while light rain fell outside at 23°C. The afternoon was devoted to project planning, followed by a bookstore visit before I reached home at 7:30 PM. News about proposed technology regulations left me thinking about how quickly the industry is changing.",
      },
      {
        'date': '2026-08-21',
        'mood': 'Tired',
        'title': 'Tired Moments (sample 2)',
        'text': "I left home at 8:00 AM and spent the morning on my office commute under light rain and 23°C weather. The afternoon was filled with project meetings before I took a quiet walk in the park. I returned home at 7:30 PM after hearing about a newly announced technology summit, ending the day feeling tired.",
      },
      {
        'date': '2026-08-22',
        'mood': 'Excited',
        'title': 'Games and Good Company (sample 3)',
        'text': "I left home at 11:00 AM for brunch despite the hot 32°C weather. The afternoon disappeared quickly at an arcade, followed by dinner with friends in the evening. I returned home at 10:30 PM excited, and news of an upcoming gaming convention made the day even better.",
      },
      {
        'date': '2026-08-23',
        'mood': 'Calm',
        'title': 'A Breezy Morning (sample 4)',
        'text': "I left home at 8:30 AM for a cycling session in breezy 24°C weather and returned before lunch. The rest of the afternoon was quiet at home, and I finished the evening with a movie. Hearing about a newly opened nature trail made me want to plan another peaceful ride soon.",
      },
      {
        'date': '2026-08-24',
        'mood': 'Excited',
        'title': 'A Busy Start to the Week (sample 5)',
        'text': "I left home at 7:45 AM beneath cloudy 25°C skies and headed to the office. Work kept me occupied all afternoon, followed by grocery shopping before I reached home at 8:00 PM. The revised public transport fares were the main news of the day, and despite the busy schedule I ended it feeling surprisingly excited.",
      },
      {
        'date': '2026-08-25',
        'mood': 'Happy',
        'title': 'A Successful Demo (sample 6)',
        'text': "I left home at 8:00 AM while light rain kept the temperature near 23°C. After morning classes, I spent the afternoon presenting a project demonstration that went better than expected. Dinner outside followed, and I arrived home at 9:00 PM happy, just as a new student innovation event was being announced.",
      },
      {
        'date': '2026-08-26',
        'mood': 'Happy',
        'title': 'Code and Coffee (sample 7)',
        'text': "I left home at 9:00 AM for coffee and some planning while the temperature reached 30°C. I spent the afternoon coding and made good progress before returning at 6:30 PM. Music filled the evening, and news of an upcoming open-source conference gave me another reason to end the day happy.",
      },
      {
        'date': '2026-08-27',
        'mood': 'Reflective',
        'title': 'Reflective Moments (sample 8)',
        'text': "I left home at 8:30 AM and spent the morning at a cafe under sunny 29°C skies. My afternoon was centred around shopping, followed by visiting family in the evening before I returned home at 8:00 PM. India winning a cricket match was the day's big news, and I ended the day feeling reflective about how it had unfolded.",
      },
    ];

    for (Map sample in samples) {
      String date = sample['date'];

      // Do not overwrite an entry that already exists
      if (DBHelper.readEntry(date) == null) {
        await DBHelper.changeTitle(date, sample['title']);

        await DBHelper.changeText(date, sample['text']);

        await DBHelper.changeMood(date, sample['mood']);
      }
    }
  }
}
