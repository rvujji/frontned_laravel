import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/offering_model.dart';
import '../offering_service.dart';

final offeringServiceProvider = Provider((ref) => OfferingService());

final workshopOfferingsProvider =
    FutureProvider.family<List<OfferingModel>, String>((
      ref,
      workshopSlug,
    ) async {
      final service = ref.read(offeringServiceProvider);

      return service.getWorkshopOfferings(workshopSlug);
    });

final offeringDetailProvider = FutureProvider.family<OfferingModel, String>((
  ref,
  slug,
) async {
  final service = ref.read(offeringServiceProvider);

  return service.getOffering(slug);
});
