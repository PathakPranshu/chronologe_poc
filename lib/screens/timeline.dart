import 'package:chronologe_poc/dbhelper.dart';
import 'package:flutter/material.dart';

class Timeline extends StatefulWidget {
  const Timeline({super.key});

  @override
  State<Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  void initState() {
    super.initState();
    testDatabase();
  }
  Future<void> testDatabase() async {
    String date = '2026-08-24';
    // 1. Insert or Update text
    await DBHelper.changeText(date, 'Today was a good day!');

    // Read after inserting text
    Map? entry = DBHelper.readEntry(date);
    print('AFTER TEXT:');
    print(entry);

    // 2. Insert or Update mood
    await DBHelper.changeMood(date, 'Happy');

    // Read after inserting mood
    entry = DBHelper.readEntry(date);
    print('AFTER MOOD:');
    print(entry);

    // 3. Insert or Update weather
    await DBHelper.changeWeather(date, 'Sunny', '25°C');

    // Read after inserting weather
    entry = DBHelper.readEntry(date);
    print('AFTER WEATHER:');
    print(entry);

    // 4. Add image 1
    await DBHelper.addImage(date,'images/photo1.jpg');

    // Read after adding image 1
    entry = DBHelper.readEntry(date);
    print('AFTER IMAGE 1:');
    print(entry);

    // 5. Add image 2
    await DBHelper.addImage(date,'images/photo2.jpg');

    // Read after adding image 2
    entry = DBHelper.readEntry(date);
    print('AFTER IMAGE 2:');
    print(entry);

    // 6. Delete first image 
    await DBHelper.deleteImage(date, 'images/photo1.jpg');

    // Read after deleting first image
    entry = DBHelper.readEntry(date);
    print('AFTER DELETING IMAGE 1:');
    print(entry);

  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}