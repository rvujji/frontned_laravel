import '../../core/api_client.dart';
import 'certificate_models.dart';

class CertificateService {
  final ApiClient _apiClient = ApiClient();

  Future<List<CertificateModel>> fetchCertificates() async {
    final response = await _apiClient.get('/v1/me/certificates');

    final data = response['data'] as List<dynamic>;

    return data.map((e) => CertificateModel.fromJson(e)).toList();
  }
}
