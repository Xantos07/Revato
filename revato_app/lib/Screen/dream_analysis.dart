import 'package:flutter/material.dart';
import 'package:revato_app/widgets/dream_app_bar.dart';

class DreamAnalysis extends StatefulWidget {
  const DreamAnalysis({super.key});

  @override
  State<DreamAnalysis> createState() => _DreamAnalysisScreenState();
}

class _DreamAnalysisScreenState extends State<DreamAnalysis> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildDreamAppBar(title: 'Mon analyse de rêve', context: context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Analyse de rêve',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              const Text(
                'Visualisez vos rêves sous forme de graphique interactif',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
