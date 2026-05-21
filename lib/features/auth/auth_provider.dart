import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage.dart';
import 'auth_models.dart';
import 'auth_service.dart';

final authServiceProvider = Provider((ref) => AuthService());

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final token = await AppStorage.getToken();

    if (token == null) {
      return null;
    }

    try {
      final service = ref.read(authServiceProvider);

      return await service.me();
    } catch (_) {
      return null;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = const AsyncLoading();

    try {
      final service = ref.read(authServiceProvider);

      final response = await service.login(email: email, password: password);

      state = AsyncData(response.user);
      return true;
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      return false;
    }
  }

  Future<void> logout() async {
    final service = ref.read(authServiceProvider);

    await service.logout();

    state = const AsyncData(null);
  }
}
