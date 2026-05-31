import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums.dart';
import 'session_management_models.dart';
import 'session_management_provider.dart';
import 'session_management_service.dart';

class SessionFormDialog extends ConsumerStatefulWidget {
  final SessionManagementModel? session;

  const SessionFormDialog({super.key, this.session});

  @override
  ConsumerState<SessionFormDialog> createState() => _SessionFormDialogState();
}

class _SessionFormDialogState extends ConsumerState<SessionFormDialog> {
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;

  late final TextEditingController _titleController;
  late final TextEditingController _sessionNumberController;
  late final TextEditingController _capacityController;
  late final TextEditingController _notesController;
  DateTime? _startAt;
  DateTime? _endAt;

  int? _workshopId;
  int? _offeringId;

  SessionKind _sessionKind = SessionKind.values.first;

  DeliveryMode _deliveryMode = DeliveryMode.values.first;

  SessionStatus _status = SessionStatus.values.first;

  // late int _duration;
  // late String? _venueName;
  // late String? _venueAddress;
  // late String? _meetingLink;
  //
  // late String? _meetingPassword;
  // late double? _completionWeight;
  // late String? _agenda;
  //
  // late String? _materials;
  // late String? _prework;
  //
  // late String? _homework;
  // late String? _recordingUrl;
  // late String? _slidesUrl;

  bool _attendanceRequired = false;
  bool _waitlistEnabled = false;
  bool _bookable = true;
  late final TextEditingController _durationController;
  late final TextEditingController _timezoneController;

  late final TextEditingController _venueNameController;
  late final TextEditingController _venueAddressController;

  late final TextEditingController _meetingLinkController;
  late final TextEditingController _meetingPasswordController;

  late final TextEditingController _completionWeightController;

  late final TextEditingController _agendaController;
  late final TextEditingController _materialsController;

  late final TextEditingController _preworkController;
  late final TextEditingController _homeworkController;

  late final TextEditingController _recordingUrlController;
  late final TextEditingController _slidesUrlController;

  final _service = SessionManagementService();

  bool get isEdit => widget.session != null;

  @override
  void initState() {
    super.initState();

    final session = widget.session;

    _titleController = TextEditingController(text: session?.title ?? '');

    _sessionNumberController = TextEditingController(
      text: session?.sessionNumber.toString() ?? '1',
    );

    _capacityController = TextEditingController(
      text: session?.capacity.toString() ?? '30',
    );

    _notesController = TextEditingController(text: session?.notes ?? '');
    _durationController = TextEditingController(
      text: session?.durationMinutes?.toString() ?? '',
    );

    _timezoneController = TextEditingController(
      text: session?.timezone ?? 'Asia/Kolkata',
    );

    _venueNameController = TextEditingController(
      text: session?.venueName ?? '',
    );

    _venueAddressController = TextEditingController(
      text: session?.venueAddress ?? '',
    );

    _meetingLinkController = TextEditingController(
      text: session?.meetingLink ?? '',
    );

    _meetingPasswordController = TextEditingController(
      text: session?.meetingPassword ?? '',
    );

    _completionWeightController = TextEditingController(
      text: session?.completionWeight?.toString() ?? '',
    );

    _agendaController = TextEditingController(
      text: session?.agendaSummary ?? '',
    );

    _materialsController = TextEditingController(
      text: session?.materialsRequired ?? '',
    );

    _preworkController = TextEditingController(text: session?.prework ?? '');

    _homeworkController = TextEditingController(text: session?.homework ?? '');

    _recordingUrlController = TextEditingController(
      text: session?.recordingUrl ?? '',
    );

    _slidesUrlController = TextEditingController(
      text: session?.slidesUrl ?? '',
    );

    if (session != null) {
      _workshopId = session.workshopId;
      _offeringId = session.workshopOfferingId;

      _sessionKind = session.sessionKind;

      _deliveryMode = session.deliveryMode;

      _status = session.status;

      _attendanceRequired = session.attendanceRequired;

      _waitlistEnabled = session.waitlistEnabled;

      _bookable = session.bookable;
      _startAt = session.startAt;
      _endAt = session.endAt;
      // _duration = session.durationMinutes;
      // _venueName = session.venueName;
      // _venueAddress = session.venueAddress;
      // _meetingLink = session.meetingLink;
      // _meetingPassword = session.meetingPassword;
      // _completionWeight = session.completionWeight;
      // _agenda = session.agendaSummary;
      // _materials = session.materialsRequired;
      // _prework = session.prework;
      // _homework = session.homework;
      // _recordingUrl = session.recordingUrl;
      // _slidesUrl = session.slidesUrl;
    }
  }

