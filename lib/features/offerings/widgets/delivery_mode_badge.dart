import 'package:flutter/material.dart';

import '../../../core/enums.dart';

class DeliveryModeBadge extends StatelessWidget {
  final DeliveryMode mode;

  const DeliveryModeBadge({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    IconData icon;

    switch (mode) {
      case DeliveryMode.virtual:
        icon = Icons.videocam;
        break;

      case DeliveryMode.hybrid:
        icon = Icons.sync;
        break;

      case DeliveryMode.physical:
        icon = Icons.location_on;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(.08),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(mode.name.toUpperCase()),
        ],
      ),
    );
  }
}
