import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontned_laravel/features/workshop_management/workshop_form_dialog.dart';

import '../dashboard/widgets/dashboard_shell.dart';
import 'workshop_management_models.dart';
import 'workshop_management_service.dart';

final managedWorkshopsProvider = FutureProvider<List<ManagedWorkshop>>((
  ref,
) async {
  final service = ref.read(workshopManagementServiceProvider);

  return service.fetchWorkshops();
});

final workshopCategoriesProvider = FutureProvider<List<WorkshopCategory>>((
  ref,
) async {
  final service = ref.read(workshopManagementServiceProvider);

  return service.fetchCategories();
});

class WorkshopManagementPage extends ConsumerWidget {
  const WorkshopManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workshopsAsync = ref.watch(managedWorkshopsProvider);

    return DashboardShell(
      title: "Workshops",
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                const Text(
                  'Workshop Management',

                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),

                const Spacer(),

                ElevatedButton.icon(
                  onPressed: () async {
                    final created = await showDialog<bool>(
                      context: context,

                      builder: (context) {
                        return const WorkshopFormDialog();
                      },
                    );

                    if (created == true) {
                      ref.invalidate(managedWorkshopsProvider);
                    }
                  },

                  icon: const Icon(Icons.add),

                  label: const Text('Create Workshop'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Expanded(
              child: Card(
                child: workshopsAsync.when(
                  loading: () {
                    return const Center(child: CircularProgressIndicator());
                  },

                  error: (error, stackTrace) {
                    return Center(child: Text(error.toString()));
                  },

                  data: (workshops) {
                    if (workshops.isEmpty) {
                      return const Center(child: Text('No workshops found'));
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,

                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Title')),

                          DataColumn(label: Text('Status')),

                          DataColumn(label: Text('Price')),

                          DataColumn(label: Text('Created')),

                          DataColumn(label: Text('Actions')),
                        ],

                        rows: workshops.map((workshop) {
                          return DataRow(
                            cells: [
                              DataCell(Text(workshop.title)),

                              DataCell(_StatusChip(status: workshop.status)),

                              DataCell(Text('₹ ${workshop.price}')),

                              DataCell(Text(workshop.createdAt ?? '')),

                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        final updated = await showDialog<bool>(
                                          context: context,

                                          builder: (context) {
                                            return WorkshopFormDialog(
                                              workshop: workshop,
                                            );
                                          },
                                        );

                                        if (updated == true) {
                                          ref.invalidate(
                                            managedWorkshopsProvider,
                                          );
                                        }
                                      },

                                      icon: const Icon(Icons.edit),
                                    ),

                                    IconButton(
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,

                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text(
                                                'Delete Workshop?',
                                              ),

                                              content: const Text(
                                                'This action cannot be undone.',
                                              ),

                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                      context,
                                                      false,
                                                    );
                                                  },

                                                  child: const Text('Cancel'),
                                                ),

                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                      context,
                                                      true,
                                                    );
                                                  },

                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (confirm != true) {
                                          return;
                                        }

                                        await ref
                                            .read(
                                              workshopManagementServiceProvider,
                                            )
                                            .deleteWorkshop(workshop.id);

                                        ref.invalidate(
                                          managedWorkshopsProvider,
                                        );
                                      },

                                      icon: const Icon(Icons.delete),
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

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;

    if (status == 'published') {
      color = Colors.green;
    }

    if (status == 'draft') {
      color = Colors.orange;
    }

    return Chip(
      label: Text(status),

      backgroundColor: color.withOpacity(0.15),

      side: BorderSide.none,

      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }
}
