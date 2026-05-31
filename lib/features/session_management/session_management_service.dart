import '../../core/api_client.dart';
import 'session_management_models.dart';

class SessionManagementService {
  final ApiClient _apiClient = ApiClient();

  Future<List<SessionManagementModel>> fetchSessions({
    String? search,
    int? offeringId,
    String? status,
  }) async {
    final response = await _apiClient.get(
      '/v1/admin/sessions',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,

        // Verify backend parameter name.
        // If backend expects workshop_offering_id,
        // change this back.
        if (offeringId != null) 'offering_id': offeringId,

        if (status != null && status.isNotEmpty) 'status': status,
      },
    );

    final data = response['data'];

    if (data == null) {
      return [];
    }

    if (data is! List) {
      return [];
    }

    return data
        .map(
          (e) => SessionManagementModel.fromJson(Map<String, dynamic>.from(e)),
        )
        .toList();
  }

  Future<SessionManagementModel?> getSession(int sessionId) async {
    final response = await _apiClient.get('/v1/admin/sessions/$sessionId');

    final data = response['data'];

    if (data == null) {
      return null;
    }

    return SessionManagementModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> createSession({required Map<String, dynamic> data}) async {
    await _apiClient.post('/v1/admin/sessions', data: data);
  }

  Future<void> updateSession({
    required int sessionId,
    required Map<String, dynamic> data,
  }) async {
    await _apiClient.put('/v1/admin/sessions/$sessionId', data: data);
  }

  Future<void> deleteSession(int sessionId) async {
    await _apiClient.delete('/v1/admin/sessions/$sessionId');
  }

  Future<void> updateSessionStatus({
    required int sessionId,
    required String status,
  }) async {
    await _apiClient.put(
      '/v1/admin/sessions/$sessionId',
      data: {'status': status},
    );
  }

  Future<void> publishSession(int sessionId) async {
    await updateSessionStatus(sessionId: sessionId, status: 'published');
  }

  Future<void> cancelSession(int sessionId) async {
    await updateSessionStatus(sessionId: sessionId, status: 'cancelled');
  }

  Future<void> completeSession(int sessionId) async {
    await updateSessionStatus(sessionId: sessionId, status: 'completed');
  }
}
