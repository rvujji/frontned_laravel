import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
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

  late final TextEditingController _videoUrlController;

  String _status = 'draft';

  int? _categoryId;

  bool _isFeatured = false;

  bool _isSaving = false;

  Uint8List? _thumbnailBytes;

  String? _thumbnailName;

  bool get isEdit => widget.workshop != null;

  @override
  void initState() {
    super.initState();

    final workshop = widget.workshop;

    _titleController = TextEditingController(text: workshop?.title ?? '');

    _titleController.addListener(() {
      if (!isEdit) {
        _slugController.text = _generateSlug(_titleController.text);
      }
    });

    _slugController = TextEditingController(text: workshop?.slug ?? '');

    _shortDescriptionController = TextEditingController(
      text: workshop?.shortDescription ?? '',
    );

    _fullDescriptionController = TextEditingController(
      text: workshop?.fullDescription ?? '',
    );

    _priceController = TextEditingController(text: workshop?.price ?? '');

    _videoUrlController = TextEditingController(text: workshop?.videoUrl ?? '');

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

    _videoUrlController.dispose();

    super.dispose();
  }

  String _generateSlug(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-');
  }

  Future<void> _pickThumbnail() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null) {
      return;
    }

    final file = result.files.first;

    setState(() {
      _thumbnailBytes = file.bytes;

      _thumbnailName = file.name;
    });
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

          videoUrl: _videoUrlController.text,

          thumbnailBytes: _thumbnailBytes,

          thumbnailName: _thumbnailName,
        );
      } else {
        await service.createWorkshop(
          categoryId: _categoryId!,

          title: _titleController.text,

          slug: _slugController.text,

          shortDescription: _shortDescriptionController.text,

          fullDescription: _fullDescriptionController.text,

          isFeatured: _isFeatured,

          price: _priceController.text,

          status: _status,

          videoUrl: _videoUrlController.text,

          thumbnailBytes: _thumbnailBytes,

          thumbnailName: _thumbnailName,
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
        width: 520,

        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              TextField(
                controller: _titleController,

                decoration: const InputDecoration(labelText: 'Title'),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _slugController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Slug',
                  helperText: 'Automatically generated',
                ),
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

                keyboardType: TextInputType.number,

                decoration: const InputDecoration(labelText: 'Price'),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _videoUrlController,

                decoration: const InputDecoration(
                  labelText: 'Video URL',
                  hintText: 'https://youtube.com/...',
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Workshop Thumbnail',

                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: _pickThumbnail,

                icon: const Icon(Icons.upload),

                label: const Text('Choose Thumbnail'),
              ),

              const SizedBox(height: 16),

              if (_thumbnailBytes != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),

                  child: Image.memory(
                    _thumbnailBytes!,

                    height: 180,

                    width: double.infinity,

                    fit: BoxFit.cover,
                  ),
                )
              else if (widget.workshop?.thumbnailUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),

                  child: Image.network(
                    widget.workshop!.thumbnailUrl!,

                    height: 180,

                    width: double.infinity,

                    fit: BoxFit.cover,
                  ),
                ),

              const SizedBox(height: 24),

              categoriesAsync.when(
                loading: () {
                  return const Center(child: CircularProgressIndicator());
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

                  DropdownMenuItem(value: 'archived', child: Text('Archived')),
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
