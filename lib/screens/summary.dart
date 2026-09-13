import 'dart:convert';

import 'package:chronologe_poc/dbhelper.dart';
import 'package:chronologe_poc/env/env.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';

class Summary extends StatefulWidget {
  const Summary({super.key});

  @override
  State<Summary> createState() => _SummaryState();
}

final String geminiApiKey = Env.geminiApiKey;

class _SummaryState extends State<Summary> {
  List<Map<String, dynamic>> weeklyEntries = [];
  bool isLoading = true;

  // Added for Gemini summary generation.
  bool isGenerating = false;
  bool datePicked = false;
  String? generatedTitle;
  String? generatedSummary;
  String? overallMood;
  String? errorMessage;

  late DateTime startDate;
  late DateTime endDate;

  Future<void> _pickWeek(BuildContext context) async {
    DateTime indexDate = DateTime.now();
    DateTime initialDate = indexDate;
    while (indexDate.weekday != DateTime.sunday) {
      indexDate = indexDate.subtract(Duration(days: 1));
      initialDate = indexDate;
    }
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,

      firstDate: DateTime(2026, 8, 1),
      lastDate: DateTime.now(),
      helpText: 'Select a starting week day for summary',

      selectableDayPredicate: (DateTime date) {
        return date.weekday == DateTime.sunday;
      },
    );

