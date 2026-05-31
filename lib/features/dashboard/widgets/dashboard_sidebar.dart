import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/auth_provider.dart';

class DashboardSidebar extends ConsumerWidget {
  const DashboardSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.value;
    final canManageWorkshops = user?.can('workshop:read') ?? false;

    final canManageOfferings = user?.can('offering:read') ?? false;

    final canManageSessions = user?.can('session:read') ?? false;

    final canManageEnrollments = user?.can('enrollment:read') ?? false;

    final canManageAttendance = user?.can('attendance:read') ?? false;

    return Container(
      color: Colors.indigo.shade700,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Skill Garage',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _SidebarItem(
              title: 'Dashboard',
              icon: Icons.dashboard,
              onTap: () {
                context.go('/dashboard');
              },
            ),
            if (canManageWorkshops)
              _SidebarItem(
                title: 'Workshops',
                icon: Icons.school,
                onTap: () {
                  context.go('/dashboard/workshops');
                },
              ),
            if (canManageOfferings)
              _SidebarItem(
                title: 'Offerings',
                icon: Icons.event_note,
                onTap: () {
                  context.go('/dashboard/offerings');
                },
              ),
            if (canManageSessions)
              _SidebarItem(
                title: 'Sessions',
                icon: Icons.schedule,
                onTap: () {
                  context.go('/dashboard/sessions');
                },
              ),
            if (canManageEnrollments)
              _SidebarItem(
                title: 'Enrollments',
                icon: Icons.people,
                onTap: () {
                  context.go('/dashboard/offering-enrollments');
                },
              ),
            if (canManageAttendance)
              _SidebarItem(
                title: 'Attendance',
                icon: Icons.fact_check,
                onTap: () {
                  context.go('/dashboard/attendance');
                },
              ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white24,
                          child: Text(
                            user != null && user.name.isNotEmpty
                                ? user.name.substring(0, 1).toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await ref.read(authProvider.notifier).logout();

                          if (context.mounted) {
                            context.go('/');
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}
