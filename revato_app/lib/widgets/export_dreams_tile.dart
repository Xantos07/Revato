import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/business/dream_business_service.dart';
import '../services/utils/export_service.dart';

class ExportDreamsTile extends StatelessWidget {
  const ExportDreamsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.download),
      title: const Text('Exporter vos rêves'),
      subtitle: const Text('Télécharger en CSV'),
      trailing: const Icon(Icons.file_download),
      onTap: () => _exportDreamsToCSV(context),
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
}
