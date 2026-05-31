import '../../core/api_client.dart';
import 'offering_enrollment_models.dart';

class OfferingEnrollmentService {
  final ApiClient _apiClient = ApiClient();

  Future<PaginatedEnrollments> fetchEnrollments({
    int? workshopId,
    int? offeringId,
    int? studentId,
    String? completionStatus,
    String? search,
    int page = 1,
    int perPage = 15,
  }) async {
    final response = await _apiClient.get(
      '/v1/admin/offering-enrollments',
      queryParameters: {
        if (workshopId != null) 'workshop_id': workshopId,
        if (offeringId != null) 'offering_id': offeringId,
        if (studentId != null) 'student_id': studentId,
        if (completionStatus != null && completionStatus.isNotEmpty)
          'completion_status': completionStatus,
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page,
        'per_page': perPage,
      },
    );

    return PaginatedEnrollments.fromJson(
      Map<String, dynamic>.from(response['data']),
    );
  }

  Future<EnrollmentFiltersResponse> fetchFilters() async {
    final response = await _apiClient.get(
      '/v1/admin/offering-enrollments/filters',
    );

    return EnrollmentFiltersResponse.fromJson(
      Map<String, dynamic>.from(response['data']),
    );
  }

  Future<void> issueCertificate(int enrollmentId) async {
    await _apiClient.post('/v1/admin/enrollments/$enrollmentId/certificate');
  }
}
