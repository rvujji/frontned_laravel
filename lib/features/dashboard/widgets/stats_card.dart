import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;

  final IconData icon;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Row(
          children: [
            Icon(icon, size: 40),

            const SizedBox(width: 24),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(title),

                const SizedBox(height: 8),

                Text(
                  value,

                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
