import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

/// Service pour gérer l'importation de rêves depuis un fichier CSV
class ImportService {
  /// Ouvre un sélecteur de fichier et importe les rêves depuis un CSV
  static Future<List<Map<String, dynamic>>> importDreamsFromCSV() async {
    try {
      // Ouvrir le sélecteur de fichier
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        throw Exception('Aucun fichier sélectionné');
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        throw Exception('Impossible de lire le chemin du fichier');
      }

      // Lire le fichier CSV
      final file = File(filePath);
      final csvString = await file.readAsString();

      // Parser le CSV
      final csvData = const CsvToListConverter().convert(csvString);

      if (csvData.isEmpty || csvData.length < 2) {
        throw Exception('Le fichier CSV est vide ou invalide');
      }

      // Vérifier l'en-tête
      final headers = csvData[0].map((e) => e.toString()).toList();

      if (headers.length < 3) {
        throw Exception('Format CSV invalide : en-tête incomplet');
      }

      // Parser les rêves (ignorer l'en-tête)
      List<Map<String, dynamic>> dreams = [];

      for (int i = 1; i < csvData.length; i++) {
        final row = csvData[i];

        if (row.isEmpty || row.length < 2) continue;

        try {
          final dream = parseDreamRow(row);
          dreams.add(dream);
        } catch (e) {
          print('Erreur lors du parsing de la ligne $i: $e');
          // Continuer avec les autres lignes
        }
      }

      return dreams;
    } catch (e) {
      print('Erreur lors de l\'importation: $e');
      rethrow;
    }
  }

  /// Parse une ligne CSV en objet Dream
  /// Exposé publiquement pour les tests
  static Map<String, dynamic> parseDreamRow(List<dynamic> row) {
    // Colonnes attendues : [ID, Titre, Date, Tags, Redactions]
    final title = row.length > 1 ? row[1].toString().trim() : 'Sans titre';
    final dateStr =
        row.length > 2 ? row[2].toString() : DateTime.now().toIso8601String();
    final tagsStr = row.length > 3 ? row[3].toString() : '';
    final redactionsStr = row.length > 4 ? row[4].toString() : '';

    // Parser la date
    DateTime createdAt;
    try {
      createdAt = DateTime.parse(dateStr);
    } catch (e) {
      createdAt = DateTime.now();
    }

    // Parser les tags par catégorie
    // Format: "categoryName: tagName | categoryName: tagName"
    Map<String, List<String>> tagsByCategory = {};
    if (tagsStr.isNotEmpty) {
      final tagPairs = tagsStr
          .split('|')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty);

      for (final pair in tagPairs) {
        final parts = pair.split(':');
        if (parts.length == 2) {
          final categoryName = parts[0].trim();
          final tagName = parts[1].trim();

          if (categoryName.isNotEmpty && tagName.isNotEmpty) {
            if (!tagsByCategory.containsKey(categoryName)) {
              tagsByCategory[categoryName] = [];
            }
            tagsByCategory[categoryName]!.add(tagName);
          }
        }
      }
    }

    // Parser les rédactions par catégorie
    // Format: "categoryName: content | categoryName: content"
    Map<String, String> redactionsByCategory = {};
    if (redactionsStr.isNotEmpty) {
      final redactionPairs = redactionsStr
          .split('|')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty);

      for (final pair in redactionPairs) {
        final parts = pair.split(':');
        if (parts.length >= 2) {
          final categoryName = parts[0].trim();
          // Rejoindre le reste au cas où il y aurait des ':' dans le contenu
          final content = parts.sublist(1).join(':').trim();

          if (categoryName.isNotEmpty && content.isNotEmpty) {
            redactionsByCategory[categoryName] = content;
          }
        }
      }
    }

    return {
      'title': title,
      'createdAt': createdAt,
      'tagsByCategory': tagsByCategory,
      'redactionsByCategory': redactionsByCategory,
    };
  }
}
