import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_provider.dart';

class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return AppBar(
      title: GestureDetector(
        onTap: () {
          context.go('/');
        },
        child: const Text(
          'Skill Garage',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      actions: [
        if (!isMobile) ...[
          TextButton(
            onPressed: () {
              context.go('/');
            },
            child: const Text('Home'),
          ),
          TextButton(
            onPressed: () {
              context.go('/workshops');
            },
            child: const Text('Workshops'),
          ),
          const SizedBox(width: 16),
          authState.when(
            data: (user) {
              if (user == null) {
                return ElevatedButton(
                  onPressed: () {
                    context.go(
                      '/login?redirect=${Uri.encodeComponent(GoRouterState.of(context).uri.toString())}',
                    );
                  },
                  child: const Text('Login'),
                );
              }

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(user.name),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).logout();
                    },
                    child: const Text('Logout'),
                  ),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (error, stackTrace) {
              return ElevatedButton(
                onPressed: () {
                  context.go(
                    '/login?redirect=${Uri.encodeComponent(GoRouterState.of(context).uri.toString())}',
                  );
                },
                child: const Text('Login'),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
