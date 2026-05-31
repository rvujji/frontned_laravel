import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_reservation_service.dart';

final sessionReservationServiceProvider = Provider(
  (ref) => SessionReservationService(),
);

final sessionReservationProvider =
    StateNotifierProvider<SessionReservationNotifier, AsyncValue<void>>(
      (ref) => SessionReservationNotifier(ref),
    );

class SessionReservationNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  SessionReservationNotifier(this.ref) : super(const AsyncData(null));

  Future<void> reserveSession(int sessionId) async {
    state = const AsyncLoading();

    try {
      final service = ref.read(sessionReservationServiceProvider);

      await service.reserveSession(sessionId);

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
