import 'package:flutter/material.dart';

import '../../shared/utility/string_extension.dart';
import 'progress_models.dart';

class ProgressSummaryCard extends StatelessWidget {
  final ProgressModel progress;

  const ProgressSummaryCard({super.key, required this.progress});

  Color get progressColor {
    if (progress.progressPercentage >= 100) {
      return Colors.green;
    }

    if (progress.progressPercentage >= 60) {
      return Colors.orange;
    }

    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
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
            Text(
              progress.offeringTitle,

              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            LinearProgressIndicator(
              value: progress.progressPercentage / 100,

              color: progressColor,

              minHeight: 10,
            ),

            const SizedBox(height: 18),

            Text('${progress.progressPercentage.toStringAsFixed(0)}% Complete'),

            const SizedBox(height: 10),

            Text(
              '${progress.attendedSessions} / '
              '${progress.requiredSessions} '
              'Required Sessions Attended',
            ),

            const SizedBox(height: 20),

            Wrap(
              spacing: 12,
              runSpacing: 12,

              children: [
                Chip(label: Text(progress.completionStatus.name.displayLabel)),

                Chip(
                  label: Text(
                    progress.certificateEligible
                        ? 'Certificate Eligible'
                        : 'Not Eligible Yet',
                  ),
                ),

                if (progress.certificateIssued)
                  const Chip(label: Text('Certificate Issued')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
