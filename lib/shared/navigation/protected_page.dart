import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_provider.dart';

class ProtectedPage extends ConsumerWidget {
  final Widget child;

  final String? redirectTo;

  const ProtectedPage({super.key, required this.child, this.redirectTo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      loading: () {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },

      error: (error, stackTrace) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.go('/login');
          }
        });

        return const SizedBox();
      },

      data: (user) {
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              final redirect = redirectTo != null
                  ? '?redirect=${Uri.encodeComponent(redirectTo!)}'
                  : '';

              context.go('/login$redirect');
            }
          });

          return const SizedBox();
        }

        return child;
      },
    );
  }
}
