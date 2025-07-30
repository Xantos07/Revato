import 'package:flutter/material.dart';
import 'package:revato_app/widgets/dream_app_bar.dart';

class DreamEditorCarousel extends StatefulWidget {
  const DreamEditorCarousel({super.key});

  @override
  State<DreamEditorCarousel> createState() => _DreamEditorScreenState();
}

class _DreamEditorScreenState extends State<DreamEditorCarousel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: buildDreamAppBar(title: 'Edit', context: context));
  }
}
