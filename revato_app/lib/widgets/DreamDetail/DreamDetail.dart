import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revato_app/model/dream_model.dart';
import 'package:revato_app/viewmodel/dream_detail_view_model.dart';
import 'package:revato_app/widgets/DreamList/DreamChipsRow.dart';
import 'package:revato_app/widgets/Utils.dart';

class DreamDetail extends StatelessWidget {
  final Dream dream;

  const DreamDetail({required this.dream, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DreamDetailViewModel(),
      child: Consumer<DreamDetailViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Mon rêve',
                style: TextStyle(
                  color: Color(0xFF7C3AED),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  letterSpacing: 1.2,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              iconTheme: const IconThemeData(color: Color(0xFF7C3AED)),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dream.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7C3AED),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rédigé le ${formatDate(dream.createdAt)}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 18),

                  if (dream.redactions.isNotEmpty) ...[
                    for (final redaction in dream.redactions) ...[
                      Text(
                        redaction.displayName ?? 'Sans catégorie',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        redaction.content,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ] else ...[
                    const Text(
                      'Aucun contenu disponible',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                  if (dream.tags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Tags :',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DreamChipsRow(dream),
                  ],

                  // Ajouter en bas de l'écran de détail
                  const SizedBox(height: 34),

                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    height: 1,
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => viewModel.editDream(dream),
                        icon: Icon(Icons.edit, color: Colors.white),
                        label: Text(
                          'Modifier',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            58,
                            136,
                            237,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => viewModel.deleteDream(dream.id),
                        icon: Icon(Icons.delete, color: Colors.white),
                        label: Text(
                          'Supprimer',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
