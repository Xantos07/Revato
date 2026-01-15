import 'package:flutter_test/flutter_test.dart';
import 'package:revato_app/services/business/dream_business_service.dart';
import 'package:revato_app/services/data/dream_repository.dart';
import 'package:revato_app/model/dream_model.dart';
import 'package:revato_app/model/tag_individual_model.dart';
import 'package:revato_app/model/redaction_individual_model.dart';

/// Mock DreamRepository pour les tests
class MockDreamRepository extends DreamRepository {
  List<Dream> mockDreams = [];
  int nextId = 1;
  bool shouldThrowError = false;
  bool shouldThrowOnInsert = false;
  String? errorMessage;

  @override
  Future<List<Dream>> getAllDreamsWithAssociations() async {
    if (shouldThrowError && !shouldThrowOnInsert) {
      throw Exception(errorMessage ?? 'Mock error');
    }
    return List.from(mockDreams);
  }

  @override
  Future<Dream?> getDreamWithAssociations(int dreamId) async {
    if (shouldThrowError && !shouldThrowOnInsert) {
      throw Exception(errorMessage ?? 'Mock error');
    }
    try {
      return mockDreams.firstWhere((d) => d.id == dreamId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> insertDreamWithData(Map<String, dynamic> data) async {
    if (shouldThrowError || shouldThrowOnInsert) {
      throw Exception(errorMessage ?? 'Mock error');
    }

    final dream = Dream(
      id: nextId,
      title: data['title'] as String,
      createdAt: DateTime.now(),
      tags: [],
      redactions: [],
    );

    mockDreams.add(dream);
    return nextId++;
  }

  @override
  Future<void> updateDreamWithData(
    int dreamId,
    Map<String, dynamic> data,
  ) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Mock error');
    }

    final index = mockDreams.indexWhere((d) => d.id == dreamId);
    if (index != -1) {
      final oldDream = mockDreams[index];
      mockDreams[index] = Dream(
        id: oldDream.id,
        title: data['title'] as String,
        createdAt: oldDream.createdAt,
        tags: oldDream.tags,
        redactions: oldDream.redactions,
      );
    }
  }

  @override
  Future<bool> deleteDream(int dreamId) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Mock error');
    }

    final index = mockDreams.indexWhere((d) => d.id == dreamId);
    if (index != -1) {
      mockDreams.removeAt(index);
      return true;
    }
    return false;
  }

  void reset() {
    mockDreams.clear();
    nextId = 1;
    shouldThrowError = false;
    shouldThrowOnInsert = false;
    errorMessage = null;
  }
}

