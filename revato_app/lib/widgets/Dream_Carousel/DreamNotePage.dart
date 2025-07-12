import 'package:flutter/material.dart';
import 'package:revato_app/widgets/Dream_Carousel/DreamFields.dart';
import 'package:revato_app/widgets/Dream_Carousel/DreamPageBase.dart';

class DreamNotePage extends StatelessWidget {
  final String title;
  final String label;
  final TextEditingController controller;
  const DreamNotePage({
    required this.title,
    required this.label,
    required this.controller,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return DreamPageBase(
      title: title,
      small: false,
      child: DreamMultilineField(label: label, controller: controller),
    );
  }
}
