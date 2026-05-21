import 'package:go_router/go_router.dart';

import '../features/auth/pages/login_page.dart';
import '../features/dashboard/pages/dashboard_page.dart';
import '../features/enrollments/pages/enrollments_page.dart';
import '../features/enrollments/pages/my_enrollments_page.dart';
import '../features/home/home_page.dart';
import '../features/workshop_management/workshop_management_page.dart';
import '../features/workshops/pages/workshop_detail_page.dart';
import '../features/workshops/pages/workshop_listing_page.dart';
import '../shared/navigation/protected_page.dart';
import '../shared/navigation/role_protected_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const HomePage();
      },
    ),
    GoRoute(
      path: '/workshops',
      builder: (context, state) {
        return const WorkshopListingPage();
      },
    ),
    GoRoute(
      path: '/login',

      builder: (context, state) {
        final redirect = state.uri.queryParameters['redirect'];

        return LoginPage(redirect: redirect);
      },
    ),
    GoRoute(
      path: '/dashboard',

      builder: (context, state) {
        return RoleProtectedPage(
          allow: (user) => user.isAdmin || user.isTrainer,

          child: const DashboardPage(),
        );
      },
    ),
    GoRoute(
      path: '/workshops/:slug',

      builder: (context, state) {
        final slug = state.pathParameters['slug']!;

        return WorkshopDetailPage(slug: slug);
      },
    ),
    GoRoute(
      path: '/dashboard/workshops',

      builder: (context, state) {
        return RoleProtectedPage(
          allow: (user) => user.isAdmin || user.isTrainer,
          child: const WorkshopManagementPage(),
        );
      },
    ),
    GoRoute(
      path: '/dashboard/enrollments',

      builder: (context, state) {
        return RoleProtectedPage(
          allow: (user) => user.isAdmin || user.isTrainer,
          child: const EnrollmentsPage(),
        );
      },
    ),
    GoRoute(
      path: '/my-enrollments',

      builder: (context, state) {
        return const ProtectedPage(child: MyEnrollmentsPage());
      },
    ),
  ],
);
