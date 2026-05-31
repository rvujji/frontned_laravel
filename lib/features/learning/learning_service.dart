import '../../../core/api_client.dart';
import 'models/learner_dashboard_model.dart';
import 'models/learning_enrollment_model.dart';
import 'models/reservation_model.dart';

class LearningService {
  final ApiClient _apiClient = ApiClient();

  Future<LearnerDashboardModel> fetchDashboard() async {
    final enrollmentsResponse = await _apiClient.get(
      '/v1/me/offering-enrollments',
    );

    final reservationsResponse = await _apiClient.get(
      '/v1/me/session-reservations',
    );

    final enrollmentsData = enrollmentsResponse['data'] as List<dynamic>;

    final reservationsData = reservationsResponse['data'] as List<dynamic>;

    return LearnerDashboardModel(
      enrollments: enrollmentsData
          .map((e) => LearningEnrollmentModel.fromJson(e))
          .toList(),

      upcomingReservations: reservationsData
          .map((e) => ReservationModel.fromJson(e))
          .toList(),
    );
  }

  Future<List<LearningEnrollmentModel>> fetchEnrollments() async {
    final response = await _apiClient.get('/v1/me/offering-enrollments');

    final data = response['data'] as List<dynamic>;

    return data.map((e) => LearningEnrollmentModel.fromJson(e)).toList();
  }

  Future<void> cancelEnrollment(int enrollmentId) async {
    await _apiClient.delete('/v1/me/offering-enrollments/$enrollmentId');
  }
}
