import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utility/string_extension.dart';
import '../learning_provider.dart';
import '../models/learning_enrollment_model.dart';

class EnrolledOfferingCard extends ConsumerStatefulWidget {
  final LearningEnrollmentModel enrollment;

  const EnrolledOfferingCard({super.key, required this.enrollment});

  @override
  ConsumerState<EnrolledOfferingCard> createState() =>
      _EnrolledOfferingCardState();
}

class _EnrolledOfferingCardState extends ConsumerState<EnrolledOfferingCard> {
  bool loading = false;

  Future<void> _cancelEnrollment() async {
    final confirmed = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Enrollment'),

          content: const Text(
            'Are you sure you want to cancel this enrollment?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },

              child: const Text('No'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },

              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final service = ref.read(learningServiceProvider);

      await service.cancelEnrollment(widget.enrollment.id);

      ref.invalidate(learnerDashboardProvider);
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void _downloadCertificate() {
    final certificate = widget.enrollment.certificate;

    if (certificate == null || certificate.certificateUrl.isEmpty) {
      return;
    }

    html.window.open(certificate.certificateUrl, '_blank');
  }

  @override
  Widget build(BuildContext context) {
    final enrollment = widget.enrollment;

    debugPrint(
      'Enrollment ${enrollment.id} '
      'issued=${enrollment.certificateIssued} '
      'eligible=${enrollment.certificateEligible} '
      'certificate=${enrollment.certificate}',
    );

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
              enrollment.offering.title,

              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Chip(label: Text(enrollment.enrollmentStatus.displayLabel)),

            const SizedBox(height: 18),

            Text(
              'Progress: '
              '${enrollment.progressPercentage.toStringAsFixed(0)}%',
            ),

            const SizedBox(height: 12),

            LinearProgressIndicator(value: enrollment.progressPercentage / 100),

            const Spacer(),

            if (loading)
              const Center(child: CircularProgressIndicator())
            else ...[
              if (enrollment.certificateIssued &&
                  enrollment.certificate != null)
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    onPressed: _downloadCertificate,

                    icon: const Icon(Icons.workspace_premium),

                    label: const Text('Download Certificate'),
                  ),
                ),

              if (!enrollment.certificateIssued &&
                  enrollment.completionStatus != 'completed')
                Padding(
                  padding: const EdgeInsets.only(top: 12),

                  child: SizedBox(
                    width: double.infinity,

                    child: OutlinedButton.icon(
                      onPressed: _cancelEnrollment,

                      icon: const Icon(Icons.close),

                      label: const Text('Cancel Enrollment'),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
