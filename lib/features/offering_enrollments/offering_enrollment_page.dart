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

    final filtersAsync = ref.watch(enrollmentFiltersLookupProvider);

    final filters = ref.watch(enrollmentFiltersProvider);

    return DashboardShell(
      title: 'Offering Enrollments',

      child: Column(
        children: [
          filtersAsync.when(
            loading: () => const LinearProgressIndicator(),

            error: (_, __) => const SizedBox(),

            data: (lookup) {
              final filteredOfferings = lookup.offerings.where((o) {
                if (filters.workshopId == null) {
                  return true;
                }

                return o.workshopId == filters.workshopId;
              }).toList();

              return Padding(
                padding: const EdgeInsets.all(24),

                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,

                  children: [
                    SizedBox(
                      width: 220,

                      child: DropdownButtonFormField<int>(
                        initialValue: filters.workshopId,

                        decoration: const InputDecoration(
                          labelText: 'Workshop',
                        ),

                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All'),
                          ),

                          ...lookup.workshops.map(
                            (workshop) => DropdownMenuItem(
                              value: workshop.id,

                              child: SizedBox(
                                width: 180,
                                child: Text(
                                  workshop.title,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ),
                        ],

                        onChanged: (value) {
                          ref
                              .read(enrollmentFiltersProvider.notifier)
                              .state = filters.copyWith(
                            workshopId: value,
                            clearOffering: true,
                            page: 1,
                          );
                        },
                      ),
                    ),

                    SizedBox(
                      width: 220,

                      child: DropdownButtonFormField<int>(
                        initialValue: filters.offeringId,

                        decoration: const InputDecoration(
                          labelText: 'Offering',
                        ),

                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All'),
                          ),

                          ...filteredOfferings.map(
                            (offering) => DropdownMenuItem(
                              value: offering.id,

                              child: SizedBox(
                                width: 180,
                                child: Text(
                                  offering.title,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ),
                        ],

                        onChanged: (value) {
                          ref.read(enrollmentFiltersProvider.notifier).state =
                              filters.copyWith(offeringId: value, page: 1);
                        },
                      ),
                    ),

                    SizedBox(
                      width: 220,

                      child: DropdownButtonFormField<int>(
                        initialValue: filters.studentId,

                        decoration: const InputDecoration(labelText: 'Student'),

                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All'),
                          ),

                          ...lookup.students.map(
                            (student) => DropdownMenuItem(
                              value: student.id,

                              child: SizedBox(
                                width: 180,
                                child: Text(
                                  student.name,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ),
                        ],

                        onChanged: (value) {
                          ref.read(enrollmentFiltersProvider.notifier).state =
                              filters.copyWith(studentId: value, page: 1);
                        },
                      ),
                    ),

                    SizedBox(
                      width: 220,

                      child: DropdownButtonFormField<String>(
                        initialValue: filters.completionStatus,

                        decoration: const InputDecoration(
                          labelText: 'Completion',
                        ),

                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All'),
                          ),

                          ...lookup.completionStatuses.map(
                            (status) => DropdownMenuItem(
                              value: status,

                              child: Text(status.displayLabel),
                            ),
                          ),
                        ],

                        onChanged: (value) {
                          ref
                              .read(enrollmentFiltersProvider.notifier)
                              .state = filters.copyWith(
                            completionStatus: value,
                            page: 1,
                          );
                        },
                      ),
                    ),

                    SizedBox(
                      width: 260,

                      child: TextFormField(
                        initialValue: filters.search,

                        decoration: InputDecoration(
                          labelText: 'Search',

                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {},
                          ),
                        ),

                        onChanged: (value) {
                          ref.read(enrollmentFiltersProvider.notifier).state =
                              filters.copyWith(search: value, page: 1);
                        },
                      ),
                    ),

                    OutlinedButton.icon(
                      onPressed: () {
                        ref.read(enrollmentFiltersProvider.notifier).state =
                            const EnrollmentFilters();
                      },

                      icon: const Icon(Icons.clear),

                      label: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),

          Expanded(
            child: enrollmentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),

              error: (error, stackTrace) {
                debugPrint(error.toString());

                return Center(child: Text(error.toString()));
              },

              data: (pageData) {
                final enrollments = pageData.data;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),

                  child: Card(
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,

                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Workshop')),

                                DataColumn(label: Text('Offering')),

                                DataColumn(label: Text('Student')),

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
                                      builder: (_) => OfferingEnrollmentDialog(
                                        enrollment: enrollment,
                                      ),
                                    );
                                  },

                                  cells: [
                                    DataCell(Text(enrollment.workshopTitle)),

                                    DataCell(
                                      SizedBox(
                                        width: 220,
                                        child: Text(enrollment.offeringTitle),
                                      ),
                                    ),

                                    DataCell(
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,

                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          Text(enrollment.learnerName),

                                          Text(enrollment.learnerEmail),
                                        ],
                                      ),
                                    ),

                                    DataCell(
                                      Chip(
                                        label: Text(
                                          enrollment
                                              .completionStatus
                                              .name
                                              .displayLabel,
                                        ),
                                      ),
                                    ),

                                    DataCell(
                                      Text(
                                        '${enrollment.progressPercentage.toStringAsFixed(0)}%',
                                      ),
                                    ),

                                    DataCell(
                                      Text(
                                        '${enrollment.attendedSessions}/${enrollment.totalSessions}',
                                      ),
                                    ),

                                    DataCell(
                                      Icon(
                                        enrollment.certificateIssued
                                            ? Icons.verified
                                            : Icons.hourglass_bottom,
                                      ),
                                    ),

                                    DataCell(
                                      Text(enrollment.enrolledAt.readableDate),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.all(16),

                          child: Row(
                            children: [
                              Text(
                                'Showing ${enrollments.length} of ${pageData.total}',
                              ),

                              const Spacer(),

                              IconButton(
                                onPressed: pageData.currentPage > 1
                                    ? () {
                                        ref
                                            .read(
                                              enrollmentFiltersProvider
                                                  .notifier,
                                            )
                                            .state = filters.copyWith(
                                          page: pageData.currentPage - 1,
                                        );
                                      }
                                    : null,

                                icon: const Icon(Icons.chevron_left),
                              ),

                              Text(
                                'Page ${pageData.currentPage} of ${pageData.lastPage}',
                              ),

                              IconButton(
                                onPressed:
                                    pageData.currentPage < pageData.lastPage
                                    ? () {
                                        ref
                                            .read(
                                              enrollmentFiltersProvider
                                                  .notifier,
                                            )
                                            .state = filters.copyWith(
                                          page: pageData.currentPage + 1,
                                        );
                                      }
                                    : null,

                                icon: const Icon(Icons.chevron_right),
                              ),
                            ],
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
      ),
    );
  }
}
