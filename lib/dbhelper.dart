import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

class DBHelper {
  static late Box diaryBox;

  // Start database
  static Future<void> init() async {
    await Hive.initFlutter();

    diaryBox = await Hive.openBox('diary');
  }

  // Get existing entry or create a blank entry
  static Map<String, dynamic>? getEntry(
    String date, {
    bool readOnly = false,
  }) {
    final rawData = diaryBox.get(date);

    if (rawData != null) {
      return Map<String, dynamic>.from(rawData);
    }

    if (!readOnly) {
      return {
        'date': date,
        'title': '',
        'text_data': '',
        'images_data': [],
        'images_loc': [],
        'mood': '',
      };
    }

    return null;
  }

  // Read full diary entry safely
  static Map<String, dynamic>? readEntry(String date) {
    final rawData = diaryBox.get(date);

    if (rawData == null) {
      return null;
    }

    return Map<String, dynamic>.from(rawData);
  }

  // Change diary text
  static Future<void> changeText(
    String date,
    String textData,
  ) async {
    final Map<String, dynamic>? entry = getEntry(date);

    if (entry == null) {
      return;
    }

    entry['text_data'] = textData;

    await diaryBox.put(date, entry);
  }

  // Change title
  static Future<void> changeTitle(
    String date,
    String title,
  ) async {
    final Map<String, dynamic>? entry = getEntry(date);

    if (entry == null) {
      return;
    }

    entry['title'] = title;

    await diaryBox.put(date, entry);
  }

  // Change mood
  static Future<void> changeMood(
    String date,
    String mood,
  ) async {
    final Map<String, dynamic>? entry = getEntry(date);

    if (entry == null) {
      return;
    }

    entry['mood'] = mood;

    await diaryBox.put(date, entry);
  }

  // Add image
  static Future<void> addImage(
    String date,
    String imageUrl,
  ) async {
    final Map<String, dynamic>? entry = getEntry(date);

    if (entry == null) {
      return;
    }

    final List<String> imagesList =
        (entry['images_loc'] as List?)
                ?.cast<String>()
                .toList() ??
            <String>[];

    imagesList.add(imageUrl);

    entry['images_loc'] = imagesList;

    await diaryBox.put(date, entry);
  }

  // Delete image
  static Future<void> deleteImage(
    String date,
    String imageUrl,
  ) async {
    final Map<String, dynamic>? entry = readEntry(date);

    if (entry == null) {
      return;
    }

    final List<String> imagesList =
        (entry['images_loc'] as List?)
                ?.cast<String>()
                .toList() ??
            <String>[];

    imagesList.remove(imageUrl);

    entry['images_loc'] = imagesList;

    await diaryBox.put(date, entry);
  }

  // Get all diary entries sorted newest to oldest
  static List<Map<String, dynamic>>
      getAllEntriesNewestFirst() {
    final List<String> keys =
        diaryBox.keys.cast<String>().toList();

    keys.sort((a, b) => b.compareTo(a));

    return keys
        .map(
          (key) => Map<String, dynamic>.from(
            diaryBox.get(key),
          ),
        )
        .toList();
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
        'entry': entry
      });
    }

    return monthData;
  }
}