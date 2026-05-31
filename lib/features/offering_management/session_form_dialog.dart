import 'package:flutter/material.dart';

import '../../../shared/utility/enum_extension.dart';
import '../../core/enums.dart';
import 'offering_management_models.dart';
import 'offering_management_service.dart';

class SessionFormDialog extends StatefulWidget {
  final int offeringId;

  final AdminSession? session;

  const SessionFormDialog({super.key, required this.offeringId, this.session});

  @override
  State<SessionFormDialog> createState() => _SessionFormDialogState();
}

class _SessionFormDialogState extends State<SessionFormDialog> {
  final _formKey = GlobalKey<FormState>();

  final _service = OfferingManagementService();

  late TextEditingController _titleController;

  late TextEditingController _startAtController;

  late TextEditingController _endAtController;

  SessionKind _sessionKind = SessionKind.instruction;

  SessionStatus _status = SessionStatus.scheduled;

  bool _attendanceRequired = true;

  bool _loading = false;

  bool get isEdit => widget.session != null;

  @override
  void initState() {
    super.initState();

    final session = widget.session;

    _titleController = TextEditingController(text: session?.title ?? '');

    _startAtController = TextEditingController(text: session?.startAt ?? '');

    _endAtController = TextEditingController(text: session?.endAt ?? '');

    if (session != null) {
      _attendanceRequired = session.attendanceRequired;

      _sessionKind =
          SessionKind.values.byNameOrNull(session.sessionKind) ??
          SessionKind.instruction;

      _status =
          SessionStatus.values.byNameOrNull(session.status) ??
          SessionStatus.draft;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final data = {
        'title': _titleController.text,

        'session_kind': _sessionKind.name,

        'status': _status.name,

        'start_at': _startAtController.text,

        'end_at': _endAtController.text,

        'attendance_required': _attendanceRequired,
      };

      if (isEdit) {
        await _service.updateSession(sessionId: widget.session!.id, data: data);
      } else {
        await _service.createSession(offeringId: widget.offeringId, data: data);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 700,

        padding: const EdgeInsets.all(32),

        child: Form(
          key: _formKey,

          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                Text(
                  isEdit ? 'Edit Session' : 'Create Session',

                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 32),

                TextFormField(
                  controller: _titleController,

                  decoration: const InputDecoration(labelText: 'Session Title'),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 24),

                DropdownButtonFormField<SessionKind>(
                  value: _sessionKind,

                  items: SessionKind.values
                      .map(
                        (e) => DropdownMenuItem(value: e, child: Text(e.name)),
                      )
                      .toList(),

                  onChanged: (value) {
                    setState(() {
                      _sessionKind = value!;
                    });
                  },

                  decoration: const InputDecoration(labelText: 'Session Kind'),
                ),

                const SizedBox(height: 24),

                DropdownButtonFormField<SessionStatus>(
                  value: _status,

                  items: SessionStatus.values
                      .map(
                        (e) => DropdownMenuItem(value: e, child: Text(e.name)),
                      )
                      .toList(),

                  onChanged: (value) {
                    setState(() {
                      _status = value!;
                    });
                  },

                  decoration: const InputDecoration(labelText: 'Status'),
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: _startAtController,

                  decoration: const InputDecoration(labelText: 'Start At'),
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: _endAtController,

                  decoration: const InputDecoration(labelText: 'End At'),
                ),

                const SizedBox(height: 24),

                SwitchListTile(
                  value: _attendanceRequired,

                  onChanged: (value) {
                    setState(() {
                      _attendanceRequired = value;
                    });
                  },

                  title: const Text('Attendance Required'),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,

                    child: _loading
                        ? const CircularProgressIndicator()
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18),

                            child: Text(
                              isEdit ? 'Update Session' : 'Create Session',
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
