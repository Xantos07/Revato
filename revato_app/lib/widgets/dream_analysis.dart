import 'package:flutter/material.dart';

class DreamAnalysis extends StatefulWidget {
  const DreamAnalysis({super.key});

  @override
  State<DreamAnalysis> createState() => _DreamAnalysisScreenState();
}

class _DreamAnalysisScreenState extends State<DreamAnalysis> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mon analyse de rêve',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF7C3AED)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Analyse de rêve à venir ! \n\n'
                'Cette fonctionnalité est en cours de développement. \n\n'
                'Je fais tout pour que cela arrive !!!  \n\n'
                '😁',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
