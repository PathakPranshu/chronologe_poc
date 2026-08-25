import 'package:chronologe_poc/screens/entry.dart';
import 'package:chronologe_poc/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
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
              leading: null,
              title: Text(
                "Your Chronologe",
              ),
              // pinned: false,
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
                              color: Theme.of(context).colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TableCalendar(
                              focusedDay: _focusedDay,
                              // currentDay: DateTime.now(),
                              firstDay: DateTime.utc(2026, 03, 14),
                              lastDay: DateTime.now(),
                              calendarFormat: CalendarFormat.month,
                              calendarStyle: CalendarStyle(
                                todayDecoration: BoxDecoration(
                                  border: Border.all(color: Theme.of(context).colorScheme.primary),
                                  shape: BoxShape.circle
                                ),
                                selectedDecoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle
                                ),
                                todayTextStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface
                                )
                              ),
                              headerStyle: HeaderStyle(
                                formatButtonVisible: false,
                                titleCentered: true,
                                headerPadding: EdgeInsets.fromLTRB(0, 4, 0, 12),
                                leftChevronPadding: EdgeInsets.all(0),
                                rightChevronPadding: EdgeInsets.all(0),
                              ),
                              selectedDayPredicate: (day) {
                                return isSameDay(_selectedDay, day);
                              },

                              onDaySelected: (selectedDay, focusedDay) => {
                                if (!isSameDay(selectedDay, _selectedDay))
                                  {
                                    // TODO: Call entry retrieval function with selected day

                                    setState(() {
                                      _selectedDay = selectedDay;
                                      _focusedDay = focusedDay;
                                    }),
                                  },
                              },
                            ),
                          )
                        : Container(height: 0),
                  ),
                  const SizedBox(height: 500),
                  Text("RVSH",
                  style: CustomTheme.toRobotoItalic(Theme.of(context).textTheme.titleLarge)),
                ],
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
                // TODO: redirect to entry screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Entry()),
                );
              },
              child: Icon(Icons.edit),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// To be removed*** this code is to preview the ui of this widget
@Preview(name: "Timeline Preview", size: Size(390, 844))
Widget timelinePreview() {
  return Timeline();
}
