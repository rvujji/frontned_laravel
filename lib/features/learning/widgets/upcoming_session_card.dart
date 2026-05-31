import 'package:flutter/material.dart';

import '../../../shared/utility/datetime_extension.dart';
import '../models/reservation_model.dart';

class UpcomingSessionCard extends StatelessWidget {
  final ReservationModel reservation;

  const UpcomingSessionCard({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    final session = reservation.session;

    return Card(
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
            Text(
              session.title,

              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 14),

            Text(session.startAt.readableDateTime),

            const SizedBox(height: 14),

            Chip(label: Text(reservation.status)),

            const Spacer(),

            if (session.isLive)
              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: () {},

                  child: const Text('Join Session'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
