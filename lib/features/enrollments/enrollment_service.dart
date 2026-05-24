import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/paginated_response.dart';
import '../../core/api_client.dart';
import '../../core/api_response.dart';
import 'enrollment_models.dart';

final enrollmentServiceProvider = Provider((ref) => EnrollmentService());

class EnrollmentService {
  final ApiClient _apiClient = ApiClient();

  Future<PaginatedResponse<Enrollment>> fetchEnrollments({
    int page = 1,

    String? search,

    String? status,
  }) async {
    final response = await _apiClient.get(
      '/v1/admin/enrollments',

      queryParameters: {
        'page': page,

        if (search != null && search.isNotEmpty) 'search': search,

        if (status != null && status.isNotEmpty) 'status': status,
      },
    );

    final data = response['data'];

    final items = (data['data'] as List)
        .map((e) => Enrollment.fromJson(e))
        .toList();

    return PaginatedResponse<Enrollment>(
      items: items,

      currentPage: data['current_page'],

      lastPage: data['last_page'],

      total: data['total'],
    );
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
