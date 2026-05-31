import '../../core/api_client.dart';
import 'progress_models.dart';

class ProgressService {
  final ApiClient _apiClient = ApiClient();

  Future<List<ProgressModel>> fetchProgress() async {
    final response = await _apiClient.get('/v1/me/offering-enrollments');

    final data = response['data'] as List<dynamic>;

    return data.map((e) => ProgressModel.fromJson(e)).toList();
  }
}
