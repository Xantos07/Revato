import 'package:flutter/material.dart';
import 'package:revato_app/viewmodel/statistics_view_model.dart';

/// Section dédiée à l'analyse de qualité et motivation
class QualityMotivationSection extends StatelessWidget {
  final StatisticsViewModel viewModel;

  const QualityMotivationSection({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          _buildContentRichness(),
          const SizedBox(height: 20),
          _buildCurrentStreak(),
          const SizedBox(height: 20),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildContentRichness() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.article, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Richesse du contenu'),
                  Text(
                    '${viewModel.dreamsWithRedactions}/${viewModel.totalDreams} rêves avec rédaction',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Text(
              '${viewModel.contentRichness}%',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: viewModel.contentRichness / 100,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          backgroundColor: Colors.grey[300],
        ),
      ],
    );
  }

  Widget _buildCurrentStreak() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.local_fire_department, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Série actuelle'),
                  Text(
                    viewModel.currentStreak > 0
                        ? '${viewModel.currentStreak} jours consécutifs !'
                        : 'Aucune série en cours',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            if (viewModel.currentStreak > 0)
              const Text('🔥', style: TextStyle(fontSize: 24)),
          ],
        ),
        if (viewModel.longestStreak > viewModel.currentStreak) ...[
          const SizedBox(height: 12),
          Text(
            'Record personnel: ${viewModel.longestStreak} jours',
            style: TextStyle(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Row(
      children: [
        const Icon(Icons.trending_up, color: Colors.teal),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Activité récente'),
              Text(
                '${viewModel.recentDreams} rêves cette semaine',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getActivityColor(viewModel.recentDreams),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            _getActivityLabel(viewModel.recentDreams),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Color _getActivityColor(int recentDreams) {
    if (recentDreams >= 7) return Colors.green;
    if (recentDreams >= 4) return Colors.orange;
    if (recentDreams >= 1) return Colors.blue;
    return Colors.grey;
  }

  String _getActivityLabel(int recentDreams) {
    if (recentDreams >= 7) return 'EXCELLENT';
    if (recentDreams >= 4) return 'BIEN';
    if (recentDreams >= 1) return 'MOYEN';
    return 'FAIBLE';
  }
}
