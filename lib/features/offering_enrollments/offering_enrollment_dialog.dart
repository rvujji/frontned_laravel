import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/utility/datetime_extension.dart';
import '../../shared/utility/string_extension.dart';
import 'offering_enrollment_models.dart';
import 'offering_enrollment_provider.dart';

class OfferingEnrollmentDialog extends ConsumerStatefulWidget {
  final OfferingEnrollmentModel enrollment;

  const OfferingEnrollmentDialog({super.key, required this.enrollment});

  @override
  ConsumerState<OfferingEnrollmentDialog> createState() =>
      _OfferingEnrollmentDialogState();
}

class _OfferingEnrollmentDialogState
    extends ConsumerState<OfferingEnrollmentDialog> {
  bool loading = false;

  Future<void> _issueCertificate() async {
    setState(() {
      loading = true;
    });

    try {
      final service = ref.read(offeringEnrollmentServiceProvider);

      await service.issueCertificate(widget.enrollment.id);

      ref.invalidate(offeringEnrollmentProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Certificate issued successfully')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final enrollment = widget.enrollment;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),

      child: Container(
        width: 700,

        padding: const EdgeInsets.all(32),

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Enrollment Details',

                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              _Section(
                title: 'Learner',

                children: [
                  _InfoRow(label: 'Name', value: enrollment.learnerName),

                  _InfoRow(label: 'Email', value: enrollment.learnerEmail),
                ],
              ),

              const SizedBox(height: 28),

              _Section(
                title: 'Offering',

                children: [
                  _InfoRow(label: 'Workshop', value: enrollment.workshopTitle),
                  _InfoRow(label: 'Offering', value: enrollment.offeringTitle),

                  _InfoRow(
                    label: 'Enrolled At',

                    value: enrollment.enrolledAt.readableDateTime,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              _Section(
                title: 'Learning Progress',

                children: [
                  _InfoRow(
                    label: 'Enrollment Status',

                    value: enrollment.enrollmentStatus.name.displayLabel,
                  ),

                  _InfoRow(
                    label: 'Completion Status',

                    value: enrollment.completionStatus.name.displayLabel,
                  ),

                  _InfoRow(
                    label: 'Progress',

                    value:
                        '${enrollment.progressPercentage.toStringAsFixed(0)}%',
                  ),

                  _InfoRow(
                    label: 'Attendance',

                    value:
                        '${enrollment.attendedSessions} / '
                        '${enrollment.totalSessions}',
                  ),

                  _InfoRow(
                    label: 'Attendance %',

                    value:
                        '${enrollment.attendancePercentage.toStringAsFixed(0)}%',
                  ),
                ],
              ),

              const SizedBox(height: 28),

              _Section(
                title: 'Certificates',

                children: [
                  _InfoRow(
                    label: 'Eligible',

                    value: enrollment.certificateEligible ? 'Yes' : 'No',
                  ),

                  _InfoRow(
                    label: 'Issued',

                    value: enrollment.certificateIssued ? 'Yes' : 'No',
                  ),
                ],
              ),

              const SizedBox(height: 36),

              if (loading)
                const Center(child: CircularProgressIndicator())
              else if (enrollment.certificateEligible &&
                  !enrollment.certificateIssued)
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    onPressed: _issueCertificate,

                    icon: const Icon(Icons.workspace_premium),

                    label: const Text('Issue Certificate'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;

  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          title,

          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 18),

        ...children,
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;

  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          SizedBox(
            width: 180,

            child: Text(label, style: TextStyle(color: Colors.grey.shade700)),
          ),

          Expanded(
            child: Text(
              value,

              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