  Future<void> _pickStartDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startAt ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startAt ?? DateTime.now()),
    );

    if (time == null) return;

    setState(() {
      _startAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
    if (_startAt != null && _endAt != null) {
      _durationController.text = _endAt!
          .difference(_startAt!)
          .inMinutes
          .toString();
    }
  }

  Future<void> _pickEndDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endAt ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endAt ?? DateTime.now()),
    );

    if (time == null) return;

    setState(() {
      _endAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
    if (_startAt != null && _endAt != null) {
      _durationController.text = _endAt!
          .difference(_startAt!)
          .inMinutes
          .toString();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_offeringId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an offering')),
      );
      return;
    }

    if (_startAt == null || _endAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end date/time')),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final payload = {
        'workshop_offering_id': _offeringId,
        'session_number': int.tryParse(_sessionNumberController.text) ?? 1,
        'title': _titleController.text,
        'session_kind': _sessionKind.name,
        'delivery_mode': _deliveryMode.name,
        'capacity': int.tryParse(_capacityController.text) ?? 0,
        'attendance_required': _attendanceRequired,
        'waitlist_enabled': _waitlistEnabled,
        'bookable': _bookable,
        'status': _status.name,
        'notes': _notesController.text,
        'start_at': _startAt!.toIso8601String(),
        'end_at': _endAt!.toIso8601String(),
        'timezone': _timezoneController.text,
        'duration_minutes': int.tryParse(_durationController.text),

        'venue_name': _venueNameController.text,
        'venue_address': _venueAddressController.text,

        'meeting_link': _meetingLinkController.text,
        'meeting_password': _meetingPasswordController.text,

        'completion_weight':
            double.tryParse(_completionWeightController.text) ?? 0,

        'agenda_summary': _agendaController.text,

        'materials_required': _materialsController.text,

        'prework': _preworkController.text,

        'homework': _homeworkController.text,

        'recording_url': _recordingUrlController.text,

        'slides_url': _slidesUrlController.text,
      };

      if (isEdit) {
        await _service.updateSession(
          sessionId: widget.session!.id,
          data: payload,
        );
      } else {
        await _service.createSession(data: payload);
      }

      if (!mounted) return;

      Navigator.pop(context, true);
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
    final workshopsAsync = ref.watch(workshopsProvider);
    final offeringsAsync = ref.watch(offeringsProvider);

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
                  style: Theme.of(context).textTheme.headlineSmall,
                ),

                const SizedBox(height: 24),

                workshopsAsync.when(
                  data: (workshops) {
                    return Column(
                      children: [
                        DropdownButtonFormField<int>(
                          initialValue: _workshopId,
                          decoration: const InputDecoration(
                            labelText: 'Workshop',
                          ),
                          items: workshops
                              .map(
                                (workshop) => DropdownMenuItem(
                                  value: workshop.id,
                                  child: Text(workshop.title),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _workshopId = value;
                              _offeringId = null;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        offeringsAsync.when(
                          data: (offerings) {
                            final filteredOfferings = offerings.where((o) {
                              if (_workshopId == null) {
                                return true;
                              }

                              return o.workshopId == _workshopId;
                            }).toList();

                            return DropdownButtonFormField<int>(
                              initialValue: _offeringId,
                              decoration: const InputDecoration(
                                labelText: 'Offering',
                              ),
                              items: filteredOfferings
                                  .map(
                                    (o) => DropdownMenuItem(
                                      value: o.id,
                                      child: Text(o.title),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _offeringId = value;
                                });
                              },
                            );
                          },
                          loading: () => const CircularProgressIndicator(),
                          error: (_, __) => const SizedBox(),
                        ),
                      ],
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const SizedBox(),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _sessionNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Session Number',
                  ),
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _capacityController,
                  decoration: const InputDecoration(labelText: 'Capacity'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _completionWeightController,
                  decoration: const InputDecoration(
                    labelText: 'Completion Weight',
                  ),
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<SessionKind>(
                  value: _sessionKind,
                  decoration: const InputDecoration(labelText: 'Session Kind'),
                  items: SessionKind.values
                      .map(
                        (e) => DropdownMenuItem(value: e, child: Text(e.name)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _sessionKind = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<DeliveryMode>(
                  value: _deliveryMode,
                  decoration: const InputDecoration(labelText: 'Delivery Mode'),
                  items: DeliveryMode.values
                      .map(
                        (e) => DropdownMenuItem(value: e, child: Text(e.name)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _deliveryMode = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 16),

                ListTile(
                  title: const Text('Start Date & Time'),
                  subtitle: Text(_startAt?.toString() ?? 'Not selected'),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: _pickStartDateTime,
                ),

                const SizedBox(height: 12),

                ListTile(
                  title: const Text('End Date & Time'),
                  subtitle: Text(_endAt?.toString() ?? 'Not selected'),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: _pickEndDateTime,
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _timezoneController,
                  decoration: const InputDecoration(labelText: 'Timezone'),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duration (Minutes)',
                  ),
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<SessionStatus>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: SessionStatus.values
                      .map(
                        (e) => DropdownMenuItem(value: e, child: Text(e.name)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _status = value;
                      });
                    }
                  },
                ),

                SwitchListTile(
                  title: const Text('Attendance Required'),
                  value: _attendanceRequired,
                  onChanged: (value) {
                    setState(() {
                      _attendanceRequired = value;
                    });
                  },
                ),

                SwitchListTile(
                  title: const Text('Waitlist Enabled'),
                  value: _waitlistEnabled,
                  onChanged: (value) {
                    setState(() {
                      _waitlistEnabled = value;
                    });
                  },
                ),

                SwitchListTile(
                  title: const Text('Bookable'),
                  value: _bookable,
                  onChanged: (value) {
                    setState(() {
                      _bookable = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _venueNameController,
                  decoration: const InputDecoration(labelText: 'Venue Name'),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _venueAddressController,
                  decoration: const InputDecoration(labelText: 'Venue Address'),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _meetingLinkController,
                  decoration: const InputDecoration(labelText: 'Meeting Link'),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _meetingPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Meeting Password',
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _agendaController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Agenda Summary',
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _materialsController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Materials Required',
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _preworkController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Prework'),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _homeworkController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Homework'),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _recordingUrlController,
                  decoration: const InputDecoration(labelText: 'Recording URL'),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _slidesUrlController,
                  decoration: const InputDecoration(labelText: 'Slides URL'),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),

                const SizedBox(height: 24),

                FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: Text(isEdit ? 'Update Session' : 'Create Session'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
