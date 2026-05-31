import 'package:flutter/material.dart';

import '../models/reservation_model.dart';
import 'attendance_badge.dart';
import 'reservation_status_badge.dart';

class LearnerSessionCard extends StatelessWidget {
  final ReservationModel reservation;

  const LearnerSessionCard({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    final session = reservation.session;

    return Card(
      elevation: 0,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),

        side: BorderSide(color: Colors.grey.shade300),
      ),

      child: Padding(
        padding: const EdgeInsets.all(22),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                ReservationStatusBadge(status: reservation.status),

                const SizedBox(width: 12),

                AttendanceBadge(attended: reservation.attended),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              session.title,

              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(Icons.schedule, size: 18),

                const SizedBox(width: 8),

                Expanded(child: Text(session.startAt)),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.location_on, size: 18),

                const SizedBox(width: 8),

                Expanded(child: Text(session.venueName ?? 'Virtual Session')),
              ],
            ),

            const Spacer(),

            if (session.isLive)
              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  onPressed: () {},

                  icon: const Icon(Icons.play_arrow),

                  label: const Text('Join Live Session'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
