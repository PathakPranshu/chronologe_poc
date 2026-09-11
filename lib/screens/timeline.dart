import 'dart:io';

import 'package:chronologe_poc/dbhelper.dart';
import 'package:chronologe_poc/screens/diaryview.dart';
import 'package:chronologe_poc/screens/entry.dart';
import 'package:chronologe_poc/screens/info.dart';
import 'package:chronologe_poc/screens/preferences.dart';
import 'package:chronologe_poc/screens/search.dart';
import 'package:chronologe_poc/screens/summary.dart';
import 'package:chronologe_poc/theme.dart';
import 'package:chronologe_poc/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:table_calendar/table_calendar.dart';

class Timeline extends StatefulWidget {
  const Timeline({super.key});

  @override
  State<Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  void _openSearch() {
    showSearch(
      context: context,
      delegate: DiarySearchDelegate(
        entries: allEntries,
        imagePaths: resolvedFirstImages,
      ),
    );
  }

  bool isCalendarExpanded = false;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Map<String, dynamic>> allEntries = [];
  Map<String, String> resolvedFirstImages = {};
  Set<String> entryDatesWithData = {};

  List<Map<dynamic, dynamic>>? _monthData = [];
  Map<String, String>? _dateMoods;

  Future<void> _loadTimelineData() async {
    final List<Map<String, dynamic>> entries =
        DBHelper.getAllEntriesNewestFirst();

    final Directory appDocDir = await getApplicationDocumentsDirectory();

    final Map<String, String> imagePathsCache = {};
    final Set<String> datesWithData = {};
    final Map<String, String> moods = {};

    for (var entry in entries) {
      final String dateKey = entry['date'] ?? '';

      if (dateKey.isEmpty) continue;

      // Track days with entries for calendar indicators.
      datesWithData.add(dateKey);

      moods[dateKey] = entry['mood'] ?? '';

      final List<String> images =
          (entry['images_loc'] as List?)?.cast<String>().toList() ?? [];

      if (images.isNotEmpty) {
        final String firstImageName = images.first;

        final String absolutePath = p.join(
          appDocDir.path,
          'entries',
          'images',
          dateKey,
          firstImageName,
        );

        imagePathsCache[dateKey] = absolutePath;
      }
    }

    if (!mounted) return;

    setState(() {
      allEntries = entries;
      resolvedFirstImages = imagePathsCache;
      entryDatesWithData = datesWithData;
      _dateMoods = moods;
    });
  }

