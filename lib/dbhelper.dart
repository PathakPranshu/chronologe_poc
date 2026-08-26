import 'dart:typed_data';
import 'package:flutter/material.dart';
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
      'images_data': [],
      'mood': '',
      'weather': {
        'category': '',
        'temp': '',
      },
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
  // Usage : await DBHelper.changeTitle('2026-08-24', 'New Title');
  static Future<void> changeTitle(String date, String title) async {
    Map entry = getEntry(date);

    entry['title'] = title;

    await diaryBox.put(date, entry);
  }

  // Change mood
  // Usage : await DBHelper.changeMood('2026-08-24', 'Happy
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
  static Future<void> addImage(String date, Uint8List imageData) async {
    Map entry = getEntry(date);

    List imagesList = entry['images_data'] ?? [];

    imagesList.add(imageData);

    entry['images_data'] = imagesList;

    await diaryBox.put(date, entry);
  }

  // Delete image
  // Usage : await DBHelper.deleteImage('2026-08-24', 'example/image.jpg');
  static Future<void> deleteImage(String date, int index) async {
    Map entry = getEntry(date);

    List imagesList = entry['images_data'];

    imagesList.removeAt(index);

    entry['images_data'] = imagesList;

    await diaryBox.put(date, entry);
  }

  // Read full diary entry
  // Usage : Map? entry = DBHelper.getEntry('2026-08-24');
  static Map? readEntry(String date) {
    return diaryBox.get(date);
  }

  // Get date, mood and weather for every day in a month
  // Usage : List<Map> monthData = DBHelper.getMonthData(2026, 8);
  static List<Map> getMonthData(int year, int month) {
    List<Map> monthData = [];

    int days = DateUtils.getDaysInMonth(year, month);

    for (int day = 1; day <= days; day++) {
      String date = DateTime(year, month, day)
          .toIso8601String()
          .substring(0, 10);

      Map? entry = readEntry(date);

      monthData.add({
        'date': date,
        'mood': entry?['mood'] ?? '',
        'weather': entry?['weather'] ?? {
          'category': '',
          'temp': '',
        },
      });
    }

    return monthData;
  }
}