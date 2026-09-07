import 'package:chronologe_poc/dbhelper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Summary extends StatefulWidget {
  const Summary({super.key});

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  List<Map<String, dynamic>> weeklyEntries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeeklyEntries();
  }

  void _loadWeeklyEntries() {
    final List<Map<String, dynamic>> allEntries =
        DBHelper.getAllEntriesNewestFirst();

    final DateTime today = DateTime.now();
    final DateTime sevenDaysAgo = today.subtract(
      const Duration(days: 6),
    );

    final List<Map<String, dynamic>> entries = allEntries.where((entry) {
      final String dateString = entry['date'] ?? '';

      final DateTime? entryDate =
          DateTime.tryParse(dateString);

      if (entryDate == null) {
        return false;
      }

      final DateTime normalizedEntryDate = DateTime(
        entryDate.year,
        entryDate.month,
        entryDate.day,
      );

      final DateTime normalizedStartDate = DateTime(
        sevenDaysAgo.year,
        sevenDaysAgo.month,
        sevenDaysAgo.day,
      );

      final DateTime normalizedToday = DateTime(
        today.year,
        today.month,
        today.day,
      );

      final bool isWithinWeek =
          !normalizedEntryDate.isBefore(normalizedStartDate) &&
          !normalizedEntryDate.isAfter(normalizedToday);

      final String text =
          (entry['text_data'] ?? '').toString().trim();

      return isWithinWeek && text.isNotEmpty;
    }).toList();

    setState(() {
      weeklyEntries = entries;
      isLoading = false;
    });
  }

  String _buildWeeklyText() {
    if (weeklyEntries.isEmpty) {
      return '';
    }

    return weeklyEntries.map((entry) {
      final DateTime date =
          DateTime.parse(entry['date']);

      final String formattedDate =
          DateFormat('MMM d, yyyy').format(date);

      final String title =
          (entry['title'] ?? '').toString().trim();

      final String text =
          (entry['text_data'] ?? '').toString().trim();

      return '''
Date: $formattedDate
Title: $title
Entry: $text
''';
    }).join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final String weeklyText = _buildWeeklyText();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weekly Summary',
        ),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : weeklyEntries.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Add diary entries during the week to generate your weekly summary.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Last 7 Days',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        '${weeklyEntries.length} diary entr${weeklyEntries.length == 1 ? 'y' : 'ies'} found',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium,
                      ),

                      const SizedBox(height: 24),

                      Expanded(
                        child: ListView.builder(
                          itemCount:
                              weeklyEntries.length,
                          itemBuilder:
                              (context, index) {
                            final entry =
                                weeklyEntries[index];

                            final DateTime date =
                                DateTime.parse(
                              entry['date'],
                            );

                            final String title =
                                (entry['title'] ?? '')
                                    .toString();

                            final String text =
                                (entry['text_data'] ?? '')
                                    .toString();

                            return Card(
                              margin:
                                  const EdgeInsets.only(
                                bottom: 12,
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.all(
                                  16,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      DateFormat(
                                        'MMM d, yyyy',
                                      ).format(date),
                                      style: Theme.of(
                                        context,
                                      )
                                          .textTheme
                                          .labelLarge,
                                    ),

                                    const SizedBox(
                                      height: 8,
                                    ),

                                    if (title.trim().isNotEmpty)
                                      Text(
                                        title,
                                        style: Theme.of(
                                          context,
                                        )
                                            .textTheme
                                            .titleMedium,
                                      ),

                                    if (title.trim().isNotEmpty)
                                      const SizedBox(
                                        height: 8,
                                      ),

                                    Text(text),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            debugPrint(
                              weeklyText,
                            );

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Weekly entries are ready for AI summary generation.',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.auto_awesome_rounded,
                          ),
                          label: const Text(
                            'Generate Weekly Summary',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}