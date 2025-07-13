import 'package:flutter/material.dart';
import 'package:revato_app/widgets/Dream_Carousel/DreamPageBase.dart';
import 'package:revato_app/widgets/Dream_Carousel/Dreamfields.dart';

class DreamTitlePage extends StatelessWidget {
  final TextEditingController controller;
  const DreamTitlePage({required this.controller, super.key});
  @override
  Widget build(BuildContext context) {
    return DreamPageBase(
      title: 'Titre du rêve',
      small: true,
      child: DreamTextField(
        label: 'Titre, ex : La locomotive en or',
        controller: controller,
      ),
    );
  }
}
