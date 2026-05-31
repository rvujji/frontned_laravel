import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../offering_management/offering_management_models.dart';
import '../offering_management/offering_management_service.dart';
import 'session_management_models.dart';
import 'session_management_service.dart';

final sessionManagementServiceProvider = Provider<SessionManagementService>(
  (ref) => SessionManagementService(),
);

final offeringManagementServiceProvider = Provider<OfferingManagementService>(
  (ref) => OfferingManagementService(),
);

class SessionFilters {
  final String search;

  final int? workshopId;

  final int? offeringId;

  final String? status;

  const SessionFilters({
    this.search = '',
    this.workshopId,
    this.offeringId,
    this.status,
  });

  SessionFilters copyWith({
    String? search,
    int? workshopId,
    int? offeringId,
    String? status,
  }) {
    return SessionFilters(
      search: search ?? this.search,
      workshopId: workshopId ?? this.workshopId,
      offeringId: offeringId ?? this.offeringId,
      status: status ?? this.status,
    );
  }
}

final sessionFiltersProvider = StateProvider<SessionFilters>(
  (ref) => const SessionFilters(),
);

final sessionsProvider = FutureProvider<List<SessionManagementModel>>((
  ref,
) async {
  final service = ref.read(sessionManagementServiceProvider);

  final filters = ref.watch(sessionFiltersProvider);

  final sessions = await service.fetchSessions(
    search: filters.search,
    offeringId: filters.offeringId,
    status: filters.status,
  );

  return sessions.where((session) {
    if (filters.workshopId != null &&
        session.workshopId != filters.workshopId) {
      return false;
    }

    return true;
  }).toList();
});

final offeringsProvider = FutureProvider<List<AdminOffering>>((ref) async {
  final service = ref.read(offeringManagementServiceProvider);

  return service.fetchOfferings();
});

final workshopsProvider = FutureProvider<List<OfferingWorkshop>>((ref) async {
  final service = ref.read(offeringManagementServiceProvider);

  return service.fetchWorkshops();
});
