import 'dart:io';

import 'package:chronologe_poc/dbhelper.dart';
import 'package:chronologe_poc/providers.dart';
import 'package:chronologe_poc/screens/imagepreview.dart';
import 'package:chronologe_poc/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class SummaryView extends ConsumerStatefulWidget {
  final String startingWeekDate;
  const SummaryView({super.key, required this.startingWeekDate});

  @override
  ConsumerState<SummaryView> createState() => _SummaryViewState();
}

class _SummaryViewState extends ConsumerState<SummaryView> {
  final CarouselController _carouselController = CarouselController();
  final ImagePicker _picker = ImagePicker();

  late String _dateRange;
  late Map<String, dynamic>? summaryData;
  late String _dbkey;

  List<String> resolvedImagePaths = [];
  List<String> storedFilenames = [];

  // Holds images selected but not yet saved
  List<XFile> unsavedImages = [];

  // Toggle for Edit mode
  bool isEditing = false;

  Future<Directory> _getTargetDirectory() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String targetPath = p.join(
      appDocDir.path,
      'summaries',
      'images',
      _dbkey,
    );
    return Directory(targetPath);
  }

  Future<void> _loadStoredImages() async {
    storedFilenames =
        (summaryData!['imageLoc'] as List?)?.cast<String>().toList() ?? [];

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
    _dbkey = widget.startingWeekDate;

    DateTime start = DateTime.parse(_dbkey);
    DateTime end = start.add(const Duration(days: 6));

    String formattedStart = DateFormat('MMM d').format(start);
    String formattedEnd = DateFormat('MMM d, y').format(end);
    _dateRange = "$formattedStart - $formattedEnd";

    summaryData = DBHelper.readSummary(_dbkey);
    if (summaryData != null) {
      _loadStoredImages();
    }
  }

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        imageQuality: 90,
      );
      if (images.isNotEmpty) {
        setState(() {
          unsavedImages.addAll(images);
        });
      }
      await _saveImages();
    } on Exception catch (e) {
      debugPrint("Error picking images: $e");
    }
  }

  Future<void> _saveImages() async {
    if (unsavedImages.isNotEmpty) {
      final Directory targetDir = await _getTargetDirectory();
      final Directory tempDir = await getTemporaryDirectory();
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      List<String> newFilenames = [];
      List<String> newResolvedPaths = [];
      int counter = 1;

      for (var image in unsavedImages) {
        final File tempFile = File(image.path);
        final String timestamp = DateTime.now().millisecondsSinceEpoch
            .toString();
        final String extension = p.extension(image.path);
        final String uniqueName = '${timestamp}_$counter$extension';
        counter++;

        final String permanentPath = p.join(targetDir.path, uniqueName);
        bool isCopied = false;

        try {
          await tempFile.copy(permanentPath);
          isCopied = true;

          await DBHelper.addSummaryImage(_dbkey, uniqueName);

          newFilenames.add(uniqueName);
          newResolvedPaths.add(permanentPath);
        } on Exception catch (imageError) {
          debugPrint('Failed to process image $uniqueName: $imageError');
          if (isCopied) {
            final File orphanFile = File(permanentPath);
            if (await orphanFile.exists()) {
              await orphanFile.delete();
            }
          }
        }
      }

      // CLEANING: Delete the images from temporary storage (cache)
      if (tempDir.existsSync()) {
        tempDir.listSync(recursive: true).forEach((
          FileSystemEntity entity,
        ) async {
          if (entity is File &&
              (entity.path.endsWith('jpg') ||
                  entity.path.endsWith('jpeg') ||
                  entity.path.endsWith('png') ||
                  entity.path.endsWith('heic') ||
                  entity.path.endsWith('webp'))) {
            DateTime now = DateTime.now();
            DateTime lastModified = await entity.lastModified();
            if (now.difference(lastModified) < Duration(minutes: 5)) {
              await entity.delete();
            }
          }
        });
      }

      setState(() {
        storedFilenames.addAll(newFilenames);
        resolvedImagePaths.addAll(newResolvedPaths);
        unsavedImages.clear();
      });
    }

    // Always exit edit mode when saving, even if no new images were added
    setState(() {
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    CustomFonts customFonts = ref.watch(customFontsProvider);

    if (summaryData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Week Wrapup")),
        body: const Center(child: Text("Summary not found.")),
      );
    }

    // Total images for the GridView (saved + unsaved)
    final int totalEditImages =
        resolvedImagePaths.length + unsavedImages.length;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
            ),
            title: const Text("Week Wrapup"),
            actions: [
              if (isEditing)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      enableFeedback: true,
                      minimumSize: Size.zero,
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      iconColor: theme.colorScheme.onPrimaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                    ),
                    onPressed: _saveImages,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.check, size: 16.67),
                        SizedBox(width: 4),
                        Text('Save'),
                      ],
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.primaryFixed,
                    ),
                    color: theme.colorScheme.primaryFixed,
                    tooltip: 'Edit Photos',
                    onPressed: () {
                      setState(() {
                        isEditing = true;
                      });
                    },
                    icon: Icon(
                      Icons.edit_outlined,
                      color: theme.colorScheme.onPrimaryFixedVariant,
                      size: 17,
                    ),
                  ),
                ),
            ],
          ),

          // Text Content Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    summaryData!['title'] ?? '',
                    style: customFonts.title != null
                        ? theme.textTheme.displayMedium!.merge(
                            customFonts.title,
                          )
                        : theme.textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),

                  // Date Range
                  Text(
                    _dateRange,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Theme in italic
                  Text(
                    "Theme: ${summaryData!['theme']}",
                    style: CustomTheme.toRobotoItalic(
                      theme.textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mood Chip
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: CustomTheme.getMoodColor(
                          summaryData!['overallMood'] ?? 'Reflective',
                          context,
                        ),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Overall: ${summaryData!['overallMood']}",
                        style: customFonts.body != null
                            ? theme.textTheme.titleMedium!.merge(
                                customFonts.body,
                              )
                            : theme.textTheme.titleMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Summary Text
                  Text(
                    summaryData!['summary'] ?? '',
                    style: customFonts.body != null
                        ? theme.textTheme.bodyLarge!.merge(customFonts.body)
                        : theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),

                  if ((summaryData!['highlights'] as List).isNotEmpty) ...[
                    Text(
                      "Highlights",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (summaryData!['highlights'] as List)
                          .map(
                            (highlight) => Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Text(
                                "• ${highlight.toString()}",
                                style: customFonts.body != null
                                    ? theme.textTheme.bodyLarge!.merge(
                                        customFonts.body,
                                      )
                                    : theme.textTheme.bodyLarge,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),

          if (isEditing && totalEditImages > 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: totalEditImages,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemBuilder: (context, index) {
                    final bool isSavedImage = index < resolvedImagePaths.length;

                    final String imagePath = isSavedImage
                        ? resolvedImagePaths[index]
                        : unsavedImages[index - resolvedImagePaths.length].path;

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            File(imagePath),
                            fit: BoxFit.cover,
                            cacheWidth: 300,
                          ),
                          // Quick Delete button
                          Positioned(
                            top: 4,
                            right: 4,
                            child: CircleAvatar(
                              backgroundColor: theme.colorScheme.primary
                                  .withAlpha(240),
                              radius: 16,
                              child: PopupMenuButton<String>(
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.more_vert,
                                  color: theme.colorScheme.onPrimary,
                                  size: 18,
                                ),
                                onSelected: (value) async {
                                  if (value == 'delete') {
                                    if (isSavedImage) {
                                      // 1. Delete from DB & File System
                                      final String targetedFilename =
                                          storedFilenames[index];
                                      await DBHelper.deleteSummaryImage(
                                        _dbkey,
                                        targetedFilename,
                                      );

                                      final File fileToDelete = File(imagePath);
                                      if (await fileToDelete.exists()) {
                                        await fileToDelete.delete();
                                      }
                                      // 2. Update UI
                                      setState(() {
                                        storedFilenames.removeAt(index);
                                        resolvedImagePaths.removeAt(index);
                                      });
                                    } else {
                                      // Delete unsaved image
                                      setState(() {
                                        unsavedImages.removeAt(
                                          index - resolvedImagePaths.length,
                                        );
                                      });
                                    }
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_outline,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

          if (!isEditing && resolvedImagePaths.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: CarouselView.weighted(
                  controller: _carouselController,
                  itemClipBehavior: Clip.antiAlias,
                  onTap: (index) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImagePreview(
                          carouselImagePath: resolvedImagePaths,
                          currentImageIndex: index,
                        ),
                      ),
                    );
                  },
                  flexWeights: const <int>[4, 2, 1],
                  itemSnapping: true,
                  shrinkExtent: 80,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  children: resolvedImagePaths.map((imagePath) {
                    return OverflowBox(
                      minWidth: 250,
                      maxWidth: 250,
                      maxHeight: 200,
                      minHeight: 200,
                      alignment: Alignment.center,
                      child: Image.file(
                        File(imagePath),
                        key: ValueKey(imagePath),
                        fit: BoxFit.cover,
                        cacheWidth: 600,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 84)),
        ],
      ),

      floatingActionButton: isEditing
          ? FloatingActionButton.extended(
              onPressed: _pickImages,
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: theme.colorScheme.onSecondary,
              enableFeedback: true,
              elevation: 1.0,
              icon: const Icon(Icons.add),
              label: const Text("Add Photos"),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
