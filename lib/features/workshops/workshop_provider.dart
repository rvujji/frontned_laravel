import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontned_laravel/features/workshops/workshop_pagination.dart';

import 'workshop_models.dart';
import 'workshop_service.dart';

final workshopServiceProvider = Provider((ref) => WorkshopService());
final searchProvider = StateProvider<String>((ref) => '');

final selectedCategoryProvider = StateProvider<int?>((ref) => null);
final workshopsProvider = FutureProvider<WorkshopPagination>((ref) async {
  final service = ref.read(workshopServiceProvider);

  final search = ref.watch(searchProvider);

  final categoryId = ref.watch(selectedCategoryProvider);

  return service.fetchWorkshops(search: search, categoryId: categoryId);
});

final workshopDetailProvider = FutureProvider.family<Workshop, String>((
  ref,
  slug,
) async {
  final service = ref.read(workshopServiceProvider);

  return service.fetchWorkshopDetail(slug);
});
final currentPageProvider = StateProvider<int>((ref) => 1);
