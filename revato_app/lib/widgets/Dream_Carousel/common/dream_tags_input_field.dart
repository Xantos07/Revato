import 'package:flutter/material.dart';
import 'package:revato_app/widgets/Dream_Carousel/common/components/index.dart';

/// Composant principal de gestion des tags
/// Responsabilité : Orchestration des micro-composants
class DreamTagsInputField extends StatefulWidget {
  final String label;
  final List<String> tags;
  final ValueChanged<List<String>> onChanged;
  final Color chipColor;
  final Color? chipTextColor;
  final Color? addButtonColor;
  final List<String>? existingTags;
  final bool allowEditing;

  const DreamTagsInputField({
    required this.label,
    required this.tags,
    required this.onChanged,
    required this.chipColor,
    this.chipTextColor,
    this.addButtonColor,
    this.existingTags,
    this.allowEditing = false,
    super.key,
  });

  @override
  State<DreamTagsInputField> createState() => _DreamTagsInputFieldState();
}

class _DreamTagsInputFieldState extends State<DreamTagsInputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final TagAutocompleteManager _autocompleteManager = TagAutocompleteManager();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (widget.existingTags != null) {
      setState(() {
        _autocompleteManager.updateSuggestions(
          text: _controller.text,
          existingTags: widget.existingTags!,
          currentTags: widget.tags,
          hasFocus: _focusNode.hasFocus,
        );
      });
    }
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      setState(() {
        _autocompleteManager.updateSuggestions(
          text: _controller.text,
          existingTags: widget.existingTags ?? [],
          currentTags: widget.tags,
          hasFocus: false,
        );
      });
    }
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !widget.tags.contains(tag)) {
      widget.onChanged([...widget.tags, tag]);
      _controller.clear();
      setState(() {
        _autocompleteManager.updateSuggestions(
          text: '',
          existingTags: widget.existingTags ?? [],
          currentTags: [...widget.tags, tag],
          hasFocus: _focusNode.hasFocus,
        );
      });
    }
  }

  void _removeTag(int index) {
    final newTags = List<String>.from(widget.tags);
    newTags.removeAt(index);
    widget.onChanged(newTags);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Champ de saisie
        TagInputWidget(
          label: widget.label,
          controller: _controller,
          focusNode: _focusNode,
          onAddTag: () => _addTag(_controller.text.trim()),
          onSubmitted: _addTag,
          addButtonColor: widget.addButtonColor,
        ),

        const SizedBox(height: 8),

        // Suggestions d'autocomplétion
        if (_autocompleteManager.showSuggestions)
          TagSuggestionsWidget(
            suggestions: _autocompleteManager.suggestions,
            onSuggestionTap: _addTag,
            chipColor: widget.chipColor,
          ),

        const SizedBox(height: 8),

        // Affichage des tags
        TagChipsWidget(
          tags: widget.tags,
          chipColor: widget.chipColor,
          chipTextColor: widget.chipTextColor,
          onRemoveTag: (tag) {
            final index = widget.tags.indexOf(tag);
            if (index >= 0) _removeTag(index);
          },
          onEditTag:
              widget.allowEditing
                  ? (tag) {
                    final index = widget.tags.indexOf(tag);
                    if (index >= 0) {
                      // TODO: Implémenter l'édition de tag
                      // Pour l'instant, on peut juste supprimer et laisser l'utilisateur re-taper
                    }
                  }
                  : null,
        ),
      ],
    );
  }
}
