import 'package:flutter/material.dart';
import 'package:revato_app/viewmodel/statistics_view_model.dart';
import 'package:revato_app/widgets/Statistics/stat_card_widget.dart';

/// Section des statistiques générales (vue d'ensemble)
class OverviewStatsSection extends StatelessWidget {
  final StatisticsViewModel viewModel;

  const OverviewStatsSection({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCardWidget(
                title: 'Total rêves',
                value: viewModel.totalDreams.toString(),
                icon: Icons.nights_stay,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCardWidget(
                title: 'Richesse',
                value: '${viewModel.contentRichness}%',
                icon: Icons.article,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCardWidget(
                title: 'Streak actuel',
                value: '${viewModel.currentStreak} jours',
                icon: Icons.local_fire_department,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCardWidget(
                title: 'Record',
                value: '${viewModel.longestStreak} jours',
                icon: Icons.emoji_events,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCardWidget(
                title: 'Cette semaine',
                value: viewModel.recentDreams.toString(),
                icon: Icons.date_range,
                color: Colors.teal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCardWidget(
                title: 'Par mois',
                value: viewModel.formatDecimal(viewModel.dreamsPerMonth),
                icon: Icons.calendar_today,
                color: Colors.indigo,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
