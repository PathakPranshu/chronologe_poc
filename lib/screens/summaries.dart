import 'dart:io';

import 'package:chronologe_poc/dbhelper.dart';
import 'package:chronologe_poc/screens/summary.dart';
import 'package:chronologe_poc/screens/summaryview.dart';
import 'package:chronologe_poc/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;


class SummariesScreen extends StatefulWidget {
  const SummariesScreen({super.key});

  @override
  State<SummariesScreen> createState() => _SummariesScreenState();
}

class _SummariesScreenState extends State<SummariesScreen> {
  List<Map<String, dynamic>> allSummaries = [];
  Map<String, String> resolvedFirstImages = {};

  @override
  void initState() {
    super.initState();
    _loadSummaries();
  }

  Future<void> _loadSummaries() async {
    final summaries = DBHelper.getAllSummaries();
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Map<String, String> imagePathsCache = {};

    for (var entry in summaries) {
      final String dateKey = entry['startingWeekDate'] ?? '';
      if (dateKey.isEmpty) continue;

      final List<String> images =
          (entry['imageLoc'] as List?)?.cast<String>().toList() ?? [];

      if (images.isNotEmpty) {
        final String firstImageName = images.first;
        final String absolutePath = p.join(
          appDocDir.path,
          'summaries',
          'images',
          dateKey,
          firstImageName,
        );
        imagePathsCache[dateKey] = absolutePath;
      }
    }

    if (!mounted) return;

    setState(() {
      allSummaries = summaries;
      resolvedFirstImages = imagePathsCache;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Summaries'),
        surfaceTintColor: Colors.transparent,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                "Weekly Summaries",
                style: theme.textTheme.titleSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
          
          allSummaries.isEmpty
              ? const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text('No summaries yet. Create one to get started!'),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = allSummaries[index];
                        final String dateKey = entry['startingWeekDate'] ?? '';
                        final String title = entry['title'] ?? 'Weekly Wrap-Up';
                        final String description = entry['summary'] ?? '';
                        final List<dynamic> highlights = entry['highlights'] ?? '';
                        final String mood = entry['overallMood'] ?? 'Reflective';
                        final String? imagePath = resolvedFirstImages[dateKey];

                        // Format the date range correctly
                        DateTime start = DateTime.tryParse(dateKey) ?? DateTime.now();
                        DateTime end = start.add(const Duration(days: 6));
                        String formattedDate = "${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d, yyyy').format(end)}";

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Material(
                            borderRadius: BorderRadius.circular(28),
                            color: Color.alphaBlend(
                              CustomTheme.getMoodColor(mood, context).withAlpha(15),
                              theme.colorScheme.surfaceContainerLowest,
                            ),
                            elevation: 1,
                            shadowColor: theme.colorScheme.shadow,
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              children: [
                                InkWell(
                                  onTap: () {
                                    
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SummaryView(startingWeekDate: dateKey),
                                      ),
                                    ).then((_) => _loadSummaries());
                                    
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Image Thumbnail
                                            Container(
                                              width: 86,
                                              height: 86,
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme.surfaceContainerHigh,
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: theme.colorScheme.outlineVariant.withAlpha(100),
                                                ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: imagePath != null
                                                    ? Image.file(File(imagePath), fit: BoxFit.cover)
                                                    : Center(
                                                        child: Icon(
                                                          Icons.auto_awesome_rounded,
                                                          size: 28,
                                                          color: theme.colorScheme.onSurfaceVariant.withAlpha(100),
                                                        ),
                                                      ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            
                                            // Text Content
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    title.isEmpty ? "Weekly Wrap-Up" : title,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: theme.textTheme.titleMedium?.copyWith(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 16,
                                                      color: theme.colorScheme.onSurface,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    description.isEmpty
                                                        ? "No summary provided."
                                                        : description,
                                                    maxLines: 3,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: theme.textTheme.bodyMedium?.copyWith(
                                                      color: theme.colorScheme.onSurfaceVariant,
                                                      fontSize: 13,
                                                      height: 1.3,
                                                    ),
                                                  ),
                                                  
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                                    highlights.isEmpty
                                                        ? "No summary provided."
                                                        : highlights[0],
                                                    maxLines: 3,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: theme.textTheme.bodyMedium?.copyWith(
                                                      color: theme.colorScheme.onSurfaceVariant,
                                                      fontSize: 13,
                                                      height: 1.3,
                                                    ),
                                                  ),
                                        const SizedBox(height: 12),
                                              Text(
                                                formattedDate,
                                                style: theme.textTheme.labelLarge?.copyWith(
                                                    color: theme.colorScheme.onSurfaceVariant.withAlpha(175),
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Bottom Right Mood Decoration
                                Positioned(
                                  bottom: -8,
                                  right: -8,
                                  child: IgnorePointer(
                                    child: Container(
                                      width: 60,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: CustomTheme.getMoodColor(mood, context),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(24),
                                          bottomLeft: Radius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: allSummaries.length,
                    ),
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 84)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Summary()),
          ).then((_) => _loadSummaries());
          
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 1.0,
        icon: const Icon(Icons.auto_awesome),
        label: const Text("Create Summary"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}