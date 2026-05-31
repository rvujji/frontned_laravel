import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../shared/navigation/app_shell.dart';
import '../../../shared/utility/string_extension.dart';
import '../../offerings/providers/offering_provider.dart';
import '../../offerings/widgets/offering_card.dart';
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

  Future<void> _openVideo(String url) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(uri);

    if (!launched && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open video')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final workshopAsync = ref.watch(workshopDetailProvider(widget.slug));
    final offeringsAsync = ref.watch(workshopOfferingsProvider(widget.slug));
    return AppShell(
      child: workshopAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        data: (workshop) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (workshop.thumbnailUrl != null)
                  if (workshop.thumbnailUrl != null &&
                      workshop.thumbnailUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),

                      child: AspectRatio(
                        aspectRatio: 16 / 9,

                        child: Image.network(
                          workshop.thumbnailUrl!,

                          fit: BoxFit.cover,

                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade300,

                              child: const Center(
                                child: Icon(Icons.image, size: 64),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
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
                          Chip(
                            label: Text(
                              workshop.category?.name.displayLabel ?? '',
                            ),
                          ),
                          Chip(label: Text(workshop.status.displayLabel)),
                          Chip(label: Text('₹ ${workshop.price}')),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          if (workshop.videoUrl != null &&
                              workshop.videoUrl!.isNotEmpty)
                            OutlinedButton.icon(
                              onPressed: () async {
                                await _openVideo(workshop.videoUrl!);
                              },
                              icon: const Icon(Icons.play_circle_outline),
                              label: const Text('Watch Intro Video'),
                            ),
                        ],
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
                      const SizedBox(height: 56),

                      const Text(
                        'Available Offerings',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 24),

                      offeringsAsync.when(
                        loading: () {
                          return const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },

                        error: (error, stackTrace) {
                          return Text(error.toString());
                        },

                        data: (offerings) {
                          if (offerings.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'No offerings available currently.',
                              ),
                            );
                          }

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: offerings.length,

                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20,
                                  mainAxisExtent: 240,
                                ),

                            itemBuilder: (context, index) {
                              return OfferingCard(offering: offerings[index]);
                            },
                          );
                        },
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
