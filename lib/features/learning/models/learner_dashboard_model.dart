import 'learning_enrollment_model.dart';
import 'reservation_model.dart';

class LearnerDashboardModel {
  final List<LearningEnrollmentModel> enrollments;

  final List<ReservationModel> upcomingReservations;

  LearnerDashboardModel({
    required this.enrollments,
    required this.upcomingReservations,
  });
}
