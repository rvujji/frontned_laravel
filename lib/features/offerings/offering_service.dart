import '../../../core/api_client.dart';
import 'models/offering_model.dart';

class OfferingService {
  final ApiClient _apiClient = ApiClient();

  Future<List<OfferingModel>> getWorkshopOfferings(String workshopSlug) async {
    final response = await _apiClient.get(
      '/v1/public/workshops/$workshopSlug/offerings',
    );

    final data = response['data'] as List<dynamic>;

    return data.map((e) => OfferingModel.fromJson(e)).toList();
  }

  Future<OfferingModel> getOffering(String slug) async {
    final response = await _apiClient.get('/v1/public/offerings/$slug');

    final data = response['data'];

    return OfferingModel.fromJson(data);
  }

  Future<void> enroll(int offeringId) async {
    await _apiClient.post('/v1/me/offerings/$offeringId/enroll');
  }
}
