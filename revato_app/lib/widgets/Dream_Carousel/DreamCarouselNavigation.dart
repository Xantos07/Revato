import 'package:flutter/material.dart';

class DreamCarouselNavigation extends StatelessWidget {
  final int page;
  final int totalPages;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  const DreamCarouselNavigation({
    required this.page,
    required this.totalPages,
    required this.onPrev,
    required this.onNext,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        children: [
          if (page > 0)
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 18,
                    ),
                  ),
                  onPressed: onPrev,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text(
                    'Précédent',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            )
          else
            const Spacer(),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 22,
                  ),
                ),
                onPressed: onNext,
                icon: Icon(
                  page < totalPages - 1 ? Icons.arrow_forward : Icons.check,
                ),
                label: Text(
                  page < totalPages - 1 ? 'Suivant' : 'Valider',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
