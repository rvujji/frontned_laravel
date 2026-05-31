import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/offering_model.dart';
import 'delivery_mode_badge.dart';

class OfferingCard extends StatelessWidget {
  final OfferingModel offering;

  const OfferingCard({super.key, required this.offering});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push('/offerings/${offering.slug}');
      },
      borderRadius: BorderRadius.circular(20),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DeliveryModeBadge(mode: offering.deliveryMode),

              const SizedBox(height: 16),

              Text(
                offering.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text('${offering.sessions.length} Sessions'),

              const SizedBox(height: 8),

              Text('₹ ${offering.price}'),

              const SizedBox(height: 8),

              Text(
                offering.startDate != null
                    ? offering.startDate!.split('T').first
                    : 'Date TBD',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
