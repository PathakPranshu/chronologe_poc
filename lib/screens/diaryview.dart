import 'dart:io';

import 'package:chronologe_poc/dbhelper.dart';
import 'package:chronologe_poc/screens/entry.dart';
import 'package:chronologe_poc/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class DiaryView extends StatefulWidget {
  final String dateKey;
  const DiaryView({super.key, this.dateKey = ''});

  @override
  State<DiaryView> createState() => _DiaryViewState();
}

class _DiaryViewState extends State<DiaryView> {
  final CarouselController _carouselController = CarouselController();
  late String _formattedDate;
  late Map<String, dynamic>? entry;
  late String _dbkey;

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

  Future<void> _loadStoredImages() async {
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

    _dbkey = widget.dateKey;
    DateTime parsedDateTime = DateTime.parse(_dbkey);
    _formattedDate = DateFormat('E, MMM d, y').format(parsedDateTime);

    entry = DBHelper.getEntry(_dbkey, readOnly: true);
    if (entry != null) {
      _loadStoredImages();
    }
  }

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            title: Text(_formattedDate),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(entry!['title'], style: theme.textTheme.displayMedium),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: CustomTheme.getMoodColor(entry!['mood']),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Mood: ${entry!['mood']}",
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(entry!['text_data'], style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (resolvedImagePaths.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 180,
                child: CarouselView.weighted(
                  controller: _carouselController,
                  onTap: (index) {
                    showDialog(
                      context: context,
                      builder: (dialogContext) {
                        return AnnotatedRegion<SystemUiOverlayStyle>(
                          value: const SystemUiOverlayStyle(
                            statusBarColor: Colors.black,
                            statusBarIconBrightness: Brightness.light,
                            statusBarBrightness: Brightness.dark,
                            systemNavigationBarColor: Colors.black,
                            systemNavigationBarIconBrightness: Brightness.light,
                            systemNavigationBarDividerColor: Colors.transparent,
                          ),
                          child: Dialog.fullscreen(
                            child: Scaffold(
                              backgroundColor: Colors.black,
                              extendBody: true,
                              extendBodyBehindAppBar: true,
                              appBar: AppBar(
                                leading: IconButton(
                                  onPressed: () {
                                    Navigator.maybePop(dialogContext);
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: theme.colorScheme.surface
                                    .withAlpha(0),
                                elevation: 0,
                              ),
                              body: InteractiveViewer(
                                maxScale: 3,
                                clipBehavior: Clip.none,
                                child: Center(
                                  child: Image.file(
                                    File(resolvedImagePaths[index]),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  flexWeights: <int>[4, 2, 1],
                  itemSnapping: true,
                  shrinkExtent: 80,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  children: resolvedImagePaths.map((imagePath) {
                    return Image.file(
                      File(imagePath),
                      key: ValueKey(imagePath),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.large(
        backgroundColor: theme.colorScheme.surfaceContainerLow,
        foregroundColor: theme.colorScheme.primary,
        elevation: 2.0,
        enableFeedback: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(36),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Entry(dateKey: _dbkey)),
          ).then((value) {
            setState(() {
              if (value != null && mounted) {
                entry = Map<String, dynamic>.from(value);
              }
            });
            _loadStoredImages();
          });
        },
        child: const Icon(Icons.edit_note),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
