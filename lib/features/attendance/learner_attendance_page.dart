import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums.dart';
import '../../shared/utility/datetime_extension.dart';
import '../dashboard/widgets/dashboard_shell.dart';
import 'attendance_provider.dart';
import 'attendance_status_badge.dart';
import 'attendance_summary_card.dart';

class LearnerAttendancePage extends ConsumerWidget {
  const LearnerAttendancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(learnerAttendanceProvider);

    return DashboardShell(
      title: 'My Attendance',

      child: attendanceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, _) => Center(child: Text(error.toString())),

        data: (attendances) {
          final total = attendances.length;

          final present = attendances
              .where((e) => e.attendanceStatus == AttendanceStatus.present)
              .length;

          final absent = attendances
              .where((e) => e.attendanceStatus == AttendanceStatus.absent)
              .length;

          final late = attendances
              .where((e) => e.attendanceStatus == AttendanceStatus.late)
              .length;

          return ListView(
            padding: const EdgeInsets.all(24),

            children: [
              AttendanceSummaryCard(
                total: total,

                present: present,

                absent: absent,
              ),

              const SizedBox(height: 24),

              Text(
                'Attendance History',

                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 20),

              ...attendances.map((attendance) {
                return Card(
                  elevation: 0,

                  margin: const EdgeInsets.only(bottom: 16),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),

                    side: BorderSide(color: Colors.grey.shade300),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(20),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                attendance.session.title,

                                style: const TextStyle(
                                  fontSize: 18,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            AttendanceStatusBadge(
                              status: attendance.attendanceStatus,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Text(
                          attendance.workshop.title,

                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),

                        const SizedBox(height: 6),

                        Text(attendance.offering.title),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Icon(
                              Icons.schedule,

                              size: 18,

                              color: Colors.grey.shade600,
                            ),

                            const SizedBox(width: 8),

                            Text(
                              attendance.session.startAt?.readableDateTime ??
                                  '',
                            ),
                          ],
                        ),

                        if (attendance.attendanceStatus ==
                            AttendanceStatus.late)
                          Padding(
                            padding: const EdgeInsets.only(top: 14),

                            child: Text(
                              'Marked Late',

                              style: TextStyle(
                                color: Colors.orange.shade700,

                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
