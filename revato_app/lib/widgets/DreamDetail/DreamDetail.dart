import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revato_app/model/dream_model.dart';
import 'package:revato_app/services/navigation_core.dart';
import 'package:revato_app/viewmodel/dream_detail_view_model.dart';
import 'package:revato_app/widgets/DreamList/DreamChipsRow.dart';
import 'package:revato_app/widgets/Utils.dart';

class DreamDetail extends StatelessWidget {
  final Dream dream;
  final VoidCallback? onDreamUpdated;

  const DreamDetail({required this.dream, this.onDreamUpdated, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print('WillPopScope: Retour détecté, callback appelé');
        onDreamUpdated?.call(); // Appelle le callback
        return true; // Permet le retour normal
      },
      child: ChangeNotifierProvider(
        create: (context) => DreamDetailViewModel(),
        child: Consumer<DreamDetailViewModel>(
          builder: (context, viewModel, child) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    onDreamUpdated
                        ?.call(); // Appelle le callback pour recharger
                    Navigator.of(context).pop();
                  },
                ),
                title: const Text(
                  'Mon rêve',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    letterSpacing: 1.2,
                  ),
                ),

                elevation: 0,
                centerTitle: true,
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dream.title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,

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
                          redaction.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          redaction.content,
                          style: const TextStyle(fontSize: 16),
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
                      color: Theme.of(context).dividerColor,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            NavigationCore().navigateToEditDream(
                              dream,
                              onDreamUpdated: onDreamUpdated,
                            );
                          },
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
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) =>
                                      _buildDeleteDialog(context, viewModel),
                            );
                          },
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
      ),
    );
  }

  Widget _buildDeleteDialog(context, DreamDetailViewModel viewModel) {
    bool isDeleting = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text(
            'Supprimer votre rêve',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          content: const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Êtes-vous sûr de vouloir supprimer votre rêve ? ',
                ),
                TextSpan(
                  text: '\nCette action est irréversible.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (isDeleting) {
                  await viewModel.deleteDream(dream.id);
                  Navigator.of(context).pop();
                  onDreamUpdated?.call();
                } else {
                  setState(() {
                    isDeleting = true;
                  });
                }
              },
              child:
                  isDeleting
                      ? const Text('Oui je suis sûr')
                      : const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}
