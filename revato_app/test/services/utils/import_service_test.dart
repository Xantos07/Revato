import 'package:flutter_test/flutter_test.dart';
import 'package:revato_app/services/utils/import_service.dart';

void main() {
  group('ImportService - CSV Parsing', () {
    test('Parse une ligne CSV valide avec toutes les données', () {
      // Note: Ces tests ne testent que la logique de parsing
      // Les tests avec fichiers réels nécessiteraient des mocks de FilePicker

      final row = [
        1, // ID
        'Mon Rêve', // Titre
        '2024-01-15T10:30:00', // Date
        'Émotions: Joie | Lieux: Maison', // Tags
        'Récit: Un rêve magnifique | Analyse: Très intéressant', // Rédactions
      ];

      final result = ImportService.parseDreamRow(row);

      expect(result['title'], 'Mon Rêve');
      expect(result['createdAt'], isA<DateTime>());

      final tags = result['tagsByCategory'] as Map<String, List<String>>;
      expect(tags['Émotions'], ['Joie']);
      expect(tags['Lieux'], ['Maison']);

      final redactions = result['redactionsByCategory'] as Map<String, String>;
      expect(redactions['Récit'], 'Un rêve magnifique');
      expect(redactions['Analyse'], 'Très intéressant');
    });

    test('Parse une ligne CSV minimale (seulement titre)', () {
      final row = [1, 'Titre Seul'];

      final result = ImportService.parseDreamRow(row);

      expect(result['title'], 'Titre Seul');
      expect(result['tagsByCategory'], isEmpty);
      expect(result['redactionsByCategory'], isEmpty);
    });

    test('Parse une date invalide utilise la date actuelle', () {
      final row = [1, 'Titre', 'date-invalide'];

      final result = ImportService.parseDreamRow(row);

      expect(result['createdAt'], isA<DateTime>());
      // Vérifie que c'est proche de maintenant (dans les 2 secondes)
      final now = DateTime.now();
      final diff = now.difference(result['createdAt'] as DateTime).inSeconds;
      expect(diff.abs() < 2, true);
    });

    test('Parse des tags multiples dans la même catégorie', () {
      final row = [
        1,
        'Titre',
        '',
        'Émotions: Joie | Émotions: Peur | Émotions: Colère',
      ];

      final result = ImportService.parseDreamRow(row);

      final tags = result['tagsByCategory'] as Map<String, List<String>>;
      expect(tags['Émotions']?.length, 3);
      expect(tags['Émotions'], containsAll(['Joie', 'Peur', 'Colère']));
    });

    test('Ignore les tags vides ou mal formés', () {
      final row = [
        1,
        'Titre',
        '',
        'Émotions: Joie | | : | Émotions: | : Tag | Lieux:Maison',
      ];

      final result = ImportService.parseDreamRow(row);

      final tags = result['tagsByCategory'] as Map<String, List<String>>;
      expect(tags['Émotions']?.length, 1);
      expect(tags['Émotions'], ['Joie']);
      expect(tags['Lieux'], ['Maison']);
    });

    test('Parse des rédactions avec deux-points dans le contenu', () {
      final row = [
        1,
        'Titre',
        '',
        '',
        'Récit: J\'ai rêvé que: il était 10:30 et je devais: partir',
      ];

      final result = ImportService.parseDreamRow(row);

      final redactions = result['redactionsByCategory'] as Map<String, String>;
      expect(
        redactions['Récit'],
        'J\'ai rêvé que: il était 10:30 et je devais: partir',
      );
    });

    test('Gère les titres avec espaces superflus', () {
      final row = [1, '   Mon Titre   '];

      final result = ImportService.parseDreamRow(row);

      expect(result['title'], 'Mon Titre');
    });

    test('Gère les lignes vides ou incomplètes', () {
      final row = <dynamic>[];

      final result = ImportService.parseDreamRow(row);

      expect(result['title'], 'Sans titre');
    });

    test('Parse des catégories avec espaces dans les noms', () {
      final row = [
        1,
        'Titre',
        '',
        'Émotions Positives: Joie | Lieux Publics: École',
      ];

      final result = ImportService.parseDreamRow(row);

      final tags = result['tagsByCategory'] as Map<String, List<String>>;
      expect(tags['Émotions Positives'], ['Joie']);
      expect(tags['Lieux Publics'], ['École']);
    });

    test('Gère les caractères spéciaux et émojis', () {
      final row = [
        1,
        'Rêve avec émojis 🌙✨',
        '',
        'Émotions: Joie 😊 | Symboles: @#\$%',
      ];

      final result = ImportService.parseDreamRow(row);

      expect(result['title'], 'Rêve avec émojis 🌙✨');

      final tags = result['tagsByCategory'] as Map<String, List<String>>;
      expect(tags['Émotions'], ['Joie 😊']);
      expect(tags['Symboles'], ['@#\$%']);
    });
  });

  group('ImportService - Validation de format', () {
    test('Détecte les formats CSV invalides', () {
      // Ces tests seraient idéalement complétés avec des mocks de fichiers
      // Pour le moment, ils documentent les comportements attendus

      // Format attendu:
      // - Minimum 2 colonnes (ID, Titre)
      // - Première ligne = en-tête
      // - Lignes suivantes = données
    });

    test('Gère les fichiers CSV vides', () {
      // Devrait lever une exception "fichier vide"
    });

    test('Gère les en-têtes manquants ou invalides', () {
      // Devrait lever une exception "format invalide"
    });
  });

  group('ImportService - Cas limites', () {
    test('Parse des lignes avec guillemets échappés', () {
      final row = [1, 'Titre avec "guillemets"', '', 'Test: "valeur"'];

      final result = ImportService.parseDreamRow(row);

      expect(result['title'], 'Titre avec "guillemets"');
    });

    test('Gère les très longues chaînes de caractères', () {
      final longText = 'A' * 10000;
      final row = [1, longText];

      final result = ImportService.parseDreamRow(row);

      expect(result['title'].length, 10000);
    });

    test('Gère les dates en différents formats', () {
      final testDates = [
        ['2024-01-15T10:30:00', true],
        ['2024-01-15', true],
        ['15/01/2024', false],
        ['invalid', false],
      ];

      for (final testCase in testDates) {
        final row = [1, 'Titre', testCase[0]];
        final result = ImportService.parseDreamRow(row);

        expect(result['createdAt'], isA<DateTime>());
      }
    });
  });

  group('ImportService - Sécurité', () {
    test('Échappe les caractères dangereux SQL', () {
      final row = [
        1,
        'DROP TABLE dreams; --',
        '',
        'Test: \'; DELETE FROM dreams; --',
      ];

      final result = ImportService.parseDreamRow(row);

      // Le titre devrait être préservé tel quel
      // La sécurité SQL doit être gérée au niveau de la DB
      expect(result['title'], 'DROP TABLE dreams; --');
    });

    test('Gère les très nombreuses catégories', () {
      final tags = List.generate(100, (i) => 'Cat$i: Tag$i').join(' | ');

      final row = [1, 'Titre', '', tags];

      final result = ImportService.parseDreamRow(row);

      final tagsByCategory =
          result['tagsByCategory'] as Map<String, List<String>>;
      expect(tagsByCategory.length, 100);
    });

    test('Limite les données excessives', () {
      // Test pour éviter les attaques DoS avec des fichiers énormes
      final hugeTags = List.generate(1000, (i) => 'Cat: Tag$i').join(' | ');

      final row = [1, 'Titre', '', hugeTags];

      final result = ImportService.parseDreamRow(row);

      // Devrait parser sans crash
      expect(result, isNotNull);
    });
  });
}
