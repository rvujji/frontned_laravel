import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../workshop_models.dart';

class WorkshopCard extends StatelessWidget {
  final Workshop workshop;

  const WorkshopCard({super.key, required this.workshop});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        context.go('/workshops/${workshop.slug}');
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                workshop.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Text(
                  workshop.shortDescription ?? 'No description',
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '₹ ${workshop.price}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
