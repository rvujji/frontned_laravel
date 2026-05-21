import 'package:flutter/material.dart';

class WorkshopSkeleton extends StatelessWidget {
  const WorkshopSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              height: 24,
              width: double.infinity,

              color: Colors.grey.shade300,
            ),

            const SizedBox(height: 16),

            Container(
              height: 16,
              width: double.infinity,

              color: Colors.grey.shade300,
            ),

            const SizedBox(height: 8),

            Container(height: 16, width: 120, color: Colors.grey.shade300),

            const Spacer(),

            Container(height: 20, width: 80, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}
