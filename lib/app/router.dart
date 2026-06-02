import 'package:go_router/go_router.dart';

import '../features/attendance/attendance_management_page.dart';
import '../features/attendance/learner_attendance_page.dart';
import '../features/auth/pages/forgot_password_page.dart';
import '../features/auth/pages/login_page.dart';
import '../features/auth/pages/register_page.dart';
import '../features/auth/pages/reset_password_page.dart';
import '../features/auth/pages/verify_email_page.dart';
import '../features/certificates/certificates_page.dart';
import '../features/dashboard/pages/dashboard_page.dart';
import '../features/home/home_page.dart';
import '../features/learning/pages/learning_detail_page.dart';
import '../features/learning/pages/my_learning_page.dart';
import '../features/offering_enrollments/email_verification_required_page.dart';
import '../features/offering_enrollments/offering_enrollment_page.dart';
import '../features/offering_management/offering_management_page.dart';
import '../features/offerings/pages/offering_detail_page.dart';
import '../features/progress/learner_progress_page.dart';
import '../features/schedule/schedule_page.dart';
import '../features/session_management/session_management_page.dart';
import '../features/workshop_management/workshop_management_page.dart';
import '../features/workshops/pages/workshop_detail_page.dart';
import '../features/workshops/pages/workshop_listing_page.dart';
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
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),

    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),

    GoRoute(
      path: '/reset-password',
      builder: (context, state) {
        final token = state.uri.queryParameters['token'] ?? '';

        final email = state.uri.queryParameters['email'] ?? '';

        return ResetPasswordPage(token: token, email: email);
      },
    ),

    GoRoute(
      path: '/verification-required',
      builder: (context, state) {
        return const EmailVerificationRequiredPage(returnToPreviousPage: true);
      },
    ),

    GoRoute(
      path: '/verify-email',
      builder: (context, state) {
        final params = state.uri.queryParameters;

        return VerifyEmailPage(
          id: params['id'] ?? '',
          hash: params['hash'] ?? '',
          expires: params['expires'] ?? '',
          signature: params['signature'] ?? '',
        );
      },
    ),

    GoRoute(
      path: '/workshops',

      builder: (context, state) {
        return const WorkshopListingPage();
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
      path: '/learning/:id',

      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);

        return LearningDetailPage(enrollmentId: id);
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
      path: '/offerings/:slug',

      builder: (context, state) {
        final slug = state.pathParameters['slug']!;

        return OfferingDetailPage(slug: slug);
      },
    ),

    GoRoute(
      path: '/my-learning',

      builder: (context, state) {
        return const MyLearningPage();
      },
    ),

    GoRoute(
      path: '/certificates',

      builder: (context, state) {
        return const CertificatesPage();
      },
    ),

    GoRoute(
      path: '/schedule',

      builder: (context, state) {
        return const SchedulePage();
      },
    ),

    GoRoute(
      path: '/attendance',

      builder: (context, state) {
        return const LearnerAttendancePage();
      },
    ),

    GoRoute(
      path: '/dashboard/attendance',

      builder: (context, state) {
        return const AttendanceManagementPage();
      },
    ),

    GoRoute(
      path: '/progress',

      builder: (context, state) {
        return const LearnerProgressPage();
      },
    ),
    GoRoute(
      path: '/dashboard/offering-enrollments',

      builder: (context, state) {
        return const AdminOfferingEnrollmentPage();
      },
    ),

    GoRoute(
      path: '/dashboard/sessions',
      builder: (context, state) {
        return RoleProtectedPage(
          allow: (user) => user.isAdmin || user.isTrainer,
          child: const SessionManagementPage(),
        );
      },
    ),
    GoRoute(
      path: '/dashboard/offerings',
      builder: (context, state) {
        return RoleProtectedPage(
          allow: (user) => user.isAdmin || user.isTrainer,
          child: const OfferingManagementPage(),
        );
      },
    ),
  ],
);
