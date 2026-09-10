import 'package:chronologe_poc/screens/diaryview.dart';
import 'package:chronologe_poc/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DiarySearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> entries;
  final Map<String, String> imagePaths;

  DiarySearchDelegate({
    required this.entries,
    required this.imagePaths,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          tooltip: 'Clear',
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final searchQuery = query.trim().toLowerCase();

    final results = searchQuery.isEmpty
        ? <Map<String, dynamic>>[]
        : entries.where((entry) {
            final title = (entry['title'] ?? '').toString().toLowerCase();
            final description =
                (entry['text_data'] ?? '').toString().toLowerCase();
            final mood = (entry['mood'] ?? '').toString().toLowerCase();

            return title.contains(searchQuery) ||
                description.contains(searchQuery) ||
                mood.contains(searchQuery);
          }).toList();

    if (searchQuery.isEmpty) {
      return const Center(
        child: Text('Search your diary entries'),
      );
    }

    if (results.isEmpty) {
      return const Center(
        child: Text('No entries found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final entry = results[index];

        final String dbKey = entry['dbkey'].toString();
        final String? imagePath = imagePaths[dbKey];

        return TimelineCard(
          title: (entry['title'] ?? '').toString(),
          description: (entry['text_data'] ?? '').toString(),
          formattedDate: DateFormat(
            'MMM d, yyyy',
          ).format(DateTime.parse(entry['date'].toString())),
          imagePath: imagePath,
          mood: (entry['mood'] ?? '').toString(),
          onTap: () {
            close(context, null);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DiaryView(
                  dateKey: dbKey,
                ),
              ),
            );
          },
        );
      },
    );
  }
} 