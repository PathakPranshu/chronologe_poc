import 'dart:io';

import 'package:chronologe_poc/dbhelper.dart';
import 'package:chronologe_poc/screens/diaryview.dart';
import 'package:chronologe_poc/screens/entry.dart';
import 'package:chronologe_poc/screens/info.dart';
import 'package:chronologe_poc/theme.dart';
import 'package:chronologe_poc/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
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
  bool isCalendarExpanded = false;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Map<String, dynamic>> allEntries = [];
  Map<String, String> resolvedFirstImages = {};
  Set<String> entryDatesWithData = {};
  Map<String, dynamic>? _selectedDayData;
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

      // Track days with entries for calendar dots
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
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          Theme(
            data: Theme.of(context).copyWith(
              textTheme: Theme.of(context).textTheme.copyWith(
                headlineMedium: Theme.of(context).textTheme.displaySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                titleLarge: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
            child: SliverAppBar.large(
              actionsPadding: EdgeInsets.fromLTRB(0, 4, 12, 8),
              leading: null,
              title: Text("Your Chronologe"),
              actions: [
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Info()),
                  ),
                  icon: Icon(
                    Icons.info_outline_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  FilledButton(
                    style: FilledButton.styleFrom(
                      enableFeedback: true,
                      minimumSize: Size.zero,
                      foregroundColor: isCalendarExpanded
                          ? Theme.of(context).colorScheme.onSecondary
                          : Theme.of(context).colorScheme.onSecondaryContainer,
                      backgroundColor: isCalendarExpanded
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.secondaryContainer,
                      iconColor: isCalendarExpanded
                          ? Theme.of(context).colorScheme.onSecondary
                          : Theme.of(context).colorScheme.onSecondaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          isCalendarExpanded ? 12 : 100,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        isCalendarExpanded = !isCalendarExpanded;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_month, size: 16.67),
                        const SizedBox(width: 4),
                        Text("Dates"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedSize(
                    duration: Duration(milliseconds: 250),
                    curve: Curves.fastOutSlowIn,
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.antiAlias,
                    child: isCalendarExpanded
                        ? Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerLow,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                TableCalendar(
                                  focusedDay: _focusedDay,
                                  // currentDay: DateTime.now(),
                                  firstDay: DateTime.utc(2026, 03, 14),
                                  lastDay: DateTime.now(),
                                  calendarFormat: CalendarFormat.month,
                                  calendarStyle: CalendarStyle(
                                    markersMaxCount: 1,
                                    markerMargin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                    todayDecoration: BoxDecoration(
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    selectedDecoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    todayTextStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                  headerStyle: HeaderStyle(
                                    formatButtonVisible: false,
                                    titleCentered: true,
                                    headerPadding: EdgeInsets.fromLTRB(0, 4, 0, 12),
                                    leftChevronPadding: EdgeInsets.all(0),
                                    rightChevronPadding: EdgeInsets.all(0),
                                    leftChevronIcon: Icon(
                                      Icons.chevron_left,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                    rightChevronIcon: Icon(
                                      Icons.chevron_right,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                  selectedDayPredicate: (day) {
                                    return isSameDay(_selectedDay, day);
                                  },
                                  eventLoader: (day) {
                                    final String dayKey = _getDbKeyOf(day);
                                    return entryDatesWithData.contains(dayKey)
                                        ? [true]
                                        : [];
                                  },
                                  onDaySelected: (selectedDay, focusedDay) async {
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
                                    _selectedDayData = DBHelper.getEntry(
                                      selectedKey,
                                      readOnly: true,
                                    );
                                  },
                                  calendarBuilders: CalendarBuilders(
                                    markerBuilder: (context, day, events) {
                                      if (events.isEmpty) {
                                        return const SizedBox.shrink();
                                      }
                                
                                      final String dayKey = _getDbKeyOf(day);
                                      final String currentDayMood =
                                          _dateMoods![dayKey] ?? '';
                                
                                      final Color indicatorColor =
                                          CustomTheme.getMoodColor(currentDayMood);
                                
                                      return Positioned(
                                        bottom: -1,
                                        child: Container(
                                          width: 24,
                                          height: 7,
                                          decoration: BoxDecoration(
                                            color: indicatorColor,
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.circular(8) // Rounded circle dot matches clean minimalistic interfaces
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(height: 4,),
                                Divider(thickness: 1, color: Theme.of(context).colorScheme.surfaceContainerHighest,),
                                const SizedBox(height: 12,),
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
                            color: CustomTheme.getMoodColor(mood),
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
                            padding: EdgeInsets.only(top: 48.0),
                            child: Text("Add a diary to get started."),
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final entryItem = allEntries[index]; // Use the filtered list here
                              final String dateStr = entryItem['date'] ?? '';

                              DateTime parsedDate =
                                  DateTime.tryParse(dateStr) ?? DateTime.now();
                              String friendlyDate = DateFormat('MMM d, yyyy')
                                  .format(parsedDate);

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
                                  ).then(
                                    (_) => _loadTimelineData(),
                                  ); // Refresh list when returning
                                },
                              );
                            },
                            childCount: allEntries
                                .length, // Triggers card list limit correctly
                          ),
                        ),
                      )
              : SliverToBoxAdapter(
                  child: _selectedDayData == null
                      ? Container(height: 0)
                      : Padding(
                          padding: EdgeInsetsGeometry.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: TimelineCard(
                            title: _selectedDayData!['title'],
                            mood: _selectedDayData!['mood'] ?? '',
                            description: _selectedDayData!['text_data'],
                            formattedDate: DateFormat(
                              'MMM d, yyyy',
                            ).format(DateTime.parse(_selectedDayData!['date'])),
                            imagePath:
                                resolvedFirstImages[_selectedDayData!['date']],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DiaryView(
                                  dateKey: _selectedDayData!['date'],
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
        ],
      ),
      floatingActionButton: isCalendarExpanded
          ? null
          : FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              enableFeedback: true,
              elevation: 2.0,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Entry()),
                ).then((_) => _loadTimelineData());
              },
              child: Icon(Icons.edit),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
