import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/api_response.dart';
import 'workshop_models.dart';
import 'workshop_pagination.dart';

final workshopServiceProvider = Provider((ref) => WorkshopService());

class WorkshopService {
  final ApiClient _apiClient = ApiClient();

  Future<WorkshopPagination> fetchWorkshops({
    String? search,
    int? categoryId,
    int page = 1,
  }) async {
    final response = await _apiClient.get(
      '/v1/public/workshops',

      queryParameters: {
        'page': page,

        if (search != null && search.isNotEmpty) 'search': search,

        if (categoryId != null) 'category_id': categoryId,
      },
    );

    final apiResponse = ApiResponse.fromJson(response, (data) {
      return WorkshopPagination.fromJson(data);
    });

    return apiResponse.data;
  }

  Future<Workshop> fetchWorkshopDetail(String slug) async {
    final response = await _apiClient.get('/v1/public/workshops/$slug');

    final apiResponse = ApiResponse.fromJson(
      response,
      (data) => Workshop.fromJson(data),
    );

    return apiResponse.data;
  }

  Future<Workshop> fetchWorkshopBySlug(String slug) async {
    final response = await _apiClient.get('/v1/public/workshops/$slug');

    final apiResponse = ApiResponse.fromJson(
      response,
      (data) => Workshop.fromJson(data),
    );

    return apiResponse.data;
  }

  Future<void> enrollWorkshop(int workshopId) async {
    await _apiClient.post('/v1/enrollments', data: {'workshop_id': workshopId});
  }
}
