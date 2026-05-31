import 'package:flutter/material.dart';

import '../../core/enums.dart';
import '../../shared/utility/string_extension.dart';

class AttendanceStatusBadge extends StatelessWidget {
  final AttendanceStatus status;

  const AttendanceStatusBadge({super.key, required this.status});

  Color get color {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;

      case AttendanceStatus.absent:
        return Colors.red;

      case AttendanceStatus.late:
        return Colors.orange;

      case AttendanceStatus.partial:
        return Colors.blue;

      case AttendanceStatus.excused:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),

        borderRadius: BorderRadius.circular(30),
      ),

      child: Text(
        status.name.displayLabel,

        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
