import 'package:flutter/material.dart';
import '../dream_input_decoration.dart';

// ================================
// COMPOSANT DE SAISIE DE TAGS
// ================================

/// Widget qui gère la saisie d'un nouveau tag
class TagInputWidget extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onAddTag;
  final Function(String) onSubmitted;
  final Color? addButtonColor;

  const TagInputWidget({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.onAddTag,
    required this.onSubmitted,
    this.addButtonColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: dreamInputDecoration(context, label),
            onSubmitted: onSubmitted,
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: onAddTag,
          style: ElevatedButton.styleFrom(
            backgroundColor: addButtonColor ?? const Color(0xFF7C3AED),
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(12),
            elevation: 2,
          ),
          child: const Icon(Icons.add, size: 22),
        ),
      ],
    );
  }
}
