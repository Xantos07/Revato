import 'package:flutter/material.dart';
import 'package:revato_app/viewmodel/dream_filter_view_model.dart';

Widget buildContentTab(DreamFilterViewModel vm) {
  return const SingleChildScrollView(
    padding: EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recherche textuelle',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7C3AED),
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Utilisez la barre de recherche principale pour rechercher dans les titres, le contenu des rêves et les ressentis.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        SizedBox(height: 24),
        Text(
          'Conseils de recherche :',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        Text('• Tapez quelques mots-clés'),
        Text('• La recherche fonctionne dans tous les champs texte'),
        Text('• Combinez avec les filtres par tags pour affiner'),
      ],
    ),
  );
}
