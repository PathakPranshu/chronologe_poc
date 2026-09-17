import 'dart:io';

import 'package:chronologe_poc/dbhelper.dart';
import 'package:chronologe_poc/providers.dart';
import 'package:chronologe_poc/screens/entry.dart';
import 'package:chronologe_poc/screens/imagepreview.dart';
import 'package:chronologe_poc/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class DiaryView extends ConsumerStatefulWidget {
  final String dateKey;
  const DiaryView({super.key, this.dateKey = ''});

  @override
  ConsumerState<DiaryView> createState() => _DiaryViewState();
}

class _DiaryViewState extends ConsumerState<DiaryView> {
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
    CustomFonts customFonts = ref.watch(customFontsProvider);

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
                  Text(entry!['title'], style: customFonts.title != null ? theme.textTheme.displayMedium!.merge(customFonts.title): theme.textTheme.displayMedium),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: CustomTheme.getMoodColor(entry!['mood'], context),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Mood: ${entry!['mood']}",
                        style: customFonts.body != null ? theme.textTheme.titleMedium!.merge(customFonts.body) : theme.textTheme.titleMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(entry!['text_data'], style: customFonts.body != null ? theme.textTheme.bodyLarge!.merge(customFonts.body) : theme.textTheme.bodyLarge,),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (resolvedImagePaths.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: CarouselView.weighted(
                  controller: _carouselController,
                  itemClipBehavior: Clip.antiAlias,
                  onTap: (index) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ImagePreview(carouselImagePath: resolvedImagePaths, currentImageIndex: index,)));
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
          SliverToBoxAdapter(child: const SizedBox(height: 84)),
        ],
      ),
      floatingActionButton: Container(
        height: 64,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryFixedDim,
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
            color: theme.colorScheme.onSurface.withAlpha(80),
            blurRadius: 2,
            offset: Offset(1, 0)
            )
          ]
        ),
        child: Row(
          spacing: 4,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Entry(dateKey: _dbkey),
                  ),
                ).then((value) {
                  setState(() {
                    if (value != null && mounted) {
                      entry = Map<String, dynamic>.from(value);
                    }
                  });
                  _loadStoredImages();
                });
              },
              icon: Icon(
                Icons.edit_note,
                color: Theme.of(context).colorScheme.onPrimaryFixedVariant,
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}