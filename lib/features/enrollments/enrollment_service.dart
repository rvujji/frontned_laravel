import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/api_response.dart';
import 'enrollment_models.dart';

final enrollmentServiceProvider = Provider((ref) => EnrollmentService());

class EnrollmentService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Enrollment>> fetchEnrollments() async {
    final response = await _apiClient.get('/v1/enrollments');

    final apiResponse = ApiResponse.fromJson(response, (data) {
      final items = data['data'] as List;

      return items.map((item) => Enrollment.fromJson(item)).toList();
    });

    return apiResponse.data;
  }

  Future<void> cancelEnrollment(int id) async {
    await _apiClient.delete('/v1/enrollments/$id');
  }

  Future<List<Enrollment>> fetchMyEnrollments() async {
    final response = await _apiClient.get('/v1/me/enrollments');

    final apiResponse = ApiResponse.fromJson(response, (data) {
      final items = data['data'] as List;

      return items.map((item) => Enrollment.fromJson(item)).toList();
    });

    return apiResponse.data;
  }
}
