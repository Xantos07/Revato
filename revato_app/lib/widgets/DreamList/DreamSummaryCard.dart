import 'package:flutter/material.dart';
import 'package:revato_app/model/dream_model.dart';
import 'package:revato_app/services/navigation_core.dart';
import 'package:revato_app/widgets/DreamList/DreamChipsRow.dart';
import 'package:revato_app/widgets/Utils.dart';

class DreamSummaryCard extends StatelessWidget {
  final Dream dream;

  DreamSummaryCard({required this.dream, Key? key}) : super(key: key);

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
      color: Colors.white,
      shadowColor: Colors.deepPurple.withOpacity(0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigation vers les détails du rêve
          NavigationCore().navigateToDreamDetail(dream);
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
                        color: Color(0xFF7C3AED),
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    formatDate(dream.createdAt),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              DreamChipsRow(dream),
              const SizedBox(height: 12),
              if (preview.isNotEmpty)
                Text(
                  preview,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
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
