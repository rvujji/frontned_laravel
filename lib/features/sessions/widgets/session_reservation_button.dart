import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/auth_provider.dart';
import '../session_reservation_provider.dart';

class SessionReservationButton extends ConsumerStatefulWidget {
  final int sessionId;
  final bool bookable;

  const SessionReservationButton({
    super.key,
    required this.sessionId,
    required this.bookable,
  });

  @override
  ConsumerState<SessionReservationButton> createState() =>
      _SessionReservationButtonState();
}

class _SessionReservationButtonState
    extends ConsumerState<SessionReservationButton> {
  bool _loading = false;

  Future<void> _reserve() async {
    final user = ref.read(authProvider).valueOrNull;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first')));

      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await ref
          .read(sessionReservationProvider.notifier)
          .reserveSession(widget.sessionId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session reserved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.bookable) {
      return OutlinedButton(onPressed: null, child: const Text('Not Bookable'));
    }

    return ElevatedButton(
      onPressed: _loading ? null : _reserve,

      child: _loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Reserve Seat'),
    );
  }
}
