import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'learning_service.dart';
import 'models/learner_dashboard_model.dart';
import 'models/learning_enrollment_model.dart';

final learningServiceProvider = Provider((ref) => LearningService());

final learnerDashboardProvider = FutureProvider<LearnerDashboardModel>((
  ref,
) async {
  final service = ref.read(learningServiceProvider);

  return service.fetchDashboard();
});

final myEnrollmentsProvider = FutureProvider<List<LearningEnrollmentModel>>((
  ref,
) async {
  final service = ref.read(learningServiceProvider);

  return service.fetchEnrollments();
});
