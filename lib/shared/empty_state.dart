import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String message;

  const EmptyState({super.key, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(Icons.search_off, size: 72),

            const SizedBox(height: 24),

            Text(
              title,

              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
