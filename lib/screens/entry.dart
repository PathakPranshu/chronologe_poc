import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class Entry extends StatefulWidget {
  const Entry({super.key});

  @override
  State<Entry> createState() => _EntryState();
}

class _EntryState extends State<Entry> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  String _date = DateFormat('E, MMM d, y').format(DateTime.now()).toString();

  final ImagePicker _picker = ImagePicker();

  List<XFile> selectedImages = [];

  Future<void> _pickImages() async {
    try {
      List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        selectedImages.addAll(images);
      }
    } on Exception catch (e) {
      debugPrint("Error picking images: $e");
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
            ),
            title: Text(_date),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  TextField(
                    controller: _titleController,
                    style: Theme.of(context).textTheme.displayMedium,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "Add a title",
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _contentController,
                    style: Theme.of(context).textTheme.bodyLarge,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "Add your thoughts here...",
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickImages,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
        enableFeedback: true,
        elevation: 1.0,
        icon: Icon(Icons.add),
        label: Text("Add Photos"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
