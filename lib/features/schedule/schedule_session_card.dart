import 'package:flutter/material.dart';

import 'schedule_models.dart';

class ScheduleSessionCard extends StatelessWidget {
  final ScheduledSession session;

  const ScheduleSessionCard({super.key, required this.session});

  Color get statusColor {
    if (session.isLive) {
      return Colors.red;
    }

    if (session.attended) {
      return Colors.green;
    }

    if (session.missed) {
      return Colors.orange;
    }

    return Colors.blue;
  }

  String get statusLabel {
    if (session.isLive) {
      return 'LIVE';
    }

    if (session.attended) {
      return 'ATTENDED';
    }

    if (session.missed) {
      return 'MISSED';
    }

    return session.reservationStatus.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),

        side: BorderSide(color: Colors.grey.shade300),
      ),

      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

              decoration: BoxDecoration(
                color: statusColor.withOpacity(.12),

                borderRadius: BorderRadius.circular(30),
              ),

              child: Text(
                statusLabel,

                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              session.title,

              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text(session.offeringTitle),

            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(Icons.schedule, size: 18),

                const SizedBox(width: 8),

                Expanded(child: Text(session.startAt)),
              ],
            ),

            const Spacer(),

            if (session.isLive)
              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  onPressed: () {},

                  icon: const Icon(Icons.play_arrow),

                  label: const Text('Join Session'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
