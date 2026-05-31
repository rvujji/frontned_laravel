import 'package:intl/intl.dart';

extension DateTimeExtension on String {
  String get readableDateTime {
    try {
      final date = DateTime.parse(this);

      return DateFormat('dd MMM yyyy • hh:mm a').format(date.toLocal());
    } catch (_) {
      return this;
    }
  }

  String get readableDate {
    try {
      final date = DateTime.parse(this);

      return DateFormat('dd MMM yyyy').format(date.toLocal());
    } catch (_) {
      return this;
    }
  }

  String get readableTime {
    try {
      final date = DateTime.parse(this);

      return DateFormat('hh:mm a').format(date.toLocal());
    } catch (_) {
      return this;
    }
  }

  String rangeTo(String end) {
    try {
      final startDate = DateTime.parse(this);

      final endDate = DateTime.parse(end);

      final sameDay =
          startDate.year == endDate.year &&
          startDate.month == endDate.month &&
          startDate.day == endDate.day;

      if (sameDay) {
        return '${DateFormat('dd MMM yyyy').format(startDate.toLocal())} • '
            '${DateFormat('hh:mm a').format(startDate.toLocal())}'
            ' → '
            '${DateFormat('hh:mm a').format(endDate.toLocal())}';
      }

      return '${DateFormat('dd MMM yyyy • hh:mm a').format(startDate.toLocal())}'
          ' → '
          '${DateFormat('dd MMM yyyy • hh:mm a').format(endDate.toLocal())}';
    } catch (_) {
      return '$this → $end';
    }
  }
}
