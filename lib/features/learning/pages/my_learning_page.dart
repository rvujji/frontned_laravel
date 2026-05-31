import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums.dart';
import '../../../shared/navigation/app_shell.dart';
import '../../attendance/attendance_provider.dart';
import '../../certificates/certificate_provider.dart';
import '../../progress/progress_provider.dart';
import '../learning_provider.dart';
import '../widgets/enrolled_offering_card.dart';
import '../widgets/learning_stats_section.dart';
import '../widgets/upcoming_session_card.dart';

class MyLearningPage extends ConsumerWidget {
  const MyLearningPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(learnerDashboardProvider);

    final progressAsync = ref.watch(progressProvider);

    final attendanceAsync = ref.watch(learnerAttendanceProvider);

    final certificatesAsync = ref.watch(certificateProvider);

    return AppShell(
      child: dashboardAsync.when(
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },

        error: (error, stackTrace) {
          return Center(child: Text(error.toString()));
        },

        data: (dashboard) {
          return progressAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),

            error: (error, _) => Center(child: Text(error.toString())),

            data: (progressItems) {
              return attendanceAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),

                error: (error, _) => Center(child: Text(error.toString())),

                data: (attendances) {
                  return certificatesAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),

                    error: (error, _) => Center(child: Text(error.toString())),

                    data: (certificates) {
                      final totalProgress = progressItems.isEmpty
                          ? 0.0
                          : progressItems
                                    .map((e) => e.progressPercentage)
                                    .reduce((a, b) => a + b) /
                                progressItems.length;

                      final attended = attendances
                          .where(
                            (e) =>
                                e.attendanceStatus == AttendanceStatus.present,
                          )
                          .length;

                      final attendancePercentage = attendances.isEmpty
                          ? 0
                          : ((attended / attendances.length) * 100).toInt();

                      final eligibleCertificates = progressItems
                          .where((e) => e.certificateEligible)
                          .length;

                      final completedOfferings = progressItems
                          .where(
                            (e) =>
                                e.completionStatus ==
                                CompletionStatus.completed,
                          )
                          .length;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(32),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            const Text(
                              'My Learning',

                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 32),

                            LearningStatsSection(
                              enrollmentsCount: dashboard.enrollments.length,

                              sessionsCount:
                                  dashboard.upcomingReservations.length,
                            ),

                            const SizedBox(height: 32),

                            GridView.count(
                              shrinkWrap: true,

                              physics: const NeverScrollableScrollPhysics(),

                              crossAxisCount: 4,

                              crossAxisSpacing: 20,

                              mainAxisSpacing: 20,

                              childAspectRatio: 1.6,

                              children: [
                                _StatCard(
                                  title: 'Progress',

                                  value: '${totalProgress.toStringAsFixed(0)}%',

                                  icon: Icons.trending_up,
                                ),

                                _StatCard(
                                  title: 'Attendance',

                                  value: '$attendancePercentage%',

                                  icon: Icons.fact_check,
                                ),

                                _StatCard(
                                  title: 'Completed',

                                  value: '$completedOfferings',

                                  icon: Icons.school,
                                ),

                                _StatCard(
                                  title: 'Certificates',

                                  value: '${certificates.length}',

                                  subtitle: '$eligibleCertificates eligible',

                                  icon: Icons.workspace_premium,
                                ),
                              ],
                            ),

                            const SizedBox(height: 56),

                            if (attendancePercentage < 75)
                              Container(
                                width: double.infinity,

                                padding: const EdgeInsets.all(20),

                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(.1),

                                  borderRadius: BorderRadius.circular(20),
                                ),

                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.warning_amber_rounded,

                                      color: Colors.orange,
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Text(
                                        'Your attendance is below the recommended threshold. '
                                        'Attend upcoming sessions to maintain certificate eligibility.',
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            if (attendancePercentage < 75)
                              const SizedBox(height: 40),

                            const Text(
                              'Enrolled Offerings',

                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 24),

                            GridView.builder(
                              shrinkWrap: true,

                              physics: const NeverScrollableScrollPhysics(),

                              itemCount: dashboard.enrollments.length,

                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,

                                    crossAxisSpacing: 20,

                                    mainAxisSpacing: 20,

                                    mainAxisExtent: 320,
                                  ),

                              itemBuilder: (context, index) {
                                return EnrolledOfferingCard(
                                  enrollment: dashboard.enrollments[index],
                                );
                              },
                            ),

                            const SizedBox(height: 56),

                            const Text(
                              'Upcoming Sessions',

                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 24),

                            GridView.builder(
                              shrinkWrap: true,

                              physics: const NeverScrollableScrollPhysics(),

                              itemCount: dashboard.upcomingReservations.length,

                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,

                                    crossAxisSpacing: 20,

                                    mainAxisSpacing: 20,

                                    mainAxisExtent: 260,
                                  ),

                              itemBuilder: (context, index) {
                                return UpcomingSessionCard(
                                  reservation:
                                      dashboard.upcomingReservations[index],
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;

  final String value;

  final String? subtitle;

  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
  });

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
            Icon(icon, size: 30),

            const Spacer(),

            Text(
              value,

              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(title, style: TextStyle(color: Colors.grey.shade700)),

            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),

                child: Text(
                  subtitle!,

                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
