import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../../model/dream_model.dart';

class ExportService {
  static Future<String> exportDreamsToCSV(List<Dream> dreams) async {
    List<List<String>> csvData = [
      ['ID', 'Titre', 'Date', 'Tags', 'Redactions'],
    ];

    for (var dream in dreams) {
      csvData.add([
        dream.id.toString(),
        dream.title,
        dream.createdAt.toString(),

        dream.tags.map((tag) => '${tag.categoryName}: ${tag.name}').join(' | '),
        dream.redactions
            .map(
              (redaction) => '${redaction.categoryName}: ${redaction.content}',
            )
            .join(' | '),
      ]);
    }
    String csv = const ListToCsvConverter().convert(csvData);

    final fileName = 'mes_reves_${DateTime.now().millisecondsSinceEpoch}.csv';

    // UNIQUEMENT sauvegarde externe
    final Directory? externalDir = await getExternalStorageDirectory();
    if (externalDir == null) {
      throw Exception('Stockage externe non disponible');
    }

    final List<String> pathSegments = externalDir.path.split('/');
    final int androidIndex = pathSegments.indexOf('Android');
    if (androidIndex <= 0) {
      throw Exception('Impossible de localiser le dossier Downloads');
    }

    final String publicPath = pathSegments.sublist(0, androidIndex).join('/');
    final String downloadsPath = '$publicPath/Download';
    final downloadDir = Directory(downloadsPath);

    if (!await downloadDir.exists()) {
      throw Exception('Dossier Downloads introuvable : $downloadsPath');
    }

    final file = File('$downloadsPath/$fileName');
    await file.writeAsString(csv);
    print('CSV sauvegardé dans Downloads: ${file.path}');
    return file.path;
  }
}
