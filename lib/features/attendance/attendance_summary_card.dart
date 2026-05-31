import 'package:flutter/material.dart';

class AttendanceSummaryCard extends StatelessWidget {
  final int total;

  final int present;

  final int absent;

  const AttendanceSummaryCard({
    super.key,
    required this.total,
    required this.present,
    required this.absent,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total == 0 ? 0 : ((present / total) * 100).toInt();

    return Card(
      elevation: 0,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),

        side: BorderSide(color: Colors.grey.shade300),
      ),

      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Attendance',

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            LinearProgressIndicator(value: percentage / 100),

            const SizedBox(height: 16),

            Text('$percentage% Attendance'),

            const SizedBox(height: 8),

            Text('$present Present • $absent Absent'),
          ],
        ),
      ),
    );
  }
}
