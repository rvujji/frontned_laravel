import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/utility/datetime_extension.dart';
import '../../shared/utility/string_extension.dart';
import '../dashboard/widgets/dashboard_shell.dart';
import 'offering_enrollment_dialog.dart';
import 'offering_enrollment_provider.dart';

class AdminOfferingEnrollmentPage extends ConsumerWidget {
  const AdminOfferingEnrollmentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrollmentsAsync = ref.watch(offeringEnrollmentProvider);

    return DashboardShell(
      title: 'Offering Enrollments',

      child: enrollmentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, stackTrace) {
          debugPrint(error.toString());

          debugPrintStack(stackTrace: stackTrace);

          return Center(child: Text(error.toString()));
        },

        data: (enrollments) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: Card(
              elevation: 0,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),

                side: BorderSide(color: Colors.grey.shade300),
              ),

              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,

                child: DataTable(
                  headingRowHeight: 64,

                  dataRowHeight: 72,

                  columns: const [
                    DataColumn(label: Text('Learner')),

                    DataColumn(label: Text('Offering')),

                    DataColumn(label: Text('Enrollment')),

                    DataColumn(label: Text('Completion')),

                    DataColumn(label: Text('Progress')),

                    DataColumn(label: Text('Attendance')),

                    DataColumn(label: Text('Certificate')),

                    DataColumn(label: Text('Enrolled')),
                  ],

                  rows: enrollments.map((enrollment) {
                    return DataRow(
                      onSelectChanged: (_) {
                        showDialog(
                          context: context,

                          builder: (_) {
                            return OfferingEnrollmentDialog(
                              enrollment: enrollment,
                            );
                          },
                        );
                      },

                      cells: [
                        DataCell(
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,

                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                enrollment.learnerName,

                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                enrollment.learnerEmail,

                                style: TextStyle(
                                  fontSize: 12,

                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        DataCell(
                          SizedBox(
                            width: 240,

                            child: Text(enrollment.offeringTitle),
                          ),
                        ),

                        DataCell(
                          Chip(
                            backgroundColor:
                                enrollment.enrollmentStatus.name == 'cancelled'
                                ? Colors.red.withOpacity(.1)
                                : null,

                            label: Text(
                              enrollment.enrollmentStatus.name.displayLabel,
                            ),
                          ),
                        ),

                        DataCell(
                          Chip(
                            label: Text(
                              enrollment.completionStatus.name.displayLabel,
                            ),
                          ),
                        ),

                        DataCell(
                          SizedBox(
                            width: 120,

                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,

                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),

                                  child: LinearProgressIndicator(
                                    minHeight: 8,

                                    value: enrollment.progressPercentage / 100,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  '${enrollment.progressPercentage.toStringAsFixed(0)}%',
                                ),
                              ],
                            ),
                          ),
                        ),

                        DataCell(
                          Text(
                            '${enrollment.attendedSessions} / '
                            '${enrollment.requiredSessions}',
                          ),
                        ),

                        DataCell(
                          Icon(
                            enrollment.certificateIssued
                                ? Icons.verified
                                : enrollment.certificateEligible
                                ? Icons.workspace_premium
                                : Icons.hourglass_bottom,

                            color: enrollment.certificateIssued
                                ? Colors.green
                                : enrollment.certificateEligible
                                ? Colors.orange
                                : Colors.grey,
                          ),
                        ),

                        DataCell(Text(enrollment.enrolledAt.readableDate)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
