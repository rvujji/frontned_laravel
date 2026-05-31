import 'package:flutter/material.dart';

class ReservationStatusBadge extends StatelessWidget {
  final String status;

  const ReservationStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (status.toLowerCase()) {
      case 'reserved':
        color = Colors.blue;
        break;

      case 'attended':
        color = Colors.green;
        break;

      case 'waitlisted':
        color = Colors.orange;
        break;

      case 'cancelled':
        color = Colors.red;
        break;

      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

      decoration: BoxDecoration(
        color: color.withOpacity(.12),

        borderRadius: BorderRadius.circular(30),
      ),

      child: Text(
        status.toUpperCase(),

        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
