import 'package:flutter/material.dart';

import '../../core/enums.dart';
import 'offering_management_models.dart';
import 'offering_management_service.dart';

class OfferingFormDialog extends StatefulWidget {
  final AdminOffering? offering;

  const OfferingFormDialog({super.key, this.offering});

  @override
  State<OfferingFormDialog> createState() => _OfferingFormDialogState();
}

class _OfferingFormDialogState extends State<OfferingFormDialog> {
  final _formKey = GlobalKey<FormState>();

  final _service = OfferingManagementService();

  late TextEditingController _titleController;
  late TextEditingController _slugController;

  List<OfferingWorkshop> _workshops = [];

  int? _selectedWorkshopId;

  String _status = 'draft';

  String _deliveryMode = 'physical';

  String _enrollmentType = EnrollmentType.session_selection.name;

  String _sessionSelectionRule = SessionSelectionRule.any_n_of_m.name;

  String _completionRule = CompletionRule.attend_n_sessions.name;

  String _capacityMode = CapacityMode.both.name;

  late TextEditingController _minimumSessionsController;

  late TextEditingController _maximumSessionsController;

  bool _certificateEnabled = true;

  bool _loading = false;

  String? _errorMessage;

  bool get isEdit => widget.offering != null;

  @override
  void initState() {
    super.initState();

    final offering = widget.offering;

    _titleController = TextEditingController(text: offering?.title ?? '');

    _slugController = TextEditingController(text: offering?.slug ?? '');

    _selectedWorkshopId = offering?.workshopId;

    _minimumSessionsController = TextEditingController(
      text: offering?.minimumSessionsRequired.toString() ?? '0',
    );

    _maximumSessionsController = TextEditingController(
      text: offering?.maximumSessionsSelectable.toString() ?? '0',
    );

    if (offering != null) {
      _status = offering.status;
      _deliveryMode = offering.deliveryMode;
      _enrollmentType = offering.enrollmentType;

      _sessionSelectionRule = offering.sessionSelectionRule;

      _completionRule = offering.completionRule;

      _capacityMode = offering.capacityMode;
      _certificateEnabled = offering.certificateEnabled;
    }

    _titleController.addListener(() {
      if (!isEdit) {
        _slugController.text = _generateSlug(_titleController.text);
      }
    });

    _loadWorkshops();
  }

  Future<void> _loadWorkshops() async {
    try {
      final workshops = await _service.fetchWorkshops();

      if (mounted) {
        setState(() {
          _workshops = workshops;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load workshops';
        });
      }
    }
  }

  String _generateSlug(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedWorkshopId == null) {
      setState(() {
        _errorMessage = 'Please select a workshop';
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final data = {
        'workshop_id': _selectedWorkshopId,

        'title': _titleController.text.trim(),

        'slug': _slugController.text.trim(),

        'status': _status,

        'delivery_mode': _deliveryMode,

        'certificate_enabled': _certificateEnabled,
        'enrollment_type': _enrollmentType,

        'session_selection_rule': _sessionSelectionRule,

        'completion_rule': _completionRule,

        'capacity_mode': _capacityMode,

        'minimum_sessions_required':
            int.tryParse(_minimumSessionsController.text) ?? 0,

        'maximum_sessions_selectable':
            int.tryParse(_maximumSessionsController.text) ?? 0,
      };

      if (isEdit) {
        await _service.updateOffering(
          offeringId: widget.offering!.id,
          data: data,
        );
      } else {
        await _service.createOffering(data: data);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
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
      child: SizedBox(
        width: 700,
        height: 650,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                isEdit ? 'Edit Offering' : 'Create Offering',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (_errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(color: Colors.red.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      DropdownButtonFormField<int>(
                        value: _selectedWorkshopId,
                        decoration: const InputDecoration(
                          labelText: 'Workshop *',
                        ),
                        items: _workshops
                            .map(
                              (workshop) => DropdownMenuItem<int>(
                                value: workshop.id,
                                child: Text(workshop.title),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedWorkshopId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Required';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _slugController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Slug',
                          helperText: 'Automatically generated',
                        ),
                      ),

                      const SizedBox(height: 24),

                      DropdownButtonFormField<String>(
                        value: _status,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: const [
                          DropdownMenuItem(
                            value: 'published',
                            child: Text('Published'),
                          ),
                          DropdownMenuItem(
                            value: 'draft',
                            child: Text('Draft'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _status = value!;
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      DropdownButtonFormField<String>(
                        value: _deliveryMode,
                        decoration: const InputDecoration(
                          labelText: 'Delivery Mode',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'virtual',
                            child: Text('Virtual'),
                          ),
                          DropdownMenuItem(
                            value: 'physical',
                            child: Text('Physical'),
                          ),
                          DropdownMenuItem(
                            value: 'hybrid',
                            child: Text('Hybrid'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _deliveryMode = value!;
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      DropdownButtonFormField<String>(
                        value: _enrollmentType,
                        decoration: const InputDecoration(
                          labelText: 'Enrollment Type',
                        ),
                        items: EnrollmentType.values
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.name,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _enrollmentType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      DropdownButtonFormField<String>(
                        value: _sessionSelectionRule,
                        decoration: const InputDecoration(
                          labelText: 'Session Selection Rule',
                        ),
                        items: SessionSelectionRule.values
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.name,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _sessionSelectionRule = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      DropdownButtonFormField<String>(
                        value: _completionRule,
                        decoration: const InputDecoration(
                          labelText: 'Completion Rule',
                        ),
                        items: CompletionRule.values
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.name,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _completionRule = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      DropdownButtonFormField<String>(
                        value: _capacityMode,
                        decoration: const InputDecoration(
                          labelText: 'Capacity Mode',
                        ),
                        items: CapacityMode.values
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.name,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _capacityMode = value!;
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _minimumSessionsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Minimum Sessions Required',
                        ),
                      ),

                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _maximumSessionsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Maximum Sessions Selectable',
                        ),
                      ),

                      const SizedBox(height: 24),

                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _certificateEnabled,
                        onChanged: (value) {
                          setState(() {
                            _certificateEnabled = value;
                          });
                        },
                        title: const Text('Certificate Enabled'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            isEdit ? 'Update Offering' : 'Create Offering',
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