    if (pickedDate != null) {
      setState(() {
        startDate = pickedDate;
        // Automatically set end date to the following Saturday (6 days later)
        endDate = pickedDate.add(const Duration(days: 6));

        // Reset Gemini states for the new week
        generatedSummary = null;
        generatedTitle = null;
        overallMood = null;
        errorMessage = null;
        datePicked = true;
      });

      // Fetch the entries for the newly selected week
      _loadWeeklyEntries();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  void _loadWeeklyEntries() {
    final List<Map<String, dynamic>> allEntries =
        DBHelper.getAllEntriesNewestFirst();

    final List<Map<String, dynamic>> entries = allEntries.where((entry) {
      final String dateString = (entry['date'] ?? '').toString();

      final DateTime? entryDate = DateTime.tryParse(dateString);

      if (entryDate == null) {
        return false;
      }

      final DateTime normalizedEntryDate = DateTime(
        entryDate.year,
        entryDate.month,
        entryDate.day,
      );

      final DateTime normalizedStartDate = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );

      final DateTime normalizedEndDate = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
      );

      final bool isWithinWeek =
          !normalizedEntryDate.isBefore(normalizedStartDate) &&
          !normalizedEntryDate.isAfter(normalizedEndDate);

      final String text = (entry['text_data'] ?? '').toString().trim();

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

    return weeklyEntries
        .map((entry) {
          final DateTime date = DateTime.parse(entry['date'].toString());

          final String formattedDate = DateFormat('MMM d, yyyy').format(date);

          final String title = (entry['title'] ?? '').toString().trim();

          final String text = (entry['text_data'] ?? '').toString().trim();

          final String mood = (entry['mood'] ?? '').toString().trim();

          return '''
Date: $formattedDate
Title: $title
Mood: $mood
Entry: $text
''';
        })
        .join('\n');
  }

  Future<void> generateSummary(DateTime startDate, DateTime endDate) async {
    final String weeklyText = _buildWeeklyText();

    if (weeklyText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No diary entries found for this week.')),
      );
      return;
    }

    setState(() {
      isGenerating = true;
      generatedTitle = null;
      generatedSummary = null;
      overallMood = null;
      errorMessage = null;
    });

    try {
      final GenerativeModel model = GenerativeModel(
        model: 'gemini-3.6-flash',
        apiKey: geminiApiKey,
      );

      final String formattedStartDate = DateFormat('MMM d, yyyy')
          .format(startDate);

      final String formattedEndDate = DateFormat('MMM d, yyyy').format(endDate);

      final String prompt =
          '''
          You are an empathetic and precise AI archivist for a private digital diary application.

          Your task is to synthesize the provided weekly journal entries into a "Weekly Memory Wrap-Up." Emulate the style of modern photo or social media memory wraps: focus on overarching themes, meaningful milestones, emotional arcs, and standout moments, rather than providing a dry chronological list.

          CRITICAL RULES:
          1. ZERO HALLUCINATION: You must rely STRICTLY on the provided text. Do not invent events, feelings, names, or outcomes that are not explicitly stated or clearly implied by the entries.
          2. SYNTHESIS OVER SUMMARY: Connect the dots. If the user wrote about studying on Monday and taking a test on Friday, frame it as a week of academic focus. 
          3. TONE: Warm, reflective, and validating.

          Week: 
          $formattedStartDate to$formattedEndDate

          Diary Entries: 
          $weeklyText

          Return ONLY valid JSON matching the exact structure below. Do not use markdown formatting (like ```json), do not include any preamble, and do not add trailing text.

          {
            "title": "A short, evocative, Google-Photos-style title for the week (e.g., 'Quiet Mornings', 'A Week of Hustle', 'Family & Friends')",
            "theme": "A 1-3 word phrase capturing the overarching focus of the week",
            "summary": "A cohesive, 3-5 sentence narrative paragraph. Weave together the important activities, repeating patterns, and emotional shifts of the week. Write in the third person (or tailored to your app's voice, e.g., 'This week, you focused on...').",
            "highlights": [
              "A concise, specific memorable moment extracted from the entries",
              "Another distinct highlight or achievement from the week"
            ],
            "overallMood": "The dominant emotion of the week (one from Calm, Happy, Excited, Reflective, Tired)"
          }
          ''';

      final GenerateContentResponse response = await model.generateContent([
        Content.text(prompt),
      ]);

      final String responseText = response.text?.trim() ?? '';

      if (responseText.isEmpty) {
        throw Exception('Gemini returned an empty response.');
      }

      final Map<String, dynamic> result = jsonDecode(responseText);

      if (!mounted) {
        return;
      }

      setState(() {
        generatedTitle = (result['title'] ?? '').toString();

        generatedSummary = (result['summary'] ?? '').toString();

        overallMood = (result['overallMood'] ?? '').toString();

        isGenerating = false;
      });

      await DBHelper.createSummary(
        startingWeekDate: DateFormat('yyyy-MM-dd').format(startDate),
        title: result['title'],
        theme: result['theme'],
        highlights: result['highlights'],
        summary: result['summary'],
        overallMood: result['overallMood'],
      );

      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Summary saved. Go back to view.')),
      );
      }

    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isGenerating = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedStartDate = '';
    String formattedEndDate = '';
    if (datePicked) {
      formattedStartDate = DateFormat('MMM d').format(startDate);
      formattedEndDate = DateFormat('MMM d, yyyy').format(endDate);
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Summary')),
      body: datePicked
          ? isLoading
                ? const Center(child: CircularProgressIndicator())
                : weeklyEntries.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'No diary entries found between '
                            '$formattedStartDate and $formattedEndDate.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.tertiaryFixed,
                              foregroundColor:
                                  theme.colorScheme.onTertiaryFixed,
                            ),
                            onPressed: () async => await _pickWeek(context),
                            child: Text("Choose another week"),
                          ),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly Entries',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),

                        const SizedBox(height: 8),

                        Text(
                          '$formattedStartDate – $formattedEndDate',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),

                        const SizedBox(height: 8),

                        Text(
                          '${weeklyEntries.length} diary entr${weeklyEntries.length == 1 ? 'y' : 'ies'} found',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),

                        const SizedBox(height: 24),

                        Expanded(
                          child: ListView(
                            children: [
                              ...weeklyEntries.map((entry) {
                                final Map<String, dynamic> entryData = entry;

                                final DateTime date = DateTime.parse(
                                  entryData['date'].toString(),
                                );

                                final String title = (entryData['title'] ?? '')
                                    .toString();

                                final String text =
                                    (entryData['text_data'] ?? '').toString();

                                final String mood = (entryData['mood'] ?? '')
                                    .toString();

                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28),
                                    color: theme.colorScheme.surfaceContainer,
                                  ),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          DateFormat('MMM d, yyyy')
                                              .format(date),
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge,
                                        ),

                                        const SizedBox(height: 8),

                                        if (title.trim().isNotEmpty)
                                          Text(
                                            title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),

                                        if (title.trim().isNotEmpty)
                                          const SizedBox(height: 8),

                                        if (mood.trim().isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 8,
                                            ),
                                            child: Text('Mood: $mood'),
                                          ),

                                        Text(text),
                                      ],
                                    ),
                                  ),
                                );
                              }),

                              // Gemini loading indicator.
                              if (isGenerating)
                                const Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        CircularProgressIndicator(),
                                        SizedBox(height: 12),
                                        Text(
                                          'Generating your weekly summary...',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              // Show Gemini errors if something goes wrong.
                              if (errorMessage != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  "Error!",
                                  style: theme.textTheme.titleSmall!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28),
                                    color: theme.colorScheme.errorContainer,
                                  ),
                                  margin: const EdgeInsets.only(
                                    top: 8,
                                    bottom: 12,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Summary generation failed',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(errorMessage!),
                                      ],
                                    ),
                                  ),
                                ),
                              ],

                              // Show the generated Gemini summary.
                              if (generatedSummary != null)
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28),
                                    color: theme.colorScheme.surfaceContainer,
                                  ),
                                  margin: const EdgeInsets.only(
                                    top: 12,
                                    bottom: 24,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          generatedTitle ?? 'Your Week',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall,
                                        ),

                                        const SizedBox(height: 12),

                                        if (overallMood != null &&
                                            overallMood!.trim().isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 12,
                                            ),
                                            child: Chip(
                                              label: Text(
                                                'Overall Mood: $overallMood',
                                              ),
                                            ),
                                          ),

                                        Text(
                                          generatedSummary!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              enableFeedback: true,
                              elevation: 1,
                              foregroundColor: Theme.of(context)
                                  .colorScheme
                                  .onPrimary,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primary,
                              iconColor: Theme.of(context)
                                  .colorScheme
                                  .onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 12,
                              ),
                            ),
                            onPressed: isGenerating
                                ? null
                                : () {
                                    generateSummary(startDate, endDate);
                                  },
                            icon: const Icon(Icons.auto_awesome_rounded),
                            label: Text(
                              isGenerating
                                  ? 'Generating...'
                                  : 'Generate Weekly Summary',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  )
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 8,
                children: [
                  Text(
                    "Select a Starting week day (Sunday) to get started !",
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.tertiaryFixed,
                      foregroundColor: theme.colorScheme.onTertiaryFixed,
                    ),
                    onPressed: () async => await _pickWeek(context),
                    child: Text("Select Date"),
                  ),
                ],
              ),
            ),
    );
  }
}
