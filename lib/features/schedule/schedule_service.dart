import '../../core/api_client.dart';
import 'schedule_models.dart';

class ScheduleService {
  final ApiClient _apiClient = ApiClient();

  Future<List<ScheduledSession>> fetchSchedule() async {
    final response = await _apiClient.get('/v1/me/schedule');

    final data = response['data'] as List<dynamic>;

    return data.map((e) => ScheduledSession.fromJson(e)).toList();
  }
}
