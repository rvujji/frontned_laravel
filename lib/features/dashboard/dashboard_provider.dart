import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dashboard_models.dart';
import 'dashboard_service.dart';

final dashboardServiceProvider = Provider((ref) => DashboardService());

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final service = ref.read(dashboardServiceProvider);

  return service.fetchStats();
});

final recentEnrollmentsProvider = FutureProvider<List<RecentEnrollment>>((
  ref,
) async {
  final service = ref.read(dashboardServiceProvider);

  return service.fetchRecentEnrollments();
});

final recentWorkshopsProvider = FutureProvider<List<RecentWorkshop>>((
  ref,
) async {
  final service = ref.read(dashboardServiceProvider);

  return service.fetchRecentWorkshops();
});
