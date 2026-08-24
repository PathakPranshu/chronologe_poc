import 'package:hive_ce_flutter/hive_ce_flutter.dart';

class DBHelper {
  static late Box diaryBox;

  // Start database
  static Future<void> init() async {
    await Hive.initFlutter();
    diaryBox = await Hive.openBox('diary');
  }

  // Get existing entry or make a blank one
  static Map getEntry(String date) {
    return diaryBox.get(date) ?? {
      'date': date,
      'text_data': '',
      'media_loc': [],
      'mood': '',
      'weather': {
        'category': '',
        'temp': '',
      }
    };
  }

  // Change diary text
  // Usage : await DBHelper.changeText('2026-08-24', 'Today was a good day!');
  static Future<void> changeText(String date, String textData) async {
    Map entry = getEntry(date);

    entry['text_data'] = textData;

    await diaryBox.put(date, entry);
  }

  // Change mood
  // Usage : await DBHelper.changeMood('2026-08-24', 'Happy');
  static Future<void> changeMood(String date, String mood) async {
    Map entry = getEntry(date);

    entry['mood'] = mood;

    await diaryBox.put(date, entry);
  }

  // Change weather
  // Usage : await DBHelper.changeWeather('2026-08-24', 'Sunny', '25°C');
  static Future<void> changeWeather(String date, String category, String temp) async {
  Map entry = getEntry(date);

  entry['weather'] = {
    'category': category,
    'temp': temp,
  };

  await diaryBox.put(date, entry);
}

  // Add image
  // Usage : await addImage('2026-08-24', 'example/image.jpg');
  static Future<void> addImage(String date, String imageUrl) async {
    Map entry = getEntry(date);

    List mediaList = entry['media_loc'];

    mediaList.add(imageUrl);

    entry['media_loc'] = mediaList;

    await diaryBox.put(date, entry);
  }

  // Delete image
  // Usage : await DBHelper.deleteImage('2026-08-24', 'example/image.jpg');
  static Future<void> deleteImage(String date, String imageUrl) async {
    Map? entry = diaryBox.get(date);

    if (entry == null) {
      return;
    }

    List mediaList = entry['media_loc'];

    for (int i = 0; i < mediaList.length; i++) {
      if (mediaList[i] == imageUrl) {
        mediaList.removeAt(i);
        break;
      }
    }

    entry['media_loc'] = mediaList;

    await diaryBox.put(date, entry);
  }

  // Read full diary entry
  // Usage : Map? entry = DBHelper.getEntry('2026-08-24');
  static Map? readEntry(String date) {
    return diaryBox.get(date);
  }
}