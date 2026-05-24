import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../workshop_models.dart';

class WorkshopCard extends StatelessWidget {
  final Workshop workshop;

  const WorkshopCard({super.key, required this.workshop});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,

      elevation: 2,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: InkWell(
        onTap: () {
          context.go('/workshops/${workshop.slug}');
        },

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            AspectRatio(
              aspectRatio: 16 / 9,

              child:
                  workshop.thumbnailUrl != null &&
                      workshop.thumbnailUrl!.isNotEmpty
                  ? Image.network(
                      workshop.thumbnailUrl!,

                      fit: BoxFit.cover,

                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade300,

                          child: const Center(
                            child: Icon(Icons.image, size: 48),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey.shade300,

                      child: const Center(child: Icon(Icons.image, size: 48)),
                    ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      workshop.title,

                      maxLines: 2,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 22,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Expanded(
                      child: Text(
                        workshop.shortDescription ?? '',

                        maxLines: 3,

                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Text(
                          '₹${workshop.price}',

                          style: const TextStyle(
                            fontSize: 18,

                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        ElevatedButton(
                          onPressed: () {
                            context.go('/workshops/${workshop.slug}');
                          },

                          child: const Text('View'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
