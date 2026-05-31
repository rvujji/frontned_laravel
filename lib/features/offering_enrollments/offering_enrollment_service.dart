import '../../core/api_client.dart';
import 'offering_enrollment_models.dart';

class OfferingEnrollmentService {
  final ApiClient _apiClient = ApiClient();

  Future<List<OfferingEnrollmentModel>> fetchEnrollments() async {
    final response = await _apiClient.get('/v1/admin/offering-enrollments');

    final data = response['data'] as List<dynamic>;

    return data.map((e) => OfferingEnrollmentModel.fromJson(e)).toList();
  }

  Future<void> issueCertificate(int enrollmentId) async {
    await _apiClient.post('/v1/admin/enrollments/$enrollmentId/certificate');
  }
}
