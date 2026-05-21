import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/navigation/app_shell.dart';
import '../../auth/auth_provider.dart';
import '../workshop_models.dart';
import '../workshop_service.dart';

final workshopDetailProvider = FutureProvider.family<Workshop, String>((
  ref,
  slug,
) async {
  final service = ref.read(workshopServiceProvider);

  return service.fetchWorkshopBySlug(slug);
});

class WorkshopDetailPage extends ConsumerStatefulWidget {
  final String slug;

  const WorkshopDetailPage({super.key, required this.slug});

  @override
  ConsumerState<WorkshopDetailPage> createState() => _WorkshopDetailPageState();
}

class _WorkshopDetailPageState extends ConsumerState<WorkshopDetailPage> {
  bool _isEnrolling = false;

  Future<void> _enroll(Workshop workshop) async {
    final user = ref.read(authProvider).value;

    if (user == null) {
      context.go('/login?redirect=/workshops/${widget.slug}');
      return;
    }

    setState(() {
      _isEnrolling = true;
    });

    try {
      final service = ref.read(workshopServiceProvider);

      await service.enrollWorkshop(workshop.id);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Enrollment successful')));
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
          _isEnrolling = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final workshopAsync = ref.watch(workshopDetailProvider(widget.slug));

    return AppShell(
      child: workshopAsync.when(
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },

        error: (error, stackTrace) {
          return Center(child: Text(error.toString()));
        },

        data: (workshop) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(48),

                  color: Colors.indigo.shade50,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      if (workshop.isFeatured == true)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.orange,

                            borderRadius: BorderRadius.circular(24),
                          ),

                          child: const Text(
                            'Featured',

                            style: TextStyle(color: Colors.white),
                          ),
                        ),

                      const SizedBox(height: 16),

                      Text(
                        workshop.title,

                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        workshop.shortDescription ?? '',

                        style: const TextStyle(fontSize: 20, height: 1.5),
                      ),

                      const SizedBox(height: 24),

                      Wrap(
                        spacing: 16,
                        runSpacing: 16,

                        children: [
                          Chip(label: Text(workshop.category?.name ?? '')),

                          Chip(label: Text(workshop.status)),

                          Chip(label: Text('₹ ${workshop.price}')),
                        ],
                      ),

                      const SizedBox(height: 32),

                      ElevatedButton(
                        onPressed: _isEnrolling
                            ? null
                            : () {
                                _enroll(workshop);
                              },

                        child: _isEnrolling
                            ? const SizedBox(
                                width: 20,
                                height: 20,

                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),

                                child: Text('Enroll Now'),
                              ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(32),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'Workshop Details',

                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        workshop.fullDescription ?? '',

                        style: const TextStyle(fontSize: 18, height: 1.8),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
