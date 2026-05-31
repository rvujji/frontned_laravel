import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums.dart';
import '../../shared/utility/datetime_extension.dart';
import '../dashboard/widgets/dashboard_shell.dart';
import 'attendance_provider.dart';
import 'attendance_status_badge.dart';

class AttendanceManagementPage extends ConsumerWidget {
  const AttendanceManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(attendanceManagementProvider);

    final notifier = ref.read(attendanceManagementProvider.notifier);

    final filters = notifier.filters;

    return DashboardShell(
      title: 'Attendance',

      child: attendanceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, _) => Center(child: Text(error.toString())),

        data: (attendances) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),

                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: notifier.selectedWorkshopId,

                        decoration: const InputDecoration(
                          labelText: 'Workshop',
                        ),

                        items:
                            filters?.workshops.map((e) {
                              return DropdownMenuItem<int>(
                                value: e['id'],

                                child: Text(e['title']),
                              );
                            }).toList() ??
                            [],

                        onChanged: notifier.selectWorkshop,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: notifier.selectedOfferingId,

                        decoration: const InputDecoration(
                          labelText: 'Offering',
                        ),

                        items:
                            filters?.offerings.map((e) {
                              return DropdownMenuItem<int>(
                                value: e['id'],

                                child: Text(e['title']),
                              );
                            }).toList() ??
                            [],

                        onChanged: notifier.selectOffering,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: notifier.selectedSessionId,

                        decoration: const InputDecoration(labelText: 'Session'),

                        items:
                            filters?.sessions.map((e) {
                              return DropdownMenuItem<int>(
                                value: e['id'],

                                child: Text(e['title']),
                              );
                            }).toList() ??
                            [],

                        onChanged: notifier.selectSession,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),

                  itemCount: attendances.length,

                  itemBuilder: (context, index) {
                    final attendance = attendances[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),

                      child: Padding(
                        padding: const EdgeInsets.all(20),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              attendance.student.name,

                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(attendance.student.email),

                            const SizedBox(height: 16),

                            Text(attendance.workshop.title),

                            Text(attendance.offering.title),

                            Text(attendance.session.title),

                            const SizedBox(height: 8),

                            Text(
                              attendance.session.startAt?.readableDateTime ??
                                  '',
                            ),

                            const SizedBox(height: 16),

                            Row(
                              children: [
                                AttendanceStatusBadge(
                                  status: attendance.attendanceStatus,
                                ),

                                const SizedBox(width: 16),

                                Expanded(
                                  child:
                                      DropdownButtonFormField<AttendanceStatus>(
                                        value: attendance.attendanceStatus,

                                        items: AttendanceStatus.values.map((
                                          status,
                                        ) {
                                          return DropdownMenuItem(
                                            value: status,

                                            child: Text(status.name),
                                          );
                                        }).toList(),

                                        onChanged: (value) async {
                                          if (value == null) {
                                            return;
                                          }

                                          await notifier.updateAttendance(
                                            attendanceId: attendance.id,

                                            status: value,
                                          );
                                        },
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
