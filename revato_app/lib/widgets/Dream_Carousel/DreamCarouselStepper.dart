import 'package:flutter/material.dart';

class DreamCarouselStepper extends StatelessWidget {
  final int page;
  final int total;
  const DreamCarouselStepper({
    required this.page,
    required this.total,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        total,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == page ? 22 : 12,
          height: 12,
          decoration: BoxDecoration(
            color:
                i == page
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
            boxShadow:
                i == page
                    ? [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : [],
          ),
        ),
      ),
    );
  }
}
