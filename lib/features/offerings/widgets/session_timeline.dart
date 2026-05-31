import 'package:flutter/material.dart';

import '../models/session_model.dart';
import 'session_card.dart';

class SessionTimeline extends StatelessWidget {
  final List<SessionModel> sessions;

  const SessionTimeline({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: sessions
          .map(
            (session) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: SessionCard(session: session),
            ),
          )
          .toList(),
    );
  }
}
