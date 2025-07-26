import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revato_app/widgets/Dream_Carousel/DreamFields.dart';
import '../../viewmodel/dream_writing_view_model.dart';

class DreamTagsInputFieldWithEditing extends StatefulWidget {
  final String label;
  final List<String> tags;
  final ValueChanged<List<String>> onChanged;
  final Color chipColor;
  final Color? chipTextColor;
  final Color? addButtonColor;
  final List<String>? existingTags;

  const DreamTagsInputFieldWithEditing({
    required this.label,
    required this.tags,
    required this.onChanged,
    required this.chipColor,
    this.chipTextColor,
    this.addButtonColor,
    this.existingTags,
    super.key,
  });

  @override
  State<DreamTagsInputFieldWithEditing> createState() =>
      _DreamTagsInputFieldWithEditingState();
}

class _DreamTagsInputFieldWithEditingState
    extends State<DreamTagsInputFieldWithEditing> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _suggestions = [];
  bool _showSuggestions = false;

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

  void editTag(String tag) {
    _controller.text = tag;
    _focusNode.requestFocus();
    _onTextChanged(); // Trigger suggestions update
  }

  void _onTextChanged() {
    final text = _controller.text.toLowerCase();
    if (text.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    final existingTags = widget.existingTags ?? [];
    final filteredSuggestions =
        existingTags
            .where(
              (tag) =>
                  tag.toLowerCase().contains(text) &&
                  !widget.tags.contains(tag),
            )
            .take(5)
            .toList();

    setState(() {
      _suggestions = filteredSuggestions;
      _showSuggestions = filteredSuggestions.isNotEmpty && _focusNode.hasFocus;
    });
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      setState(() {
        _showSuggestions = false;
      });
    } else {
      _onTextChanged();
    }
  }

  void _addTag([String? tagToAdd]) {
    final text = tagToAdd ?? _controller.text.trim();
    if (text.isNotEmpty && !widget.tags.contains(text)) {
      widget.onChanged([...widget.tags, text]);
      _controller.clear();
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
    }
  }

  void _removeTag(String tag) {
    widget.onChanged(widget.tags.where((t) => t != tag).toList());
  }

  /// Affiche la boîte de dialogue pour choisir le type d'édition
  Future<void> _handleTagEdit(String tag) async {
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Modifier le tag',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
              color: Color(0xFF7C3AED),
            ),
          ),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Que voulez-vous faire avec le tag "$tag" ?',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Édition locale : modifie seulement ce rêve\n'
                'Édition globale : modifie tous les rêves utilisant ce tag',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('local'),
              child: const Text('Édition locale'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('global'),
              child: const Text('Édition globale'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('cancel'),
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );

    if (result == 'local') {
      _handleLocalEdit(tag);
    } else if (result == 'global') {
      _handleGlobalEdit(tag);
    }
  }

  /// Édition locale : juste remplir le champ et supprimer de la liste
  void _handleLocalEdit(String tag) {
    editTag(tag);
    final updatedTags = widget.tags.where((t) => t != tag).toList();
    widget.onChanged(updatedTags);
  }

  /// Édition globale : renommer dans tous les rêves
  Future<void> _handleGlobalEdit(String oldTag) async {
    final TextEditingController controller = TextEditingController(
      text: oldTag,
    );

    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Renommer le tag globalement'),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Renommer "$oldTag" dans tous les rêves :'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Nouveau nom du tag',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed:
                  () => Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Renommer'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty && result != oldTag) {
      // Utiliser le ViewModel pour le renommage global
      final viewModel = Provider.of<DreamWritingViewModel>(
        context,
        listen: false,
      );
      final success = await viewModel.renameTagGlobally(oldTag, result);

      if (success) {
        // Mettre à jour la liste locale
        final updatedTags =
            widget.tags.map((tag) => tag == oldTag ? result : tag).toList();
        widget.onChanged(updatedTags);

        // Afficher un message de succès
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Tag "$oldTag" renommé en "$result" dans tous les rêves',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Afficher un message d'erreur
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors du renommage du tag'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Champ de saisie
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: dreamInputDecoration(widget.label),
                onSubmitted: (_) => _addTag(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _addTag(),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    widget.addButtonColor ?? const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(12),
                elevation: 2,
              ),
              child: const Icon(Icons.add, size: 22),
            ),
          ],
        ),
        // Suggestions d'autocomplétion
        if (_showSuggestions && _suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  _suggestions.map((suggestion) {
                    return InkWell(
                      onTap: () => _addTag(suggestion),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border:
                              _suggestions.last != suggestion
                                  ? Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade200,
                                      width: 1,
                                    ),
                                  )
                                  : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.history,
                              size: 16,
                              color: widget.chipColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                suggestion,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Icon(
                              Icons.north_west,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        const SizedBox(height: 10),
        // Tags actuels avec possibilité d'édition
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children:
              widget.tags.map((tag) {
                return GestureDetector(
                  onTap: () => _handleTagEdit(tag),
                  child: Chip(
                    label: Text(
                      tag,
                      style: TextStyle(
                        color: widget.chipTextColor ?? Colors.white,
                      ),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _removeTag(tag),
                    backgroundColor: widget.chipColor,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
