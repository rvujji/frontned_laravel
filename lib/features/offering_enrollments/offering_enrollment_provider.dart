import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'offering_enrollment_models.dart';
import 'offering_enrollment_service.dart';

final offeringEnrollmentServiceProvider = Provider(
  (ref) => OfferingEnrollmentService(),
);

final offeringEnrollmentProvider =
    FutureProvider<List<OfferingEnrollmentModel>>((ref) async {
      final service = ref.read(offeringEnrollmentServiceProvider);

      return service.fetchEnrollments();
    });

final offeringEnrollmentSearchProvider = StateProvider<String>((ref) => '');
