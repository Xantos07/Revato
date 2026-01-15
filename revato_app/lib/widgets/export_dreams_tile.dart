import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/business/dream_business_service.dart';
import '../services/utils/export_service.dart';
import '../services/utils/import_service.dart';

class ExportDreamsTile extends StatelessWidget {
  const ExportDreamsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.download),
          title: const Text('Exporter vos rêves'),
          subtitle: const Text('Télécharger en CSV'),
          trailing: const Icon(Icons.file_download),
          onTap: () => _exportDreamsToCSV(context),
        ),
        ListTile(
          leading: const Icon(Icons.upload),
          title: const Text('Importer vos rêves'),
          subtitle: const Text('Charger depuis un CSV'),
          trailing: const Icon(Icons.file_upload),
          onTap: () => _importDreamsFromCSV(context),
        ),
      ],
    );
  }

  Future<void> _exportDreamsToCSV(BuildContext context) async {
    final dreamBusinessService = DreamBusinessService();

    try {
      final dreams =
          await dreamBusinessService.getAllDreamsWithTagsAndRedactions();
      final filePath = await ExportService.exportDreamsToCSV(dreams);

      if (context.mounted) {
        final fileName = filePath.split('/').last;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ CSV exporté : $fileName'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Ouvrir',
              onPressed: () => _openFileManager(context),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'export : $e')),
        );
      }
    }
  }

  Future<void> _openFileManager(BuildContext context) async {
    try {
      final Uri downloadsUri = Uri.parse(
        'content://com.android.externalstorage.documents/document/primary%3ADownload',
      );

      if (await canLaunchUrl(downloadsUri)) {
        await launchUrl(downloadsUri, mode: LaunchMode.externalApplication);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        return;
      }
    } catch (e) {}

    try {
      final Uri fileManagerUri = Uri.parse(
        'content://com.android.documentsui.FileManagerActivity',
      );

      if (await canLaunchUrl(fileManagerUri)) {
        await launchUrl(fileManagerUri, mode: LaunchMode.externalApplication);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        return;
      }
    } catch (e) {}

    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📁 Fichier exporté dans le dossier Téléchargements'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _importDreamsFromCSV(BuildContext context) async {
    final dreamBusinessService = DreamBusinessService();

    try {
      // Afficher un indicateur de chargement
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text('Importation en cours...'),
              ],
            ),
            duration: Duration(seconds: 60),
          ),
        );
      }

      // Importer les rêves depuis le CSV
      final dreamsData = await ImportService.importDreamsFromCSV();

      if (dreamsData.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Aucun rêve trouvé dans le fichier'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Importer les rêves avec gestion des conflits
      final result = await dreamBusinessService.importDreams(dreamsData);

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        final successCount = result['success'] as int;
        final skippedCount = result['skipped'] as int;
        final total = result['total'] as int;

        // Construire le message de résultat
        String message;
        Color backgroundColor;

        if (successCount == total) {
          message = '✅ $successCount rêve(s) importé(s) avec succès';
          backgroundColor = Colors.green;
        } else if (successCount > 0) {
          message =
              '⚠️ $successCount/$total rêve(s) importé(s) ($skippedCount échoué(s))';
          backgroundColor = Colors.orange;
        } else {
          message = '❌ Aucun rêve importé ($skippedCount échec(s))';
          backgroundColor = Colors.red;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message),
                if (successCount > 0)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      '💡 Les catégories manquantes ont été créées automatiquement',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
            backgroundColor: backgroundColor,
            duration: const Duration(seconds: 5),
            action:
                skippedCount > 0
                    ? SnackBarAction(
                      label: 'Détails',
                      textColor: Colors.white,
                      onPressed: () => _showImportDetails(context, result),
                    )
                    : null,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'importation : $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showImportDetails(BuildContext context, Map<String, dynamic> result) {
    final errors = result['errors'] as List<String>;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Détails de l\'importation'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('✅ Succès : ${result['success']}'),
                  Text('❌ Échecs : ${result['skipped']}'),
                  Text('📊 Total : ${result['total']}'),
                  if (errors.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Erreurs :',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...errors.map(
                      (error) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• $error',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fermer'),
              ),
            ],
          ),
    );
  }
}
