import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../workshop_models.dart';

class CompactWorkshopCard extends StatelessWidget {
  final Workshop workshop;

  const CompactWorkshopCard({super.key, required this.workshop});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,

      child: Card(
        clipBehavior: Clip.antiAlias,

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

                            child: const Center(child: Icon(Icons.image)),
                          );
                        },
                      )
                    : Container(color: Colors.grey.shade300),
              ),

              Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      workshop.title,

                      maxLines: 2,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 18,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      workshop.shortDescription ?? '',

                      maxLines: 2,

                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      '₹${workshop.price}',

                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
