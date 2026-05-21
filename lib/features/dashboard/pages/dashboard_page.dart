import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dashboard_models.dart';
import '../dashboard_provider.dart';
import '../widgets/dashboard_shell.dart';
import '../widgets/stats_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    final enrollmentsAsync = ref.watch(recentEnrollmentsProvider);

    final recentWorkshopsAsync = ref.watch(recentWorkshopsProvider);

    return DashboardShell(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                int crossAxisCount = 4;

                if (width < 1200) {
                  crossAxisCount = 2;
                }

                if (width < 700) {
                  crossAxisCount = 1;
                }

                return GridView.count(
                  crossAxisCount: crossAxisCount,

                  shrinkWrap: true,

                  physics: const NeverScrollableScrollPhysics(),

                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,

                  childAspectRatio: 2.2,

                  children: [
                    ...statsAsync.when(
                      loading: () {
                        return List.generate(4, (index) {
                          return const StatsCard(
                            title: 'Loading...',

                            value: '--',

                            icon: Icons.hourglass_top,
                          );
                        });
                      },

                      error: (error, stackTrace) {
                        return [
                          const StatsCard(
                            title: 'Error',

                            value: '0',

                            icon: Icons.error,
                          ),
                        ];
                      },

                      data: (stats) {
                        return [
                          StatsCard(
                            title: 'Students',

                            value: stats.totalStudents.toString(),

                            icon: Icons.people,
                          ),

                          StatsCard(
                            title: 'Workshops',

                            value: stats.totalWorkshops.toString(),

                            icon: Icons.school,
                          ),

                          StatsCard(
                            title: 'Published',

                            value: stats.publishedWorkshops.toString(),

                            icon: Icons.public,
                          ),

                          StatsCard(
                            title: 'Enrollments',

                            value: stats.totalEnrollments.toString(),

                            icon: Icons.trending_up,
                          ),
                        ];
                      },
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 900;

                if (isMobile) {
                  return Column(
                    children: [
                      _RecentEnrollmentsCard(
                        enrollmentsAsync: enrollmentsAsync,
                      ),

                      const SizedBox(height: 24),

                      _RecentWorkshopsCard(
                        recentWorkshopsAsync: recentWorkshopsAsync,
                      ),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Expanded(
                      child: _RecentEnrollmentsCard(
                        enrollmentsAsync: enrollmentsAsync,
                      ),
                    ),

                    const SizedBox(width: 24),

                    Expanded(
                      child: _RecentWorkshopsCard(
                        recentWorkshopsAsync: recentWorkshopsAsync,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentEnrollmentsCard extends StatelessWidget {
  final AsyncValue<List<RecentEnrollment>> enrollmentsAsync;

  const _RecentEnrollmentsCard({required this.enrollmentsAsync});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Recent Enrollments',

              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            ...enrollmentsAsync.when(
              loading: () {
                return List.generate(5, (index) {
                  return const ListTile(
                    contentPadding: EdgeInsets.zero,

                    title: Text('Loading...'),
                  );
                });
              },

              error: (error, stackTrace) {
                return [ListTile(title: Text(error.toString()))];
              },

              data: (enrollments) {
                return enrollments.map((enrollment) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,

                    leading: const CircleAvatar(child: Icon(Icons.person)),

                    title: Text(enrollment.studentName),

                    subtitle: Text(enrollment.workshopTitle),

                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      crossAxisAlignment: CrossAxisAlignment.end,

                      children: [
                        Text(enrollment.status),

                        const SizedBox(height: 4),

                        Text(
                          enrollment.createdAt ?? '',

                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }).toList();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentWorkshopsCard extends StatelessWidget {
  final AsyncValue<List<RecentWorkshop>> recentWorkshopsAsync;

  const _RecentWorkshopsCard({required this.recentWorkshopsAsync});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Recent Workshops',

              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            ...recentWorkshopsAsync.when(
              loading: () {
                return List.generate(5, (index) {
                  return const ListTile(
                    contentPadding: EdgeInsets.zero,

                    title: Text('Loading...'),
                  );
                });
              },

              error: (error, stackTrace) {
                return [ListTile(title: Text(error.toString()))];
              },

              data: (workshops) {
                return workshops.map((workshop) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,

                    leading: const CircleAvatar(child: Icon(Icons.school)),

                    title: Text(workshop.title),

                    subtitle: Text(workshop.ownerName),

                    trailing: Text(workshop.status),
                  );
                }).toList();
              },
            ),
          ],
        ),
      ),
    );
  }
}