void main() {
  group('DreamBusinessService - Import Dreams', () {
    late DreamBusinessService service;
    late MockDreamRepository mockRepo;

    setUp(() {
      mockRepo = MockDreamRepository();
      service = DreamBusinessService(dreamRepo: mockRepo);
    });

    tearDown(() {
      mockRepo.reset();
    });

    test('Import un seul rêve valide', () async {
      final dreamsData = <Map<String, dynamic>>[
        {
          'title': 'Rêve de test',
          'tagsByCategory': <String, List<String>>{
            'Émotions': ['Joie', 'Peur'],
          },
          'redactionsByCategory': <String, String>{
            'Récit': 'Un rêve intéressant',
          },
        },
      ];

      final result = await service.importDreams(dreamsData);

      expect(result['success'], 1);
      expect(result['skipped'], 0);
      expect(result['total'], 1);
      expect(result['errors'], isEmpty);
      expect(mockRepo.mockDreams.length, 1);
      expect(mockRepo.mockDreams.first.title, 'Rêve de test');
    });

    test('Import plusieurs rêves valides', () async {
      final dreamsData = <Map<String, dynamic>>[
        {
          'title': 'Rêve 1',
          'tagsByCategory': <String, List<String>>{},
          'redactionsByCategory': <String, String>{},
        },
        {
          'title': 'Rêve 2',
          'tagsByCategory': <String, List<String>>{},
          'redactionsByCategory': <String, String>{},
        },
        {
          'title': 'Rêve 3',
          'tagsByCategory': <String, List<String>>{},
          'redactionsByCategory': <String, String>{},
        },
      ];

      final result = await service.importDreams(dreamsData);

      expect(result['success'], 3);
      expect(result['skipped'], 0);
      expect(result['total'], 3);
      expect(mockRepo.mockDreams.length, 3);
    });

    test('Gère les titres en conflit en ajoutant un suffixe', () async {
      // Ajouter un rêve existant
      mockRepo.mockDreams.add(
        Dream(
          id: 1,
          title: 'Rêve Existant',
          createdAt: DateTime.now(),
          tags: [],
          redactions: [],
        ),
      );

      final dreamsData = <Map<String, dynamic>>[
        {
          'title': 'Rêve Existant',
          'tagsByCategory': <String, List<String>>{},
          'redactionsByCategory': <String, String>{},
        },
        {
          'title': 'Rêve Existant',
          'tagsByCategory': <String, List<String>>{},
          'redactionsByCategory': <String, String>{},
        },
      ];

      final result = await service.importDreams(dreamsData);

      expect(result['success'], 2);
      expect(mockRepo.mockDreams.length, 3);
      // Vérifier que les titres sont uniques
      final titles = mockRepo.mockDreams.map((d) => d.title).toList();
      expect(titles.contains('Rêve Existant - 1'), true);
      expect(titles.contains('Rêve Existant - 2'), true);
    });

    test('Gère les rêves avec titre vide ou invalide', () async {
      final dreamsData = <Map<String, dynamic>>[
        {
          'title': '',
          'tagsByCategory': <String, List<String>>{},
          'redactionsByCategory': <String, String>{},
        },
        {
          'title': '   ',
          'tagsByCategory': <String, List<String>>{},
          'redactionsByCategory': <String, String>{},
        },
      ];

      final result = await service.importDreams(dreamsData);

      expect(result['skipped'], 2);
      expect(result['success'], 0);
      expect(result['errors'].length, 2);
    });

    test('Continue l\'import même si un rêve échoue', () async {
      final dreamsData = <Map<String, dynamic>>[
        {
          'title': 'Rêve 1',
          'tagsByCategory': <String, List<String>>{},
          'redactionsByCategory': <String, String>{},
        },
        {
          'title': '', // Invalide
          'tagsByCategory': <String, List<String>>{},
          'redactionsByCategory': <String, String>{},
        },
        {
          'title': 'Rêve 3',
          'tagsByCategory': <String, List<String>>{},
          'redactionsByCategory': <String, String>{},
        },
      ];

      final result = await service.importDreams(dreamsData);

      expect(result['success'], 2);
      expect(result['skipped'], 1);
      expect(result['total'], 3);
      expect(mockRepo.mockDreams.length, 2);
    });

    test('Import des rêves avec tags complexes', () async {
      final dreamsData = <Map<String, dynamic>>[
        {
          'title': 'Rêve avec tags',
          'tagsByCategory': <String, List<String>>{
            'Émotions': ['Joie', 'Peur', 'Colère'],
            'Lieux': ['Maison', 'Forêt'],
            'Personnages': ['Ami', 'Famille'],
          },
          'redactionsByCategory': <String, String>{},
        },
      ];

      final result = await service.importDreams(dreamsData);

      expect(result['success'], 1);
      expect(result['skipped'], 0);
    });

    test('Import des rêves avec rédactions multiples', () async {
      final dreamsData = <Map<String, dynamic>>[
        {
          'title': 'Rêve avec rédactions',
          'tagsByCategory': <String, List<String>>{},
          'redactionsByCategory': <String, String>{
            'Récit': 'Un long récit détaillé...',
            'Analyse': 'Une analyse profonde...',
            'Ressenti': 'Des émotions intenses...',
          },
        },
      ];

      final result = await service.importDreams(dreamsData);

      expect(result['success'], 1);
      expect(result['skipped'], 0);
    });

    test('Gère les doublons dans le même lot d\'import', () async {
      final dreamsData = <Map<String, dynamic>>[
        {
          'title': 'Même Titre',
          'tagsByCategory': <String, List<String>>{},
          'redactionsByCategory': <String, String>{},
        },
        {
          'title': 'Même Titre',
          'tagsByCategory': <String, List<String>>{},
          'redactionsByCategory': <String, String>{},
        },
        {
          'title': 'Même Titre',
          'tagsByCategory': <String, List<String>>{},
          'redactionsByCategory': <String, String>{},
        },
      ];

      final result = await service.importDreams(dreamsData);

      expect(result['success'], 3);
      final titles = mockRepo.mockDreams.map((d) => d.title).toSet();
      expect(titles.length, 3); // Tous les titres doivent être uniques
    });

    test('Import avec liste vide retourne 0 succès', () async {
      final result = await service.importDreams([]);

      expect(result['success'], 0);
      expect(result['skipped'], 0);
      expect(result['total'], 0);
      expect(mockRepo.mockDreams.length, 0);
    });

    test('Gère les erreurs de base de données', () async {
      // Déclencher l'erreur uniquement pour l'insertion
      mockRepo.shouldThrowOnInsert = true;
      mockRepo.errorMessage = 'Database insert failed';

      final dreamsData = <Map<String, dynamic>>[
        {
          'title': 'Rêve Test',
          'tagsByCategory': <String, List<String>>{},
          'redactionsByCategory': <String, String>{},
        },
      ];

      final result = await service.importDreams(dreamsData);

      expect(result['success'], 0);
      expect(result['skipped'], 1);
      expect(result['errors'].isNotEmpty, true);
    });

    test('Nettoie les tags invalides avant import', () async {
      final dreamsData = <Map<String, dynamic>>[
        {
          'title': 'Rêve avec tags invalides',
          'tagsByCategory': <String, List<String>>{
            'Émotions': ['Joie', '', '  ', 'Peur', 'Joie'], // Doublons et vides
          },
          'redactionsByCategory': <String, String>{},
        },
      ];

      final result = await service.importDreams(dreamsData);

      expect(result['success'], 1);
      // La validation devrait nettoyer les tags
    });

    test('Gère les caractères spéciaux dans les titres', () async {
      final dreamsData = <Map<String, dynamic>>[
        {
          'title': 'Rêve avec émojis 🌙✨',
          'tagsByCategory': <String, List<String>>{},
          'redactionsByCategory': <String, String>{},
        },
        {
          'title': 'Rêve avec "guillemets" et \'apostrophes\'',
          'tagsByCategory': <String, List<String>>{},
          'redactionsByCategory': <String, String>{},
        },
        {
          'title': 'Rêve avec des | pipes & symboles @#\$',
          'tagsByCategory': <String, List<String>>{},
          'redactionsByCategory': <String, String>{},
        },
      ];

      final result = await service.importDreams(dreamsData);

      expect(result['success'], 3);
      expect(mockRepo.mockDreams.length, 3);
    });

    test('Import massif de 100 rêves', () async {
      final dreamsData = List.generate(
        100,
        (i) => <String, dynamic>{
          'title': 'Rêve numéro $i',
          'tagsByCategory': <String, List<String>>{
            'Test': ['Tag$i'],
          },
          'redactionsByCategory': <String, String>{'Récit': 'Contenu $i'},
        },
      );

      final result = await service.importDreams(dreamsData);

      expect(result['success'], 100);
      expect(result['skipped'], 0);
      expect(mockRepo.mockDreams.length, 100);
    });

    test('Gère les catégories non existantes en DB', () async {
      // Un rêve avec des catégories qui n'existent pas encore
      final dreamsData = <Map<String, dynamic>>[
        {
          'title': 'Rêve avec catégories inconnues',
          'tagsByCategory': <String, List<String>>{
            'Sport': ['Football', 'Tennis'], // Catégorie inexistante
            'Lieux': ['Madrid', 'Paris'], // Catégorie existante
          },
          'redactionsByCategory': <String, String>{
            'Mon analyse sportive':
                'J\'ai rêvé de sport', // Catégorie inexistante
          },
        },
      ];

      final result = await service.importDreams(dreamsData);

      // L'import devrait réussir car les catégories sont créées automatiquement
      expect(result['success'], 1);
      expect(result['skipped'], 0);
      expect(mockRepo.mockDreams.length, 1);
    });

    test('Gère les rêves avec certaines catégories vides', () async {
      final dreamsData = <Map<String, dynamic>>[
        {
          'title': 'Rêve incomplet',
          'tagsByCategory': <String, List<String>>{
            'Lieux': ['Madrid', 'Paris'],
            // Pas de catégorie Émotions
            // Pas de catégorie Personnages
          },
          'redactionsByCategory': <String, String>{
            'Récit': 'Un simple récit',
            // Pas d\'Analyse
            // Pas de Ressenti
          },
        },
      ];

      final result = await service.importDreams(dreamsData);

      expect(result['success'], 1);
      expect(result['skipped'], 0);
      expect(mockRepo.mockDreams.length, 1);
    });

    test('Gère un mix de catégories existantes et nouvelles', () async {
      final dreamsData = <Map<String, dynamic>>[
        {
          'title': 'Rêve mixte 1',
          'tagsByCategory': <String, List<String>>{
            'Émotions': ['Joie'], // Existante
            'Météo': ['Ensoleillé'], // Nouvelle
          },
          'redactionsByCategory': <String, String>{},
        },
        {
          'title': 'Rêve mixte 2',
          'tagsByCategory': <String, List<String>>{
            'Météo': ['Pluvieux'], // Réutilise la nouvelle catégorie
            'Animaux': ['Chat', 'Chien'], // Encore une nouvelle
          },
          'redactionsByCategory': <String, String>{},
        },
      ];

      final result = await service.importDreams(dreamsData);

      expect(result['success'], 2);
      expect(result['skipped'], 0);
      expect(mockRepo.mockDreams.length, 2);
    });

    test('Les IDs du CSV sont ignorés - nouveaux IDs auto-générés', () async {
      // Simuler un CSV avec des IDs spécifiques (qui seront ignorés)
      // Dans un vrai CSV: ID=1000, ID=2000, ID=3000
      final dreamsData = <Map<String, dynamic>>[
        {
          'title': 'Rêve avec ancien ID 1000',
          'tagsByCategory': <String, List<String>>{},
          'redactionsByCategory': <String, String>{},
        },
        {
          'title': 'Rêve avec ancien ID 2000',
          'tagsByCategory': <String, List<String>>{},
          'redactionsByCategory': <String, String>{},
        },
        {
          'title': 'Rêve avec ancien ID 3000',
          'tagsByCategory': <String, List<String>>{},
          'redactionsByCategory': <String, String>{},
        },
      ];

      final result = await service.importDreams(dreamsData);

      expect(result['success'], 3);
      expect(mockRepo.mockDreams.length, 3);

      // Vérifier que les IDs sont séquentiels à partir de nextId du mock
      expect(mockRepo.mockDreams[0].id, 1); // Premier ID généré
      expect(mockRepo.mockDreams[1].id, 2); // Deuxième ID généré
      expect(mockRepo.mockDreams[2].id, 3); // Troisième ID généré
      // Les IDs 1000, 2000, 3000 du CSV sont complètement ignorés
    });
  });

  group('DreamBusinessService - Validation', () {
    late DreamBusinessService service;

    setUp(() {
      service = DreamBusinessService(dreamRepo: MockDreamRepository());
    });

    test('Valide correctement les données complètes', () {
      final data = <String, dynamic>{
        'title': 'Titre valide',
        'tagsByCategory': <String, List<String>>{
          'Émotions': ['Joie', 'Peur'],
        },
        'redactionsByCategory': <String, String>{'Récit': 'Un récit'},
      };

      final validated = service.validateDreamData(data);

      expect(validated['title'], 'Titre valide');
      expect(validated['tagsByCategory']['Émotions'], ['Joie', 'Peur']);
      expect(validated['redactionsByCategory']['Récit'], 'Un récit');
    });

    test('Rejette les titres vides', () {
      final data = <String, dynamic>{
        'title': '',
        'tagsByCategory': <String, List<String>>{},
        'redactionsByCategory': <String, String>{},
      };

      expect(
        () => service.validateDreamData(data),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Trim les espaces du titre', () {
      final data = <String, dynamic>{
        'title': '   Titre avec espaces   ',
        'tagsByCategory': <String, List<String>>{},
        'redactionsByCategory': <String, String>{},
      };

      final validated = service.validateDreamData(data);
      expect(validated['title'], 'Titre avec espaces');
    });

    test('Supprime les tags vides et doublons', () {
      final data = <String, dynamic>{
        'title': 'Test',
        'tagsByCategory': <String, List<String>>{
          'Émotions': ['Joie', '', 'Peur', '   ', 'Joie', 'Colère'],
        },
        'redactionsByCategory': <String, String>{},
      };

      final validated = service.validateDreamData(data);
      final tags = validated['tagsByCategory']['Émotions'] as List<String>;

      expect(tags.length, 3);
      expect(tags.contains('Joie'), true);
      expect(tags.contains('Peur'), true);
      expect(tags.contains('Colère'), true);
    });

    test('Supprime les rédactions vides', () {
      final data = <String, dynamic>{
        'title': 'Test',
        'tagsByCategory': <String, List<String>>{},
        'redactionsByCategory': <String, String>{
          'Récit': 'Contenu valide',
          'Analyse': '   ',
          'Ressenti': '',
        },
      };

      final validated = service.validateDreamData(data);
      final redactions =
          validated['redactionsByCategory'] as Map<String, String>;

      expect(redactions.length, 1);
      expect(redactions.containsKey('Récit'), true);
      expect(redactions.containsKey('Analyse'), false);
    });

    test('Gère les données nulles ou manquantes', () {
      final data = <String, dynamic>{'title': 'Test'};

      final validated = service.validateDreamData(data);

      expect(validated['tagsByCategory'], isEmpty);
      expect(validated['redactionsByCategory'], isEmpty);
    });
  });

  group('DreamBusinessService - Operations CRUD', () {
    late DreamBusinessService service;
    late MockDreamRepository mockRepo;

    setUp(() {
      mockRepo = MockDreamRepository();
      service = DreamBusinessService(dreamRepo: mockRepo);
    });

    test('Crée un rêve avec données valides', () async {
      final data = <String, dynamic>{
        'title': 'Nouveau rêve',
        'tagsByCategory': <String, List<String>>{},
        'redactionsByCategory': <String, String>{},
      };

      final id = await service.createDream(data);

      expect(id, 1);
      expect(mockRepo.mockDreams.length, 1);
    });

    test('Met à jour un rêve existant', () async {
      mockRepo.mockDreams.add(
        Dream(
          id: 1,
          title: 'Ancien titre',
          createdAt: DateTime.now(),
          tags: [],
          redactions: [],
        ),
      );

      final data = <String, dynamic>{
        'title': 'Nouveau titre',
        'tagsByCategory': <String, List<String>>{},
        'redactionsByCategory': <String, String>{},
      };

      await service.updateDream(1, data);

      expect(mockRepo.mockDreams.first.title, 'Nouveau titre');
    });

    test('Supprime un rêve existant', () async {
      mockRepo.mockDreams.add(
        Dream(
          id: 1,
          title: 'À supprimer',
          createdAt: DateTime.now(),
          tags: [],
          redactions: [],
        ),
      );

      final success = await service.deleteDream(1);

      expect(success, true);
      expect(mockRepo.mockDreams.length, 0);
    });

    test('Rejette les ID invalides pour update', () async {
      expect(
        () => service.updateDream(0, <String, dynamic>{'title': 'Test'}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Rejette les ID invalides pour delete', () async {
      expect(() => service.deleteDream(-1), throwsA(isA<ArgumentError>()));
    });
  });

  group('DreamBusinessService - Filtrage', () {
    late DreamBusinessService service;
    late List<Dream> testDreams;

    setUp(() {
      service = DreamBusinessService(dreamRepo: MockDreamRepository());

      testDreams = [
        Dream(
          id: 1,
          title: 'Rêve de vol',
          createdAt: DateTime(2024, 1, 1),
          tags: [
            Tag(
              id: 1,
              name: 'Liberté',
              categoryName: 'Émotions',
              color: '#FF0000',
            ),
            Tag(id: 2, name: 'Ciel', categoryName: 'Lieux', color: '#0000FF'),
          ],
          redactions: [
            Redaction(
              id: 1,
              content: 'Je volais au-dessus des nuages',
              categoryName: 'Récit',
              displayName: 'Récit',
            ),
          ],
        ),
        Dream(
          id: 2,
          title: 'Rêve de mer',
          createdAt: DateTime(2024, 2, 1),
          tags: [
            Tag(
              id: 3,
              name: 'Peur',
              categoryName: 'Émotions',
              color: '#000000',
            ),
          ],
          redactions: [
            Redaction(
              id: 2,
              content: 'La mer était déchaînée',
              categoryName: 'Récit',
              displayName: 'Récit',
            ),
          ],
        ),
      ];
    });

    test('Filtre par texte dans le titre', () {
      final filtered = service.filterDreams(testDreams, searchText: 'vol');

      expect(filtered.length, 1);
      expect(filtered.first.title, 'Rêve de vol');
    });

    test('Filtre par texte dans le contenu', () {
      final filtered = service.filterDreams(
        testDreams,
        searchText: 'déchaînée',
      );

      expect(filtered.length, 1);
      expect(filtered.first.title, 'Rêve de mer');
    });

    test('Filtre par tags requis', () {
      final filtered = service.filterDreams(
        testDreams,
        requiredTags: ['Liberté'],
      );

      expect(filtered.length, 1);
      expect(filtered.first.title, 'Rêve de vol');
    });

    test('Filtre par date de début', () {
      final filtered = service.filterDreams(
        testDreams,
        fromDate: DateTime(2024, 1, 15),
      );

      expect(filtered.length, 1);
      expect(filtered.first.title, 'Rêve de mer');
    });

    test('Filtre par date de fin', () {
      final filtered = service.filterDreams(
        testDreams,
        toDate: DateTime(2024, 1, 15),
      );

      expect(filtered.length, 1);
      expect(filtered.first.title, 'Rêve de vol');
    });

    test('Combine plusieurs filtres', () {
      final filtered = service.filterDreams(
        testDreams,
        searchText: 'Rêve',
        fromDate: DateTime(2024, 1, 1),
        toDate: DateTime(2024, 2, 28),
      );

      expect(filtered.length, 2);
    });
  });
}
