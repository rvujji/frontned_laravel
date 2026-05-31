import 'package:flutter/material.dart';

import '../../../shared/utility/string_extension.dart';
import '../dashboard/widgets/dashboard_shell.dart';
import 'offering_form_dialog.dart';
import 'offering_management_models.dart';
import 'offering_management_service.dart';
import 'session_management_page.dart';

class OfferingManagementPage extends StatefulWidget {
  const OfferingManagementPage({super.key});

  @override
  State<OfferingManagementPage> createState() => _OfferingManagementPageState();
}

class _OfferingManagementPageState extends State<OfferingManagementPage> {
  final _service = OfferingManagementService();

  bool _loading = true;

  List<OfferingWorkshop> workshops = [];

  int? _selectedWorkshopId;
  List<AdminOffering> offerings = [];

  String? _selectedWorkshop;

  @override
  void initState() {
    super.initState();

    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });

    try {
      final results = await Future.wait([
        _service.fetchOfferings(),
        _service.fetchWorkshops(),
      ]);

      offerings = results[0] as List<AdminOffering>;

      workshops = results[1] as List<OfferingWorkshop>;
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  List<AdminOffering> get _filteredOfferings {
    if (_selectedWorkshopId == null) {
      return offerings;
    }

    return offerings.where((offering) {
      return offering.workshopId == _selectedWorkshopId;
    }).toList();
  }

  Future<void> _createOffering() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => const OfferingFormDialog(),
    );

    if (created == true) {
      _load();
    }
  }

  Future<void> _editOffering(AdminOffering offering) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => OfferingFormDialog(offering: offering),
    );

    if (updated == true) {
      _load();
    }
  }

  Future<void> _deleteOffering(AdminOffering offering) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete Offering'),
            content: Text('Delete "${offering.title}"?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    await _service.deleteOffering(offering.id);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Offering deleted')));
    }

    _load();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: 'Offerings',
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 300,
                child: DropdownButtonFormField<int?>(
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
                    });
                  },
                ),
              ),

              const Spacer(),

              FilledButton.icon(
                onPressed: _createOffering,
                icon: const Icon(Icons.add),
                label: const Text('Create Offering'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 24,
                            columns: const [
                              DataColumn(label: Text('Workshop')),
                              DataColumn(label: Text('Offering')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Delivery')),
                              DataColumn(label: Text('Sessions')),
                              DataColumn(label: Text('Enrollments')),
                              DataColumn(label: Text('Certificate')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: _filteredOfferings
                                .map(
                                  (offering) => DataRow(
                                    cells: [
                                      DataCell(
                                        SizedBox(
                                          width: 220,
                                          child: Text(
                                            offering.workshopTitle ?? '-',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),

                                      DataCell(
                                        SizedBox(
                                          width: 260,
                                          child: Text(
                                            offering.title,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),

                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            color: Colors.grey.shade200,
                                          ),
                                          child: Text(
                                            offering.status.displayLabel,
                                          ),
                                        ),
                                      ),

                                      DataCell(Text(offering.deliveryMode)),

                                      DataCell(
                                        Text('${offering.sessionsCount}'),
                                      ),

                                      DataCell(
                                        Text('${offering.enrollmentsCount}'),
                                      ),

                                      DataCell(
                                        Icon(
                                          offering.certificateEnabled
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                        ),
                                      ),

                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              tooltip: 'Sessions',
                                              icon: const Icon(Icons.schedule),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        SessionManagementPage(
                                                          offering: offering,
                                                        ),
                                                  ),
                                                );
                                              },
                                            ),

                                            IconButton(
                                              tooltip: 'Edit',
                                              icon: const Icon(Icons.edit),
                                              onPressed: () =>
                                                  _editOffering(offering),
                                            ),

                                            IconButton(
                                              tooltip: 'Delete',
                                              icon: const Icon(Icons.delete),
                                              onPressed: () =>
                                                  _deleteOffering(offering),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
