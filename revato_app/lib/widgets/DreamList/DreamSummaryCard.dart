import 'package:flutter/material.dart';
import 'package:revato_app/model/dream_model.dart';
import 'package:revato_app/services/utils/navigation_core.dart';
import 'package:revato_app/widgets/DreamList/DreamChipsRow.dart';
import 'package:revato_app/widgets/Utils.dart';

class DreamSummaryCard extends StatelessWidget {
  final Dream dream;
  final VoidCallback? onDreamUpdated;

  DreamSummaryCard({required this.dream, this.onDreamUpdated, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Créer un aperçu à partir des rédactions disponibles
    String preview = '';
    if (dream.redactions.isNotEmpty) {
      preview = dream.redactions.map((r) => r.content).join(' • ');
    }
    if (preview.isEmpty) {
      preview = 'Aucun contenu disponible';
    }
    if (preview.length > 80) preview = preview.substring(0, 80) + '…';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.surface,
      shadowColor: Theme.of(context).colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          print('Ouverture DreamDetail pour: ${dream.title}');
          // Navigation simple avec callback direct
          NavigationCore().navigateToDreamDetail(
            dream,
            onDreamUpdated: onDreamUpdated,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      dream.title.isNotEmpty ? dream.title : 'Sans titre',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,

                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    formatDate(dream.createdAt),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              DreamChipsRow(dream),
              const SizedBox(height: 12),
              if (preview.isNotEmpty)
                Text(
                  preview,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
