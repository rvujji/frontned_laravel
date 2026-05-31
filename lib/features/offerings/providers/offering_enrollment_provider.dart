import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'offering_provider.dart';

final offeringEnrollmentProvider =
    StateNotifierProvider<OfferingEnrollmentNotifier, AsyncValue<void>>(
      (ref) => OfferingEnrollmentNotifier(ref),
    );

class OfferingEnrollmentNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  OfferingEnrollmentNotifier(this.ref) : super(const AsyncData(null));

  Future<void> enroll(int offeringId) async {
    state = const AsyncLoading();

    try {
      final service = ref.read(offeringServiceProvider);

      await service.enroll(offeringId);

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
