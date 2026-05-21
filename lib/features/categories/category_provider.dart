import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'category_models.dart';
import 'category_service.dart';

final categoryServiceProvider = Provider((ref) => CategoryService());

final categoriesProvider = FutureProvider<List<WorkshopCategory>>((ref) async {
  final service = ref.read(categoryServiceProvider);

  return service.fetchCategories();
});
