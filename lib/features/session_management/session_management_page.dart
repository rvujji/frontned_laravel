import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dashboard/widgets/dashboard_shell.dart';
import '../offering_management/offering_management_models.dart';
import 'session_form_dialog.dart';
import 'session_management_models.dart';
import 'session_management_provider.dart';
import 'session_management_service.dart';

class SessionManagementPage extends ConsumerStatefulWidget {
  const SessionManagementPage({super.key});

  @override
  ConsumerState<SessionManagementPage> createState() =>
      _SessionManagementPageState();
}

class _SessionManagementPageState extends ConsumerState<SessionManagementPage> {
  int? _selectedWorkshopId;
  int? _selectedOfferingId;

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(sessionsProvider);

    final workshopsAsync = ref.watch(workshopsProvider);

    final offeringsAsync = ref.watch(offeringsProvider);

    return DashboardShell(
      title: 'Session Management',
      child: Column(
        children: [
          _buildHeader(context, workshopsAsync, offeringsAsync),

          const SizedBox(height: 24),

          Expanded(
            child: sessionsAsync.when(
              data: (sessions) {
                final filteredSessions = _filterSessions(sessions);

                if (filteredSessions.isEmpty) {
                  return const Center(child: Text('No sessions found'));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(sessionsProvider);

                    await ref.read(sessionsProvider.future);
                  },
                  child: ListView(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 24,
                          columns: const [
                            DataColumn(label: Text('Workshop')),
                            DataColumn(label: Text('Offering')),
                            DataColumn(label: Text('#')),
                            DataColumn(label: Text('Title')),
                            DataColumn(label: Text('Kind')),
                            DataColumn(label: Text('Delivery')),
                            DataColumn(label: Text('Start')),
                            DataColumn(label: Text('End')),
                            DataColumn(label: Text('Capacity')),
                            DataColumn(label: Text('Reservations')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: filteredSessions
                              .map((session) => _buildRow(context, session))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text(error.toString())),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AsyncValue<List<OfferingWorkshop>> workshopsAsync,
    AsyncValue<List<AdminOffering>> offeringsAsync,
  ) {
    final offerings = offeringsAsync.value ?? [];

    final filteredOfferings = _selectedWorkshopId == null
        ? offerings
        : offerings.where((o) {
            return o.workshopId == _selectedWorkshopId;
          }).toList();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search sessions...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  final current = ref.read(sessionFiltersProvider);

                  ref.read(sessionFiltersProvider.notifier).state = current
                      .copyWith(search: value);
                },
              ),
            ),

            const SizedBox(width: 16),

            FilledButton.icon(
              onPressed: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (_) => const SessionFormDialog(),
                );

                if (result == true) {
                  ref.invalidate(sessionsProvider);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Session'),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: workshopsAsync.when(
                data: (workshops) {
                  return DropdownButtonFormField<int?>(
                    value: _selectedWorkshopId,
                    decoration: const InputDecoration(labelText: 'Workshop'),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('All Workshops'),
                      ),

                      ...workshops.map(
                        (workshop) => DropdownMenuItem<int?>(
                          value: workshop.id,
                          child: Text(workshop.title),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedWorkshopId = value;

                        _selectedOfferingId = null;
                      });
                    },
                  );
                },
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: DropdownButtonFormField<int?>(
                value: _selectedOfferingId,
                decoration: const InputDecoration(labelText: 'Offering'),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('All Offerings'),
                  ),

                  ...filteredOfferings.map(
                    (offering) => DropdownMenuItem<int?>(
                      value: offering.id,
                      child: Text(offering.title),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedOfferingId = value;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<SessionManagementModel> _filterSessions(
    List<SessionManagementModel> sessions,
  ) {
    return sessions.where((session) {
      if (_selectedWorkshopId != null &&
          session.workshopId != _selectedWorkshopId) {
        return false;
      }

      if (_selectedOfferingId != null &&
          session.offeringId != _selectedOfferingId) {
        return false;
      }

      return true;
    }).toList();
  }

  DataRow _buildRow(BuildContext context, SessionManagementModel session) {
    return DataRow(
      cells: [
        DataCell(
          SizedBox(width: 220, child: Text(session.workshopTitle ?? '-')),
        ),

        DataCell(
          SizedBox(width: 220, child: Text(session.offeringTitle ?? '-')),
        ),

        DataCell(
          Text(
            (session.sessionNumber ?? 0) > 0 ? '${session.sessionNumber}' : '-',
          ),
        ),

        DataCell(
          SizedBox(
            width: 220,
            child: Text(session.title, overflow: TextOverflow.ellipsis),
          ),
        ),

        DataCell(Text(session.sessionKind.name)),

        DataCell(Text(session.deliveryMode.name)),

        DataCell(Text(_formatDate(session.startAt))),

        DataCell(Text(_formatDate(session.endAt))),

        DataCell(Text('${session.capacity}')),

        DataCell(Text('${session.reservationCount}')),

        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey.shade200,
            ),
            child: Text(session.status.name),
          ),
        ),

        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (_) => SessionFormDialog(session: session),
                  );

                  if (result == true) {
                    ref.invalidate(sessionsProvider);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  await SessionManagementService().deleteSession(session.id);

                  ref.invalidate(sessionsProvider);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '-';
    }

    return '${value.day}/${value.month}/${value.year}';
  }
}
