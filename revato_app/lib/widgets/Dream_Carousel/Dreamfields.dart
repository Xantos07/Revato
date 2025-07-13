import 'package:flutter/material.dart';

InputDecoration dreamInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: Color.fromARGB(255, 0, 0, 0),
        width: 1.5,
      ),
    ),
    filled: true,
    fillColor: Colors.white,
    labelStyle: const TextStyle(
      color: Color.fromARGB(255, 0, 0, 0),
      fontWeight: FontWeight.w300,
    ),
    floatingLabelStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: Color.fromARGB(255, 0, 0, 0),
        width: 1.5,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: Color.fromARGB(255, 0, 0, 0),
        width: 2,
      ),
    ),
  );
}

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
      decoration: dreamInputDecoration(label),
      style: style ?? const TextStyle(fontSize: 18),
      minLines: minLines,
      maxLines: maxLines,
    );
  }
}

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
        decoration: dreamInputDecoration(label),
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

class DreamTagsInputField extends StatefulWidget {
  final String label;
  final List<String> tags;
  final ValueChanged<List<String>> onChanged;
  final Color chipColor;
  final Color? chipTextColor;
  final Color? addButtonColor;
  final List<String>? existingTags; // Tags existants pour l'autocomplétion
  const DreamTagsInputField({
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
  State<DreamTagsInputField> createState() => _DreamTagsInputFieldState();
}

class _DreamTagsInputFieldState extends State<DreamTagsInputField> {
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
    print('Texte saisi: "$text", Tags existants: $existingTags'); // Debug

    final filteredSuggestions =
        existingTags
            .where(
              (tag) =>
                  tag.toLowerCase().contains(text) &&
                  !widget.tags.contains(tag),
            )
            .take(5)
            .toList();

    print('Suggestions trouvées: $filteredSuggestions'); // Debug

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
      _onTextChanged(); // Recalcule les suggestions quand on refocus
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
        // Tags actuels
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children:
              widget.tags
                  .map(
                    (tag) => Chip(
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
                  )
                  .toList(),
        ),
      ],
    );
  }
}
