import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

      error: (error, stackTrace) {
        return const Scaffold(body: Center(child: Text('Unauthorized')));
      },

      data: (user) {
        debugPrint('USER ROLES => ${user?.roles}');
        debugPrint('IS ADMIN => ${user?.isAdmin}');
        if (user == null || !allow(user)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              if (user?.isStudent ?? false) {
                context.go('/my-enrollments');
              } else {
                context.go('/');
              }
            }
          });

          return const Scaffold(body: SizedBox());
        }

        return child;
      },
    );
  }
}
