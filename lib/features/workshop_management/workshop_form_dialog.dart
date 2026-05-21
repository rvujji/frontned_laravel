import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontned_laravel/features/workshop_management/workshop_management_page.dart';

import 'workshop_management_models.dart';
import 'workshop_management_service.dart';

class WorkshopFormDialog extends ConsumerStatefulWidget {
  final ManagedWorkshop? workshop;

  const WorkshopFormDialog({super.key, this.workshop});

  @override
  ConsumerState<WorkshopFormDialog> createState() => _WorkshopFormDialogState();
}

class _WorkshopFormDialogState extends ConsumerState<WorkshopFormDialog> {
  late final TextEditingController _titleController;

  late final TextEditingController _slugController;

  late final TextEditingController _shortDescriptionController;

  late final TextEditingController _fullDescriptionController;

  late final TextEditingController _priceController;

  String _status = 'draft';
  int? _categoryId;

  bool _isFeatured = false;

  bool _isSaving = false;

  bool get isEdit => widget.workshop != null;

  @override
  void initState() {
    super.initState();

    final workshop = widget.workshop;

    _titleController = TextEditingController(text: workshop?.title ?? '');

    _slugController = TextEditingController(text: workshop?.slug ?? '');

    _shortDescriptionController = TextEditingController(
      text: workshop?.shortDescription ?? '',
    );

    _fullDescriptionController = TextEditingController(
      text: workshop?.fullDescription ?? '',
    );

    _priceController = TextEditingController(text: workshop?.price ?? '');

    _status = workshop?.status ?? 'draft';
    _categoryId = workshop?.categoryId;

    _isFeatured = workshop?.isFeatured ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();

    _slugController.dispose();

    _shortDescriptionController.dispose();

    _fullDescriptionController.dispose();

    _priceController.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    if (_categoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select category')));

      return;
    }
    setState(() {
      _isSaving = true;
    });

    try {
      final service = ref.read(workshopManagementServiceProvider);

      if (isEdit) {
        await service.updateWorkshop(
          id: widget.workshop!.id,
          categoryId: _categoryId!,
          title: _titleController.text,

          slug: _slugController.text,

          shortDescription: _shortDescriptionController.text,

          fullDescription: _fullDescriptionController.text,

          isFeatured: _isFeatured,

          price: _priceController.text,

          status: _status,
        );
      } else {
        await service.createWorkshop(
          title: _titleController.text,
          categoryId: _categoryId!,
          slug: _slugController.text,

          shortDescription: _shortDescriptionController.text,

          fullDescription: _fullDescriptionController.text,

          isFeatured: _isFeatured,

          price: _priceController.text,

          status: _status,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(workshopCategoriesProvider);
    return AlertDialog(
      title: Text(isEdit ? 'Edit Workshop' : 'Create Workshop'),

      content: SizedBox(
        width: 500,

        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              TextField(
                controller: _titleController,

                decoration: const InputDecoration(labelText: 'Title'),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _slugController,

                decoration: const InputDecoration(labelText: 'Slug'),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _shortDescriptionController,

                maxLines: 2,

                decoration: const InputDecoration(
                  labelText: 'Short Description',
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _fullDescriptionController,

                maxLines: 6,

                decoration: const InputDecoration(
                  labelText: 'Full Description',
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _priceController,

                decoration: const InputDecoration(labelText: 'Price'),
              ),

              const SizedBox(height: 16),

              categoriesAsync.when(
                loading: () {
                  return const CircularProgressIndicator();
                },

                error: (error, stackTrace) {
                  return Text(error.toString());
                },

                data: (categories) {
                  return DropdownButtonFormField<int>(
                    value: _categoryId,

                    decoration: const InputDecoration(labelText: 'Category'),

                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,

                        child: Text(category.name),
                      );
                    }).toList(),

                    onChanged: (value) {
                      setState(() {
                        _categoryId = value;
                      });
                    },
                  );
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _status,

                decoration: const InputDecoration(labelText: 'Status'),

                items: const [
                  DropdownMenuItem(value: 'draft', child: Text('Draft')),

                  DropdownMenuItem(
                    value: 'published',

                    child: Text('Published'),
                  ),
                ],

                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              CheckboxListTile(
                value: _isFeatured,

                contentPadding: EdgeInsets.zero,

                title: const Text('Featured Workshop'),

                onChanged: (value) {
                  setState(() {
                    _isFeatured = value ?? false;
                  });
                },
              ),
            ],
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: _isSaving
              ? null
              : () {
                  Navigator.pop(context);
                },

          child: const Text('Cancel'),
        ),

        ElevatedButton(
          onPressed: _isSaving ? null : _save,

          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,

                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEdit ? 'Update' : 'Create'),
        ),
      ],
    );
  }
}
