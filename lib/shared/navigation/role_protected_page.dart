import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_provider.dart';

class RoleProtectedPage extends ConsumerWidget {
  final Widget child;

  final bool Function(dynamic user) allow;

  const RoleProtectedPage({
    super.key,
    required this.child,
    required this.allow,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      loading: () {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },

      error: (_, __) {
        return const Scaffold(body: Center(child: Text('Unauthorized')));
      },

      data: (user) {
        if (user == null || !allow(user)) {
          return const Scaffold(body: Center(child: Text('Access denied')));
        }

        return child;
      },
    );
  }
}
