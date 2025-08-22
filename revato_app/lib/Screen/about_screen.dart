import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revato_app/themes/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('À propos')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Logo/Icône de l'app
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Center(
                child: Icon(
                  Icons.nights_stay,
                  size: 80,
                  color:
                      themeProvider.isDarkMode
                          ? Colors.white
                          : const Color(0xFF7C3AED),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Nom de l'app
          const Center(
            child: Text(
              'Revato',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),

          // Description
          const Center(
            child: Text(
              'Journal de rêves pour noter, organiser et analyser vos rêves',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 32),

          // Informations
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info),
                  title: Text('Version'),
                  subtitle: Text('0.3.1'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Développeur'),
                  subtitle: const Text('Xantos07'),
                  onTap:
                      () => _launchUrl(context, 'https://github.com/Xantos07'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('Code source'),
                  subtitle: const Text('Voir sur GitHub'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap:
                      () => _launchUrl(
                        context,
                        'https://github.com/Xantos07/Revato',
                      ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.bug_report),
                  title: const Text('Signaler un bug'),
                  subtitle: const Text('Issues GitHub'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap:
                      () => _launchUrl(
                        context,
                        'https://github.com/Xantos07/Revato/issues',
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Fonctionnalités
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Fonctionnalités',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.create),
                  title: Text('Écriture de rêves'),
                  subtitle: Text('Interface intuitive pour capturer vos rêves'),
                ),
                const ListTile(
                  leading: Icon(Icons.label),
                  title: Text('Tags et catégories'),
                  subtitle: Text(
                    'Organisez vos rêves avec des tags personnalisés',
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.analytics),
                  title: Text('Analyses et graphiques'),
                  subtitle: Text('Visualisez vos patterns de rêves'),
                ),
                const ListTile(
                  leading: Icon(Icons.search),
                  title: Text('Recherche avancée'),
                  subtitle: Text('Filtres puissants pour retrouver vos rêves'),
                ),
                const ListTile(
                  leading: Icon(Icons.dark_mode),
                  title: Text('Thème sombre/clair'),
                  subtitle: Text('Interface adaptable à vos préférences'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Confidentialité et données
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Confidentialité',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.security, color: Colors.green),
                  title: Text('Données 100% locales'),
                  subtitle: Text(
                    'Tous vos rêves sont stockés uniquement sur votre appareil. Ils ne quittent jamais votre téléphone',
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.offline_bolt, color: Colors.green),
                  title: Text('Fonctionne hors ligne'),
                  subtitle: Text(
                    'Pas besoin d\'internet pour utiliser l\'application',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Footer
          const Center(
            child: Text(
              'Développé avec ❤️ par Xantos07',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              '© 2025 Xantos07',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    try {
      final Uri uri = Uri.parse(url);
      print('Tentative d\'ouverture de l\'URL: $url');

      if (await canLaunchUrl(uri)) {
        print('URL peut être ouverte, lancement...');
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('URL lancée avec succès');
      } else {
        print('URL ne peut pas être ouverte');
        // Fallback: essayer sans vérification
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Erreur lors de l\'ouverture de l\'URL: $e');
      // Afficher un snackbar à l'utilisateur
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible d\'ouvrir le lien: $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
