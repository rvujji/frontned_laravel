import 'package:flutter/material.dart';

import '../../../shared/utility/string_extension.dart';
import '../../shared/responsive_layout.dart';
import '../dashboard/widgets/dashboard_shell.dart';
import 'offering_management_models.dart';
import 'offering_management_service.dart';
import 'session_form_dialog.dart';

class SessionManagementPage extends StatefulWidget {
  final AdminOffering offering;

  const SessionManagementPage({super.key, required this.offering});

  @override
  State<SessionManagementPage> createState() => _SessionManagementPageState();
}

class _SessionManagementPageState extends State<SessionManagementPage> {
  final _service = OfferingManagementService();

  bool _loading = true;

  List<AdminSession> sessions = [];

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
      sessions = await _service.fetchSessions(widget.offering.id);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _createSession() async {
    final created = await showDialog<bool>(
      context: context,

      builder: (_) {
        return SessionFormDialog(offeringId: widget.offering.id);
      },
    );

    if (created == true) {
      _load();
    }
  }

  Future<void> _editSession(AdminSession session) async {
    final updated = await showDialog<bool>(
      context: context,

      builder: (_) {
        return SessionFormDialog(
          offeringId: widget.offering.id,

          session: session,
        );
      },
    );

    if (updated == true) {
      _load();
    }
  }

  Future<void> _deleteSession(AdminSession session) async {
    final confirmed =
        await showDialog<bool>(
          context: context,

          builder: (_) {
            return AlertDialog(
              title: const Text('Delete Session'),

              content: Text('Delete "${session.title}"?'),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },

                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },

                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    await _service.deleteSession(session.id);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Session deleted')));
    }

    _load();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: '${widget.offering.title} Sessions',

      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),

              ElevatedButton.icon(
                onPressed: _createSession,

                icon: const Icon(Icons.add),

                label: const Text('Create Session'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    itemCount: sessions.length,

                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          ResponsiveLayout.isDesktop(
                            MediaQuery.of(context).size.width,
                          )
                          ? 3
                          : 1,

                      crossAxisSpacing: 20,

                      mainAxisSpacing: 20,

                      mainAxisExtent: 300,
                    ),

                    itemBuilder: (context, index) {
                      final session = sessions[index];

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
                              Chip(label: Text(session.status.displayLabel)),

                              const SizedBox(height: 18),

                              Text(
                                session.title,

                                style: const TextStyle(
                                  fontSize: 22,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 14),

                              Text(session.sessionKind),

                              const SizedBox(height: 10),

                              Text(session.startAt),

                              const Spacer(),

                              Text('${session.reservationsCount} Reservations'),

                              const SizedBox(height: 10),

                              if (session.attendanceRequired)
                                const Chip(label: Text('Attendance Required')),

                              const SizedBox(height: 20),

                              Row(
                                children: [
                                  const Spacer(),

                                  IconButton(
                                    onPressed: () => _editSession(session),

                                    icon: const Icon(Icons.edit),
                                  ),

                                  IconButton(
                                    onPressed: () => _deleteSession(session),

                                    icon: const Icon(Icons.delete),
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
      ),
    );
  }
}
