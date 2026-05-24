import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/navigation/app_shell.dart';
import '../enrollment_models.dart';
import '../enrollment_service.dart';

final myEnrollmentsProvider = FutureProvider<List<Enrollment>>((ref) async {
  final service = ref.read(enrollmentServiceProvider);

  return service.fetchMyEnrollments();
});

class MyEnrollmentsPage extends ConsumerWidget {
  const MyEnrollmentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrollmentsAsync = ref.watch(myEnrollmentsProvider);

    return AppShell(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: enrollmentsAsync.when(
          loading: () {
            return const Center(child: CircularProgressIndicator());
          },

          error: (error, stackTrace) {
            return Center(child: Text(error.toString()));
          },

          data: (enrollments) {
            if (enrollments.isEmpty) {
              return const Center(child: Text('No enrollments yet'));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'My Enrollments',

                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 24),

                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width < 900
                          ? 1
                          : 2,

                      crossAxisSpacing: 24,

                      mainAxisSpacing: 24,

                      childAspectRatio: 1.6,
                    ),

                    itemCount: enrollments.length,

                    itemBuilder: (context, index) {
                      final enrollment = enrollments[index];

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      enrollment.workshopTitle,

                                      style: const TextStyle(
                                        fontSize: 24,

                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  _StatusChip(status: enrollment.status),
                                ],
                              ),

                              const SizedBox(height: 16),

                              Text('Enrolled: ${enrollment.enrolledAt ?? ''}'),

                              const Spacer(),

                              SizedBox(
                                width: double.infinity,

                                child: ElevatedButton(
                                  onPressed: () {},

                                  child: const Text('Continue Learning'),
                                ),
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
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;

    if (status == 'confirmed') {
      color = Colors.green;
    }

    if (status == 'completed') {
      color = Colors.blue;
    }

    if (status == 'cancelled') {
      color = Colors.red;
    }

    return Chip(
      label: Text(status),

      backgroundColor: color.withOpacity(0.15),

      side: BorderSide.none,

      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }
}
