import '../../core/api_client.dart';
import '../../core/api_response.dart';
import 'category_models.dart';

class CategoryService {
  final ApiClient _apiClient = ApiClient();

  Future<List<WorkshopCategory>> fetchCategories() async {
    final response = await _apiClient.get('/v1/public/categories');

    final apiResponse = ApiResponse.fromJson(response, (data) {
      return (data as List)
          .map((item) => WorkshopCategory.fromJson(item))
          .toList();
    });

    return apiResponse.data;
  }
}
