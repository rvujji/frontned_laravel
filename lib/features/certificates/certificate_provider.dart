import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'certificate_models.dart';
import 'certificate_service.dart';

final certificateServiceProvider = Provider((ref) => CertificateService());

final certificateProvider = FutureProvider<List<CertificateModel>>((ref) async {
  final service = ref.read(certificateServiceProvider);

  return service.fetchCertificates();
});
