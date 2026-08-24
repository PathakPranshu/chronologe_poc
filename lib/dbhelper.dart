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
      'title': '',
      'text_data': '',
      'images_loc': [],
    };
  }

  // Change diary text
  // Usage : await DBHelper.changeText('2026-08-24', 'Today was a good day!');
  static Future<void> changeText(String date, String textData) async {
    Map entry = getEntry(date);

    entry['text_data'] = textData;

    await diaryBox.put(date, entry);
  }

  // Change title
  // Usage : await DBHelper.changeTitle('2026-08-24', 'Happy');
  static Future<void> changeTitle(String date, String title) async {
    Map entry = getEntry(date);

    entry['title'] = title;

    await diaryBox.put(date, entry);
  }

  // Add image
  // Usage : await addImage('2026-08-24', 'example/image.jpg');
  static Future<void> addImage(String date, String imageUrl) async {
    Map entry = getEntry(date);

    List imagesList = entry['images_loc'];

    imagesList.add(imageUrl);

    entry['images_loc'] = imagesList;

    await diaryBox.put(date, entry);
  }

  // Delete image
  // Usage : await DBHelper.deleteImage('2026-08-24', 'example/image.jpg');
  static Future<void> deleteImage(String date, String imageUrl) async {
    Map? entry = diaryBox.get(date);

    if (entry == null) {
      return;
    }

    List imagesList = entry['images_loc'];

    for (int i = 0; i < imagesList.length; i++) {
      if (imagesList[i] == imageUrl) {
        imagesList.removeAt(i);
        break;
      }
    }

    entry['images_loc'] = imagesList;

    await diaryBox.put(date, entry);
  }

  // Read full diary entry
  // Usage : Map? entry = DBHelper.getEntry('2026-08-24');
  static Map? readEntry(String date) {
    return diaryBox.get(date);
  }
}