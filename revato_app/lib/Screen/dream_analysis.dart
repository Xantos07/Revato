import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revato_app/widgets/dream_app_bar.dart';
import 'package:revato_app/viewmodel/statistics_view_model.dart';
import 'package:revato_app/widgets/Statistics/overview_stats_section.dart';
import 'package:revato_app/widgets/Statistics/tag_stats_section.dart';
import 'package:revato_app/widgets/Statistics/quality_motivation_section.dart';

class DreamAnalysis extends StatefulWidget {
  const DreamAnalysis({super.key});

  @override
  State<DreamAnalysis> createState() => _DreamAnalysisScreenState();
}

class _DreamAnalysisScreenState extends State<DreamAnalysis> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StatisticsViewModel(),
      child: Scaffold(
        appBar: buildDreamAppBar(title: 'Statistiques', context: context),
        body: Consumer<StatisticsViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Calcul des statistiques...'),
                  ],
                ),
              );
            }

            if (viewModel.totalDreams == 0) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assessment_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune statistique disponible',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Commencez par créer quelques rêves pour voir vos statistiques !',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: viewModel.refreshStatistics,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // **STATISTIQUES GÉNÉRALES**
                    _buildSectionTitle('📊 Vue d\'ensemble'),
                    const SizedBox(height: 12),
                    OverviewStatsSection(viewModel: viewModel),

                    const SizedBox(height: 24),

                    // **STATISTIQUES DES TAGS**
                    _buildSectionTitle('🏷️ Tags populaires'),
                    const SizedBox(height: 12),
                    TagStatsSection(viewModel: viewModel),

                    const SizedBox(height: 24),

                    // **QUALITÉ ET MOTIVATION**
                    _buildSectionTitle('⭐ Qualité'),
                    const SizedBox(height: 12),
                    QualityMotivationSection(viewModel: viewModel),

                    const SizedBox(height: 24),

                    // **STATISTIQUES TEMPORELLES**
                    _buildSectionTitle('📅 Répartition temporelle'),
                    const SizedBox(height: 12),
                    _buildTemporalStatsSection(viewModel),

                    const SizedBox(height: 24),

                    // **INFORMATIONS SUPPLÉMENTAIRES**
                    _buildSectionTitle('ℹ️ Informations'),
                    const SizedBox(height: 12),
                    _buildInfoSection(viewModel),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// **CONSTRUCTEURS DE WIDGETS**

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTemporalStatsSection(StatisticsViewModel viewModel) {
    return Column(
      children: [
        // Rêves par jour de la semaine
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rêves par jour de la semaine',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ...viewModel.dreamsByWeekday.entries.map(
                (entry) => _buildWeekdayBar(entry.key, entry.value, viewModel),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Derniers mois
        if (viewModel.dreamsByMonth.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rêves par mois (6 derniers)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                ...viewModel.dreamsByMonth.entries
                    .toList()
                    .reversed
                    .take(6)
                    .map(
                      (entry) =>
                          _buildMonthBar(entry.key, entry.value, viewModel),
                    ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWeekdayBar(
    String day,
    int count,
    StatisticsViewModel viewModel,
  ) {
    final maxCount = viewModel.dreamsByWeekday.values.reduce(
      (a, b) => a > b ? a : b,
    );
    final percentage = maxCount > 0 ? count / maxCount : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(day, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 30,
            child: Text(
              count.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthBar(
    String month,
    int count,
    StatisticsViewModel viewModel,
  ) {
    final maxCount = viewModel.dreamsByMonth.values.reduce(
      (a, b) => a > b ? a : b,
    );
    final percentage = maxCount > 0 ? count / maxCount : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(month, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 30,
            child: Text(
              count.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(StatisticsViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Premier rêve'),
                    Text(
                      viewModel.formatDate(viewModel.firstDreamDate),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(),
          Row(
            children: [
              const Icon(Icons.event, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Dernier rêve'),
                    Text(
                      viewModel.formatDate(viewModel.lastDreamDate),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
