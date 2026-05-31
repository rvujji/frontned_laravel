import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'progress_models.dart';
import 'progress_service.dart';

final progressServiceProvider = Provider((ref) => ProgressService());

final progressProvider = FutureProvider<List<ProgressModel>>((ref) async {
  final service = ref.read(progressServiceProvider);

  return service.fetchProgress();
});
