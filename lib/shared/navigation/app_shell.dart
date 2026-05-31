import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_provider.dart';
import 'app_footer.dart';
import 'mobile_drawer.dart';

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final authState = ref.watch(authProvider);
    final user = authState.value;
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () {
            context.go('/');
          },

          child: const Text('Skill Garage'),
        ),

        actions: [
          TextButton(
            onPressed: () {
              context.go('/workshops');
            },

            child: const Text('Workshops'),
          ),

          if (user != null)
            TextButton(
              onPressed: () {
                context.go('/my-learning');
              },

              child: const Text('My Learning'),
            ),

          const SizedBox(width: 12),

          if (user == null)
            ElevatedButton(
              onPressed: () {
                context.go('/login');
              },

              child: const Text('Login'),
            )
          else
            Row(
              children: [
                CircleAvatar(
                  radius: 16,

                  child: Text(user.name.substring(0, 1).toUpperCase()),
                ),

                const SizedBox(width: 12),

                Text(user.name),

                if (user != null && (user.isAdmin || user.isTrainer))
                  TextButton(
                    onPressed: () {
                      context.go('/dashboard');
                    },

                    child: const Text('Dashboard'),
                  ),
                const SizedBox(width: 12),

                TextButton(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();

                    if (context.mounted) {
                      context.go('/');
                    }
                  },

                  child: const Text('Logout'),
                ),

                const SizedBox(width: 16),
              ],
            ),
        ],
      ),

      drawer: isMobile ? const MobileDrawer() : null,

      body: Column(
        children: [
          Expanded(child: child),

          const AppFooter(),
        ],
      ),
    );
  }
}
