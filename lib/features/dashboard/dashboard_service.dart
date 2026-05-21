import '../../core/api_client.dart';
import '../../core/api_response.dart';
import 'dashboard_models.dart';

class DashboardService {
  final ApiClient _apiClient = ApiClient();

  Future<DashboardStats> fetchStats() async {
    final response = await _apiClient.get('/v1/dashboard/stats');

    final apiResponse = ApiResponse.fromJson(
      response,
      (data) => DashboardStats.fromJson(data),
    );

    return apiResponse.data;
  }

  Future<List<RecentEnrollment>> fetchRecentEnrollments() async {
    final response = await _apiClient.get('/v1/dashboard/recent-enrollments');

    final apiResponse = ApiResponse.fromJson(response, (data) {
      return (data as List)
          .map((item) => RecentEnrollment.fromJson(item))
          .toList();
    });

    return apiResponse.data;
  }

  Future<List<RecentWorkshop>> fetchRecentWorkshops() async {
    final response = await _apiClient.get('/v1/dashboard/recent-workshops');

    final apiResponse = ApiResponse.fromJson(response, (data) {
      return (data as List)
          .map((item) => RecentWorkshop.fromJson(item))
          .toList();
    });

    return apiResponse.data;
  }
}
