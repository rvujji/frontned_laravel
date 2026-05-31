import 'package:flutter/material.dart';

class AttendanceBadge extends StatelessWidget {
  final bool attended;

  const AttendanceBadge({super.key, required this.attended});

  @override
  Widget build(BuildContext context) {
    final color = attended ? Colors.green : Colors.orange;

    final label = attended ? 'ATTENDED' : 'PENDING';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

      decoration: BoxDecoration(
        color: color.withOpacity(.12),

        borderRadius: BorderRadius.circular(30),
      ),

      child: Text(
        label,

        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
