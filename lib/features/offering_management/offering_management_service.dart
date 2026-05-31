import '../../core/api_client.dart';
import 'offering_management_models.dart';

class OfferingManagementService {
  final ApiClient _apiClient = ApiClient();

  Future<List<AdminOffering>> fetchOfferings() async {
    final response = await _apiClient.get('/v1/admin/offerings');

    final data = response['data'] as List<dynamic>;

    return data.map((e) => AdminOffering.fromJson(e)).toList();
  }

  Future<void> createOffering({required Map<String, dynamic> data}) async {
    await _apiClient.post('/v1/admin/offerings', data: data);
  }

  Future<void> updateOffering({
    required int offeringId,
    required Map<String, dynamic> data,
  }) async {
    await _apiClient.put('/v1/admin/offerings/$offeringId', data: data);
  }

  Future<void> deleteOffering(int offeringId) async {
    await _apiClient.delete('/v1/admin/offerings/$offeringId');
  }

  Future<List<AdminSession>> fetchSessions(int offeringId) async {
    final response = await _apiClient.get(
      '/v1/admin/offerings/$offeringId/sessions',
    );

    final data = response['data'] as List<dynamic>;

    return data.map((e) => AdminSession.fromJson(e)).toList();
  }

  Future<void> createSession({
    required int offeringId,
    required Map<String, dynamic> data,
  }) async {
    await _apiClient.post(
      '/v1/admin/offerings/$offeringId/sessions',
      data: data,
    );
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

  Future<List<OfferingWorkshop>> fetchWorkshops() async {
    final response = await _apiClient.get('/v1/workshops');

    final data = response['data']['data'] as List<dynamic>;

    return data.map((e) => OfferingWorkshop.fromJson(e)).toList();
  }
}
