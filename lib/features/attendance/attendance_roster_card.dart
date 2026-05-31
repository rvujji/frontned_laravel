import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums.dart';
import '../../shared/utility/datetime_extension.dart';
import '../../shared/utility/string_extension.dart';
import 'attendance_models.dart';
import 'attendance_provider.dart';
import 'attendance_status_badge.dart';

class AttendanceRosterCard extends ConsumerWidget {
  final AttendanceModel attendance;

  const AttendanceRosterCard({super.key, required this.attendance});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(attendanceManagementProvider.notifier);

    return Card(
      elevation: 0,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),

        side: BorderSide(color: Colors.grey.shade300),
      ),

      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              attendance.student.name,

              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(
              attendance.student.email,

              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 16),

            Text(
              attendance.workshop.title,

              style: const TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 6),

            Text(attendance.offering.title),

            const SizedBox(height: 6),

            Text(attendance.session.title),

            const SizedBox(height: 6),

            Text(attendance.session.startAt?.readableDateTime ?? ''),

            const SizedBox(height: 18),

            AttendanceStatusBadge(status: attendance.attendanceStatus),

            const Spacer(),

            DropdownButtonFormField<AttendanceStatus>(
              value: attendance.attendanceStatus,

              isExpanded: true,

              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),

              items: AttendanceStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,

                  child: Text(status.name.displayLabel),
                );
              }).toList(),

              onChanged: (value) async {
                if (value == null) {
                  return;
                }

                try {
                  await notifier.updateAttendance(
                    attendanceId: attendance.id,

                    status: value,
                  );
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
