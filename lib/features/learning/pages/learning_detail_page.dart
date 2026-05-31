import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/navigation/app_shell.dart';
import '../../../shared/utility/string_extension.dart';
import '../learning_provider.dart';
import '../widgets/learner_session_card.dart';

class LearningDetailPage extends ConsumerWidget {
  final int enrollmentId;

  const LearningDetailPage({super.key, required this.enrollmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrollmentsAsync = ref.watch(myEnrollmentsProvider);
    final dashboardAsync = ref.watch(learnerDashboardProvider);

    return AppShell(
      child: enrollmentsAsync.when(
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stackTrace) {
          return Center(child: Text(error.toString()));
        },
        data: (enrollments) {
          final enrollment = enrollments.firstWhere(
            (e) => e.id == enrollmentId,
          );

          final offering = enrollment.offering;

          return dashboardAsync.when(
            loading: () {
              return const Center(child: CircularProgressIndicator());
            },
            error: (error, stackTrace) {
              return Center(child: Text(error.toString()));
            },
            data: (dashboard) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.indigo.shade400,
                            Colors.indigo.shade700,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offering.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            offering.workshop?.title ?? '',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 28),
                          LinearProgressIndicator(
                            value: enrollment.progressPercentage / 100,
                            minHeight: 10,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            '${enrollment.progressPercentage.toStringAsFixed(0)}% Complete',
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              Chip(
                                label: Text(
                                  enrollment.enrollmentStatus.displayLabel,
                                ),
                              ),
                              Chip(
                                label: Text(
                                  enrollment.completionStatus.displayLabel,
                                ),
                              ),
                              if (enrollment.certificateEligible)
                                const Chip(label: Text('Certificate Eligible')),
                              if (enrollment.certificateIssued)
                                const Chip(label: Text('Certificate Issued')),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    const Text(
                      'Learning Sessions',
                      style: TextStyle(
                        fontSize: 30,
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
                            mainAxisExtent: 280,
                          ),
                      itemBuilder: (context, index) {
                        return LearnerSessionCard(
                          reservation: dashboard.upcomingReservations[index],
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
