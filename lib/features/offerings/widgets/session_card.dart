import 'package:flutter/material.dart';

import '../../../shared/utility/datetime_extension.dart';
import '../../sessions/widgets/session_reservation_button.dart';
import '../models/session_model.dart';
import 'delivery_mode_badge.dart';
import 'session_kind_badge.dart';

class SessionCard extends StatelessWidget {
  final SessionModel session;

  const SessionCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),

        side: BorderSide(color: Colors.grey.shade300),
      ),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                SessionKindBadge(kind: session.sessionKind),

                const SizedBox(width: 10),

                DeliveryModeBadge(mode: session.deliveryMode),

                const Spacer(),

                _StatusBadge(session: session),
              ],
            ),

            const SizedBox(height: 18),

            Text(
              session.title,

              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.schedule, size: 18),

                const SizedBox(width: 8),

                Expanded(child: Text(session.startAt.rangeTo(session.endAt))),
              ],
            ),

            if (session.venueName != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),

                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 18),

                    const SizedBox(width: 8),

                    Expanded(child: Text(session.venueName!)),
                  ],
                ),
              ),

            if (session.agendaSummary != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),

                child: Text(
                  session.agendaSummary!,
                  style: TextStyle(height: 1.5, color: Colors.grey.shade700),
                ),
              ),

            const SizedBox(height: 20),

            Wrap(
              spacing: 12,
              runSpacing: 12,

              children: [
                if (session.durationMinutes != null)
                  Chip(label: Text('${session.durationMinutes} mins')),

                if (session.attendanceRequired)
                  const Chip(label: Text('Attendance Required')),

                if (session.waitlistEnabled)
                  const Chip(label: Text('Waitlist Enabled')),
              ],
            ),

            const SizedBox(height: 24),

            SessionReservationButton(
              sessionId: session.id,
              bookable: session.bookable,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final SessionModel session;

  const _StatusBadge({required this.session});

  @override
  Widget build(BuildContext context) {
    String label;

    Color color;

    if (session.isLive) {
      label = 'LIVE';
      color = Colors.red;
    } else if (session.isCompleted) {
      label = 'COMPLETED';
      color = Colors.green;
    } else if (session.isUpcoming) {
      label = 'UPCOMING';
      color = Colors.blue;
    } else {
      label = session.status.name.toUpperCase();

      color = Colors.grey;
    }

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
