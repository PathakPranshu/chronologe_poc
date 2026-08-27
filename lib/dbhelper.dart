import 'package:hive_ce_flutter/hive_ce_flutter.dart';

class DBHelper {
  static late Box diaryBox;

  // Start database
  static Future<void> init() async {
    await Hive.initFlutter();
    diaryBox = await Hive.openBox('diary');
  }

  // Get existing entry or make a blank one safely clone-mapped
  static Map<String, dynamic>? getEntry(String date, {bool readOnly = false}) {
    final rawData = diaryBox.get(date);
    if (rawData != null) {
      return Map<String, dynamic>.from(rawData);
    }
    if (rawData == null && !readOnly) {
      return {
        'date': date,
        'title': '',
        'text_data': '',
        'images_data': [],
        'mood': '',
      };
    }
  }

  // Read full diary entry safely without default fallbacks
  static Map<String, dynamic>? readEntry(String date) {
    final rawData = diaryBox.get(date);
    if (rawData == null) return null;
    return Map<String, dynamic>.from(rawData);
  }

  // Change diary text
  static Future<void> changeText(String date, String textData) async {
    Map<String, dynamic>? entry = getEntry(date);
    entry!['text_data'] = textData;
    await diaryBox.put(date, entry);
  }

  // Change title
  static Future<void> changeTitle(String date, String title) async {
    Map<String, dynamic>? entry = getEntry(date);
    entry!['title'] = title;
    await diaryBox.put(date, entry);
  }

  // Change mood
  // Usage : await DBHelper.changeMood('2026-08-24', 'Happy
  static Future<void> changeMood(String date, String mood) async {
    Map<String, dynamic>? entry = getEntry(date);

    entry!['mood'] = mood;

    await diaryBox.put(date, entry);
  }

  // Add image
  static Future<void> addImage(String date, String imageUrl) async {
    Map<String, dynamic>? entry = getEntry(date);

    // SAFE CASTING: Replaces List<String>.from to prevent dynamic cast errors
    List<String> imagesList =
        (entry!['images_loc'] as List?)?.cast<String>().toList() ?? <String>[];

    imagesList.add(imageUrl);
    entry['images_loc'] = imagesList;

    await diaryBox.put(date, entry);
  }

  // Delete image
  static Future<void> deleteImage(String date, String imageUrl) async {
    Map<String, dynamic>? entry = readEntry(date);
    if (entry == null) return;

    // SAFE CASTING: Safely extract and mutate image references
    List<String> imagesList =
        (entry['images_loc'] as List?)?.cast<String>().toList() ?? <String>[];
    imagesList.remove(imageUrl);
    entry['images_loc'] = imagesList;

    await diaryBox.put(date, entry);
  }

  // Get all diary entries sorted from NEWEST to OLDEST (e.g. 2026-08-26 first)
  static List<Map<String, dynamic>> getAllEntriesNewestFirst() {
    List<String> keys = diaryBox.keys.cast<String>().toList();
    keys.sort((a, b) => b.compareTo(a));
    return keys
        .map((key) => Map<String, dynamic>.from(diaryBox.get(key)))
        .toList();
  }
}
