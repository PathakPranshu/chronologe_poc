import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:chronologe_poc/theme.dart';
import 'package:chronologe_poc/dbhelper.dart';
import 'package:image_picker/image_picker.dart';

class Entry extends StatefulWidget {
  final String date;

  const Entry({
    super.key,
    required this.date,
  });

  @override
  State<Entry> createState() => _EntryState();
}

class _EntryState extends State<Entry> {
  Map? diaryEntry;
  String selectedMood = '';

  // Image picker
  final ImagePicker imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Read the selected date from the database
    diaryEntry = DBHelper.readEntry(widget.date);

    // Get the mood
    selectedMood = diaryEntry?['mood'] ?? '';
  }

  // Pick an image and save it to the database
  Future<void> uploadImage() async {
    XFile? pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    // User cancelled the picker
    if (pickedImage == null) {
      return;
    }

    // Convert image to bytes
    Uint8List imageBytes = await pickedImage.readAsBytes();

    // Save image bytes
    await DBHelper.addImage(
      widget.date,
      imageBytes,
    );

    // Reload diary entry
    setState(() {
      diaryEntry = DBHelper.readEntry(widget.date);
    });
  }

  // Open an image in a larger view
  void viewImage(int index) {
    List images = diaryEntry?['images_data'] ?? [];

    Uint8List imageBytes = Uint8List.fromList(
      List<int>.from(images[index]),
    );

    showDialog(
      context: context,

      builder: (dialogContext) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(20),

            child: Column(
              children: [

                // Large image
                Expanded(
                  child: InteractiveViewer(
                    child: Center(
                      child: Image.memory(
                        imageBytes,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Delete button
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    onPressed: () async {

                      // Delete image from database
                      await DBHelper.deleteImage(
                        widget.date,
                        index,
                      );

                      // Close image viewer
                      Navigator.pop(dialogContext);

                      // Reload diary entry
                      setState(() {
                        diaryEntry = DBHelper.readEntry(widget.date);
                      });
                    },

                    icon: const Icon(Icons.delete),

                    label: const Text(
                      'Delete Image',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color moodColor = CustomTheme.getMoodColor(selectedMood);
    Color backgroundColor = Color.alphaBlend(
      moodColor.withValues(alpha: 0.25),
      Theme.of(context).colorScheme.surface,
    );

    List images = diaryEntry?['images_data'] ?? [];

    String formattedDate = DateFormat('EEEE, d MMMM yyyy').format(
      DateTime.parse(diaryEntry?['date'] ?? widget.date),
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button and full date
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),

                  const SizedBox(width: 10),

                  // Full date
                  Text(formattedDate, style: Theme.of(context).textTheme.headlineSmall,)
                ],
              ),

              const SizedBox(height: 25),

              // Editable diary title
              TextFormField(
                initialValue: diaryEntry?['title'] ?? '',

                minLines: 1,
                maxLines: null,

                // Text Style
                style: Theme.of(context).textTheme.displaySmall,

                decoration: const InputDecoration(
                  hintText: 'Diary title',
                  border: InputBorder.none,
                ),

                // Save the title when it is changed
                onChanged: (String newTitle) async {
                  await DBHelper.changeTitle(
                    widget.date,
                    newTitle,
                  );
                },
              ), 

              const SizedBox(height: 15),

              // Editable diary text
              Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),

                child: TextFormField(
                  initialValue: diaryEntry?['text_data'] ?? '',
                  style: Theme.of(context).textTheme.bodyLarge,
                  maxLines: 12,
                  decoration: const InputDecoration(
                    hintText: 'Write your diary entry here...',
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Image rendering
              if (images.isNotEmpty)
                Wrap(
                  spacing: 10,
                  runSpacing: 10,

                  children: [
                    for (int i = 0; i < images.length; i++)
                      GestureDetector(
                      onTap: () {
                        viewImage(i);
                      },
                      child:ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.memory(
                          images[i],
                          width: 140,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 15),

              // Weather and mood
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    // Weather
                    Row(
                      children: [
                        Text(
                          CustomTheme.getWeatherEmoji(
                            diaryEntry?['weather']['category'] ?? '',
                          ),
                          style: const TextStyle(fontSize: 40),
                        ),

                        SizedBox(width: 10),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Weather',style: Theme.of(context).textTheme.titleMedium),

                            Text(
                              '${diaryEntry?['weather']['category'] ?? ''}, '
                              '${diaryEntry?['weather']['temp'] ?? ''}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Mood
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 5,
                      ),

                      decoration: BoxDecoration(
                        color: moodColor,
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: DropdownButton<String>(
                        value: selectedMood,
                        underline: const SizedBox(),
                        style: Theme.of(context).textTheme.titleMedium,

                        items: const [
                          DropdownMenuItem(
                            value: 'Happy',
                            child: Text('Happy'),
                          ),

                          DropdownMenuItem(
                            value: 'Calm',
                            child: Text('Calm'),
                          ),

                          DropdownMenuItem(
                            value: 'Tired',
                            child: Text('Tired'),
                          ),

                          DropdownMenuItem(
                            value: 'Excited',
                            child: Text('Excited'),
                          ),

                          DropdownMenuItem(
                            value: 'Reflective',
                            child: Text('Reflective'),
                          ),
                        ],

                        onChanged: (String? newMood) async {
                          setState(() {
                            selectedMood = newMood!;
                          });

                          // Update the mood in the database
                          await DBHelper.changeMood(
                            widget.date,
                            selectedMood,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Generate button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Gemini generation will be added later
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: mySecondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(20),
                  ),

                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generate with Gemini'),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      
      floatingActionButton: FloatingActionButton.extended(
      onPressed: uploadImage,
      backgroundColor: mySecondary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text('Add Photos'),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