  String _getDbKeyOf(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  void initState() {
    super.initState();
    _loadTimelineData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          Theme(
            data: theme.copyWith(
              textTheme: theme.textTheme.copyWith(
                headlineMedium: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                titleLarge: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            child: SliverAppBar.large(
              actionsPadding: const EdgeInsets.fromLTRB(0, 4, 12, 8),
              leading: null,
              title: const Text('Your Chronologe'),
              actions: [
                IconButton(
                  tooltip: 'Weekly Summary',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Summary()),
                    );
                  },
                  icon: Icon(
                    Icons.auto_awesome_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                ),
                IconButton(
                  tooltip: 'Preferences',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Preferences(),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.tune,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                ),

                IconButton(
                  tooltip: "App Info",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Info()),
                    );
                  },
                  icon: Icon(
                    Icons.info_outline_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      FilledButton(
                        style: FilledButton.styleFrom(
                          enableFeedback: true,
                          minimumSize: Size.zero,
                          foregroundColor: isCalendarExpanded
                              ? theme.colorScheme.onSecondary
                              : theme.colorScheme.onSecondaryContainer,
                          backgroundColor: isCalendarExpanded
                              ? theme.colorScheme.secondary
                              : theme.colorScheme.secondaryContainer,
                          iconColor: isCalendarExpanded
                              ? theme.colorScheme.onSecondary
                              : theme.colorScheme.onSecondaryContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              isCalendarExpanded ? 12 : 100,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 12,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            isCalendarExpanded = !isCalendarExpanded;
                          });
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_month, size: 16.67),
                            SizedBox(width: 4),
                            Text('Dates'),
                          ],
                        ),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          enableFeedback: true,
                          minimumSize: Size.zero,
                          foregroundColor:
                              theme.colorScheme.onSecondaryContainer,
                          backgroundColor: theme.colorScheme.secondaryContainer,
                          iconColor: theme.colorScheme.onSecondaryContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 12,
                          ),
                        ),
                        onPressed: _openSearch,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.search_rounded, size: 16.67),
                            SizedBox(width: 4),
                            Text('Search'),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.fastOutSlowIn,
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.antiAlias,
                    child: isCalendarExpanded
                        ? Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                TableCalendar(
                                  focusedDay: _focusedDay,
                                  firstDay: DateTime.utc(2026, 3, 14),
                                  lastDay: DateTime.now(),
                                  calendarFormat: CalendarFormat.month,

                                  calendarStyle: CalendarStyle(
                                    markersMaxCount: 1,
                                    markerMargin: const EdgeInsets.fromLTRB(
                                      0,
                                      10,
                                      0,
                                      0,
                                    ),
                                    todayDecoration: BoxDecoration(
                                      border: Border.all(
                                        color: theme.colorScheme.primary,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    selectedDecoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    selectedTextStyle: theme
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          color: theme.colorScheme.onPrimary,
                                        ),
                                    todayTextStyle: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),

                                  headerStyle: HeaderStyle(
                                    formatButtonVisible: false,
                                    titleCentered: true,
                                    headerPadding: const EdgeInsets.fromLTRB(
                                      0,
                                      4,
                                      0,
                                      12,
                                    ),
                                    leftChevronPadding: EdgeInsets.zero,
                                    rightChevronPadding: EdgeInsets.zero,
                                    leftChevronIcon: Icon(
                                      Icons.chevron_left,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    rightChevronIcon: Icon(
                                      Icons.chevron_right,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),

                                  selectedDayPredicate: (day) {
                                    return isSameDay(_selectedDay, day);
                                  },
                                  onPageChanged: (focusedDay) => {
                                    setState(() {
                                      _focusedDay = focusedDay;
                                      _monthData = DBHelper.getMonthData(
                                        focusedDay.year,
                                        focusedDay.month,
                                      );
                                    }),
                                  },
                                  eventLoader: (day) {
                                    final String dayKey = _getDbKeyOf(day);

                                    return entryDatesWithData.contains(dayKey)
                                        ? [true]
                                        : [];
                                  },

                                  onDaySelected: (selectedDay, focusedDay) {
                                    final String selectedKey = _getDbKeyOf(
                                      selectedDay,
                                    );

                                    if (isSameDay(selectedDay, _selectedDay)) {
                                      return;
                                    }

                                    setState(() {
                                      _selectedDay = selectedDay;

                                      _focusedDay = focusedDay;
                                    });

                                    if (entryDatesWithData.contains(
                                      selectedKey,
                                    )) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DiaryView(dateKey: selectedKey),
                                        ),
                                      ).then((_) => _loadTimelineData());
                                    }
                                  },

                                  calendarBuilders: CalendarBuilders(
                                    markerBuilder: (context, day, events) {
                                      if (events.isEmpty) {
                                        return const SizedBox.shrink();
                                      }

                                      final String dayKey = _getDbKeyOf(day);

                                      final String currentDayMood =
                                          _dateMoods?[dayKey] ?? '';

                                      final Color indicatorColor =
                                          CustomTheme.getMoodColor(
                                            currentDayMood,
                                            context,
                                          );

                                      return Positioned(
                                        bottom: -1,
                                        child: Container(
                                          width: 24,
                                          height: 7,
                                          decoration: BoxDecoration(
                                            color: indicatorColor,
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Divider(
                                  thickness: 1,
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                ),

                                const SizedBox(height: 12),

                                Wrap(
                                  spacing: 15,
                                  runSpacing: 10,
                                  children: [
                                    for (String mood in [
                                      'Happy',
                                      'Calm',
                                      'Tired',
                                      'Excited',
                                      'Reflective',
                                    ])
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 16,
                                            height: 16,
                                            decoration: BoxDecoration(
                                              color: CustomTheme.getMoodColor(
                                                mood,
                                                context,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(mood),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        : Container(height: 0),
                  ),
                ],
              ),
            ),
          ),

          !isCalendarExpanded
              ? allEntries.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 48),
                            child: Text('Add a diary to get started.'),
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final entryItem = allEntries[index];

                            final String dateStr = entryItem['date'] ?? '';

                            final DateTime parsedDate =
                                DateTime.tryParse(dateStr) ?? DateTime.now();

                            final String friendlyDate = DateFormat(
                              'MMM d, yyyy',
                            ).format(parsedDate);

                            return TimelineCard(
                              title: entryItem['title'] ?? '',
                              description: entryItem['text_data'] ?? '',
                              formattedDate: friendlyDate,
                              imagePath: resolvedFirstImages[dateStr],
                              mood: entryItem['mood'] ?? '',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DiaryView(dateKey: dateStr),
                                  ),
                                ).then((_) => _loadTimelineData());
                              },
                            );
                          }, childCount: allEntries.length),
                        ),
                      )
              : SliverToBoxAdapter(
                  child: _monthData!.isEmpty
                      ? const SizedBox(height: 0)
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 12,
                            children: [
                              Text(
                                'Entries in ${DateFormat('MMMM').format(_focusedDay)} ${_focusedDay.year}',
                                style: theme.textTheme.titleSmall!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _monthData!.length,
                                itemBuilder: ((context, index) {
                                  final entry = _monthData![index];

                                  return TimelineCard(
                                    title: entry['title'] ?? "",
                                    description: entry['text_data'] ?? '',
                                    formattedDate: entry['date'],
                                    imagePath:
                                        resolvedFirstImages[entry['date']],
                                    mood: entry['mood'],
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DiaryView(dateKey: entry['date']),
                                        ),
                                      ).then((_) => _loadTimelineData());
                                    },
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                ),
          SliverToBoxAdapter(child: const SizedBox(height: 84)),
        ],
      ),

      floatingActionButton: isCalendarExpanded
          ? null
          : FloatingActionButton(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              enableFeedback: true,
              elevation: 2,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Entry()),
                ).then((_) => _loadTimelineData());
              },
              child: const Icon(Icons.edit),
            ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
