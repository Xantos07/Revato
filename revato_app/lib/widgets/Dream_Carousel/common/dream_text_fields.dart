import 'package:flutter/material.dart';
import 'dream_input_decoration.dart';

// ================================
// CHAMPS DE SAISIE SIMPLES
// ================================

/// Champ de texte standard pour le carrousel de rêves
/// Utilise la décoration commune et accepte des paramètres de personnalisation
class DreamTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int minLines;
  final int maxLines;
  final TextStyle? style;

  const DreamTextField({
    required this.label,
    required this.controller,
    this.minLines = 1,
    this.maxLines = 1,
    this.style,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: dreamInputDecoration(context, label),
      style: style ?? const TextStyle(fontSize: 18),
      minLines: minLines,
      maxLines: maxLines,
    );
  }
}

/// Champ de texte spécialisé pour les tags (style plus petit)
/// Wrapper autour de DreamTextField avec des paramètres pré-configurés
class DreamTagsField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const DreamTagsField({
    required this.label,
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DreamTextField(
      label: label,
      controller: controller,
      minLines: 1,
      maxLines: 2,
      style: const TextStyle(fontSize: 16),
    );
  }
}

/// Champ de texte multilignes qui s'étend sur tout l'espace disponible
/// Utilise Expanded pour occuper l'espace restant dans une Column/Flex
class DreamMultilineField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const DreamMultilineField({
    required this.label,
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        controller: controller,
        decoration: dreamInputDecoration(context, label),
        style: const TextStyle(fontSize: 18),
        minLines: null,
        maxLines: null,
        expands: true,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
      ),
    );
  }
}
