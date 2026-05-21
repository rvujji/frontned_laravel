import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_provider.dart';

class ProtectedPage extends ConsumerWidget {
  final Widget child;

  const ProtectedPage({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      loading: () {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },

      error: (_, __) {
        Future.microtask(() {
          context.go('/login');
        });

        return const SizedBox();
      },

      data: (user) {
        if (user == null) {
          Future.microtask(() {
            context.go(
              '/login?redirect=${Uri.encodeComponent(GoRouterState.of(context).uri.toString())}',
            );
          });

          return const SizedBox();
        }

        return child;
      },
    );
  }
}
