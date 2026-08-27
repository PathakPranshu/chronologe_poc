import 'dart:async';
import 'dart:io';

import 'package:chronologe_poc/dbhelper.dart';
import 'package:chronologe_poc/theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

enum SaveStatus { saved, typing, saving }

class Entry extends StatefulWidget {
  final String? dateKey;
  const Entry({super.key, this.dateKey});

  @override
  State<Entry> createState() => _EntryState();
}

class _EntryState extends State<Entry> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  Timer? _debounceTimer;
  SaveStatus _status = SaveStatus.saved;
  late String _formattedDate;
  late String _dbkey;
  late Map<String, dynamic>? entry;
  String selectedMood = '';

  final ImagePicker _picker = ImagePicker();

  List<String> resolvedImagePaths = [];

  List<String> storedFilenames = [];

  Future<Directory> _getTargetDirectory() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String targetPath = p.join(
      appDocDir.path,
      'entries',
      'images',
      _dbkey,
    );
    return Directory(targetPath);
  }

  Future<bool> _autoSave() async {
    String titleInput = _titleController.text.trim();
    String contentInput = _contentController.text.trim();

    // If both layout elements are completely clean, do not commit anything
    if (titleInput.isEmpty && contentInput.isEmpty) {
      return false;
    }

    bool updated = false;

    if (titleInput != (entry!['title'] ?? '')) {
      try {
        await DBHelper.changeTitle(_dbkey, titleInput);
        entry!['title'] = titleInput;
        updated = true;
      } catch (e) {
        debugPrint("Error saving title: $e");
      }
    }

    if (contentInput != (entry!['text_data'] ?? '')) {
      try {
        await DBHelper.changeText(_dbkey, contentInput);
        entry!['text_data'] = contentInput;
        updated = true;
      } catch (e) {
        debugPrint("Error saving content: $e");
      }
    }

    return updated;
  }

  void _onTextChanged() {
    if (_status != SaveStatus.typing) {
      setState(() {
        _status = SaveStatus.typing;
      });
    }

    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 1000), () async {
      setState(() {
        _status = SaveStatus.saving;
      });

      await _autoSave();

      if (mounted) {
        setState(() {
          _status = SaveStatus.saved;
        });
      }
    });
  }

  Future<void> _pickImages() async {
    try {
      List<XFile> images = await _picker.pickMultiImage();
      if (images.isEmpty) return;

      final Directory targetDir = await _getTargetDirectory();
      // Ensure the entries/images/{date} directories exist
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      List<String> newFilenames = [];
      List<String> newResolvedPaths = [];

      for (var image in images) {
        final File tempFile = File(image.path);

        final String timestamp = DateTime.now().millisecondsSinceEpoch
            .toString();
        final String extension = p.extension(image.path);
        final String uniqueName = '$timestamp$extension';

        final String permanentPath = p.join(targetDir.path, uniqueName);

        await tempFile.copy(permanentPath);

        await DBHelper.addImage(_dbkey, uniqueName);

        newFilenames.add(uniqueName);
        newResolvedPaths.add(permanentPath);
      }

      setState(() {
        storedFilenames.addAll(newFilenames);
        resolvedImagePaths.addAll(newResolvedPaths);
      });
    } on Exception catch (e) {
      debugPrint("Error picking images: $e");
    }
  }

  Future<void> _loadStoredImages() async {
    entry = DBHelper.getEntry(_dbkey);

    // Read short string names from Hive
    storedFilenames =
        (entry!['images_loc'] as List?)?.cast<String>().toList() ?? [];

    if (storedFilenames.isNotEmpty) {
      final Directory targetDir = await _getTargetDirectory();
      final List<String> paths = [];

      for (String fileName in storedFilenames) {
        paths.add(p.join(targetDir.path, fileName));
      }

      setState(() {
        resolvedImagePaths = paths;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.dateKey != null) {
      _dbkey = widget.dateKey!;

      // Formatted Date for AppBar Title
      DateTime parsedDateTime = DateTime.parse(_dbkey);
      _formattedDate = DateFormat('E, MMM d, y').format(parsedDateTime);
    } else {
      DateTime now = DateTime.now();

      _dbkey = DateFormat('yyyy-MM-dd').format(now);
      _formattedDate = DateFormat('E, MMM d, y').format(now);
    }

    entry = DBHelper.getEntry(_dbkey);
    _titleController.text = entry!['title'] ?? '';
    _contentController.text = entry!['text_data'] ?? '';
    final savedMood = entry!['mood'] as String?;
    if (savedMood != null && savedMood.isNotEmpty) {
      selectedMood = savedMood;
    } else {
      selectedMood = 'Calm'; // Matches your default item list options
    }
    _loadStoredImages();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _autoSave();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Widget _buildStatusIcon() {
    switch (_status) {
      case SaveStatus.typing:
        return SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
        );
      case SaveStatus.saving:
        return const Icon(Icons.edit, size: 1, color: Colors.grey);
      case SaveStatus.saved:
      default:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          textBaseline: TextBaseline.alphabetic,
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 2,
          children: [
            Text(
              "autosaved",
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Icon(
              Icons.check_circle,
              size: 22,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color moodColor = CustomTheme.getMoodColor(selectedMood);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(
          context,
          DBHelper.getEntry(entry!['date'], readOnly: true),
        );
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              leading: IconButton(
                onPressed: () async {
                  await _autoSave();
                  if (mounted) {
                    Navigator.pop(
                      context,
                      DBHelper.getEntry(entry!['date'], readOnly: true),
                    );
                  }
                },
                icon: const Icon(Icons.arrow_back),
              ),
              title: Text(_formattedDate),
              actions: [
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 4, 16, 8),
                  child: _buildStatusIcon(),
                ),
              ],
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
                      onChanged: (value) => _onTextChanged(),
                      style: Theme.of(context).textTheme.displayMedium,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: "Add a title",
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Select your mood",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Container(
                          height: 38,
                          padding: EdgeInsetsGeometry.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: moodColor,
                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: DropdownButton<String>(
                            iconEnabledColor: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(100),
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
                              await DBHelper.changeMood(_dbkey, selectedMood);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _contentController,
                      style: Theme.of(context).textTheme.bodyLarge,
                      onChanged: (value) => _onTextChanged(),
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: "Add your thoughts for the day... \n\nThis entry will be auto saved.",
                        hintStyle: CustomTheme.toRobotoItalic(
                          Theme.of(context).textTheme.bodyLarge,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                    if (resolvedImagePaths.isNotEmpty) ...[
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: resolvedImagePaths.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                        ),
                        itemBuilder: (context, index) {
                          final String absoluteImagePath =
                              resolvedImagePaths[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(
                                  File(absoluteImagePath),
                                  fit: BoxFit.cover,
                                ),
                                // Quick Delete button on corner overlay
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withAlpha(240),
                                    radius: 16,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                      ),
                                      onPressed: () async {
                                        final String targetedFilename =
                                            storedFilenames[index];

                                        await DBHelper.deleteImage(
                                          _dbkey,
                                          targetedFilename,
                                        );

                                        final File fileToDelete = File(
                                          absoluteImagePath,
                                        );
                                        if (await fileToDelete.exists()) {
                                          await fileToDelete.delete();
                                        }

                                        setState(() {
                                          storedFilenames.removeAt(index);
                                          resolvedImagePaths.removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
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
      ),
    );
  }
}
