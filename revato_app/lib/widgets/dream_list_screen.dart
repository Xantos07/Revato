import 'package:flutter/material.dart';
import 'package:revato_app/model/dream_model.dart';
import 'package:revato_app/services/dream_service.dart';
import 'package:revato_app/widgets/DreamList/DreamSummaryCard.dart';

class DreamListScreen extends StatelessWidget {
  const DreamListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DreamService _dreamService = DreamService();
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
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Dream>>(
              future: _dreamService.getAllDreamsWithTagsAndRedactions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final dreams = snapshot.data ?? [];
                if (dreams.isEmpty) {
                  return const Center(child: Text('Aucun rêve enregistré.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: dreams.length,
                  itemBuilder: (context, index) {
                    final dream = dreams[index];
                    return DreamSummaryCard(dream: dream);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
