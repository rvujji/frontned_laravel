import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/auth_provider.dart';

class RouteGuard {
  static bool isAuthenticated(WidgetRef ref) {
    final authState = ref.read(authProvider);

    return authState.value != null;
  }

  static bool isAdmin(WidgetRef ref) {
    final authState = ref.read(authProvider);

    return authState.value?.isAdmin ?? false;
  }
}
