import 'package:flutter/material.dart';

class DreamPageBase extends StatelessWidget {
  final String title;
  final Widget child;
  final bool small;
  const DreamPageBase({
    required this.title,
    required this.child,
    this.small = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: small ? 32 : 16, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          small ? Expanded(child: SingleChildScrollView(child: child)) : child,
        ],
      ),
    );
  }
}
