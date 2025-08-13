import 'package:flutter/material.dart';
import 'package:revato_app/viewmodel/statistics_view_model.dart';

/// Section des statistiques de tags
class TagStatsSection extends StatelessWidget {
  final StatisticsViewModel viewModel;

  const TagStatsSection({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    if (viewModel.topTags.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: const Center(child: Text('Aucun tag utilisé pour le moment')),
      );
    }

    return Column(
      children: [
        _buildTagSummary(),
        const SizedBox(height: 16),
        _buildTopTagsList(),
      ],
    );
  }

  Widget _buildTagSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                viewModel.totalTags.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const Text('Tags différents'),
            ],
          ),
          Column(
            children: [
              Text(
                viewModel.formatDecimal(viewModel.avgTagsPerDream),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const Text('Tags par rêve'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopTagsList() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children:
            viewModel.topTags.entries
                .take(5)
                .map((entry) => _buildTagItem(entry.key, entry.value))
                .toList(),
      ),
    );
  }

  Widget _buildTagItem(String tagName, int count) {
    final percentage = viewModel.getTagPercentage(tagName);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              tagName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 2,
            child: LinearProgressIndicator(
              value: percentage / 100,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 60,
            child: Text(
              '$count fois',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
