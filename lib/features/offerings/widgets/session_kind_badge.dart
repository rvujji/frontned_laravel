import 'package:flutter/material.dart';

import '../../../core/enums.dart';

class SessionKindBadge extends StatelessWidget {
  final SessionKind kind;

  const SessionKindBadge({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(.08),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        kind.name.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
