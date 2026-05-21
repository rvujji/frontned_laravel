import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/widgets/dashboard_shell.dart';
import '../enrollment_models.dart';
import '../enrollment_service.dart';

final enrollmentsProvider = FutureProvider<List<Enrollment>>((ref) async {
  final service = ref.read(enrollmentServiceProvider);
  return service.fetchEnrollments();
});

final enrollmentSearchProvider = StateProvider<String>((ref) => '');
final enrollmentStatusProvider = StateProvider<String?>((ref) => null);

class EnrollmentsPage extends ConsumerStatefulWidget {
  const EnrollmentsPage({super.key});

  @override
  ConsumerState<EnrollmentsPage> createState() => _EnrollmentsPageState();
}

class _EnrollmentsPageState extends ConsumerState<EnrollmentsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enrollmentsAsync = ref.watch(enrollmentsProvider);
    final search = ref.watch(enrollmentSearchProvider);
    final selectedStatus = ref.watch(enrollmentStatusProvider);

    return DashboardShell(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enrollments',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search student',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      ref.read(enrollmentSearchProvider.notifier).state = value;
                    },
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem<String>(value: '', child: Text('All')),
                      DropdownMenuItem<String>(
                        value: 'active',
                        child: Text('Active'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'completed',
                        child: Text('Completed'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'cancelled',
                        child: Text('Cancelled'),
                      ),
                    ],
                    onChanged: (value) {
                      ref.read(enrollmentStatusProvider.notifier).state =
                          (value == null || value.isEmpty) ? null : value;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                child: enrollmentsAsync.when(
                  loading: () {
                    return const Center(child: CircularProgressIndicator());
                  },
                  error: (error, stackTrace) {
                    return Center(child: Text(error.toString()));
                  },
                  data: (enrollments) {
                    final filteredEnrollments = enrollments.where((enrollment) {
                      final matchesSearch = enrollment.studentName
                          .toLowerCase()
                          .contains(search.toLowerCase());

                      final matchesStatus =
                          selectedStatus == null ||
                          enrollment.status == selectedStatus;

                      return matchesSearch && matchesStatus;
                    }).toList();

                    if (filteredEnrollments.isEmpty) {
                      return const Center(child: Text('No enrollments found'));
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Student')),
                          DataColumn(label: Text('Workshop')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Enrolled')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: filteredEnrollments.map((enrollment) {
                          return DataRow(
                            cells: [
                              DataCell(Text(enrollment.studentName)),
                              DataCell(Text(enrollment.workshopTitle)),
                              DataCell(
                                _EnrollmentStatusChip(
                                  status: enrollment.status,
                                ),
                              ),
                              DataCell(Text(enrollment.enrolledAt ?? '')),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed:
                                          enrollment.status == 'cancelled'
                                          ? null
                                          : () async {
                                              final confirm =
                                                  await showDialog<bool>(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                          'Cancel Enrollment?',
                                                        ),
                                                        content: const Text(
                                                          'Student enrollment will be cancelled.',
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                context,
                                                                false,
                                                              );
                                                            },
                                                            child: const Text(
                                                              'No',
                                                            ),
                                                          ),
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                context,
                                                                true,
                                                              );
                                                            },
                                                            child: const Text(
                                                              'Yes',
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );

                                              if (confirm != true) return;

                                              await ref
                                                  .read(
                                                    enrollmentServiceProvider,
                                                  )
                                                  .cancelEnrollment(
                                                    enrollment.id,
                                                  );

                                              ref.invalidate(
                                                enrollmentsProvider,
                                              );
                                            },
                                      icon: const Icon(Icons.cancel),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnrollmentStatusChip extends StatelessWidget {
  final String status;

  const _EnrollmentStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;

    if (status == 'active') {
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
