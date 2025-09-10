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
              child: ElevatedButton(
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
                child:
                    page < totalPages - 1
                        ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Suivant',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.arrow_forward),
                          ],
                        )
                        : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Valider',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.check),
                          ],
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
