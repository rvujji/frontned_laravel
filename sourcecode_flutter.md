## File: lib\main.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_strategy/url_strategy.dart';

import 'app/app.dart';
import 'core/app_provider_observer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  setPathUrlStrategy();

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('UNCAUGHT ERROR => $error');

    debugPrintStack(stackTrace: stack);

    return true;
  };

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);

    debugPrint(
      'FLUTTER ERROR => '
      '${details.exception}',
    );

    debugPrintStack(stackTrace: details.stack);
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.white,

      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Text('''
${details.exception}

${details.stack}
'''),
      ),
    );
  };

  runApp(ProviderScope(observers: [AppProviderObserver()], child: MyApp()));
}

---
## File: lib\app\app.dart
import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Skill Garage',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}

---
## File: lib\app\router.dart
import 'package:go_router/go_router.dart';

import '../features/attendance/attendance_management_page.dart';
import '../features/attendance/learner_attendance_page.dart';
import '../features/auth/pages/login_page.dart';
import '../features/certificates/certificates_page.dart';
import '../features/dashboard/pages/dashboard_page.dart';
import '../features/home/home_page.dart';
import '../features/learning/pages/learning_detail_page.dart';
import '../features/learning/pages/my_learning_page.dart';
import '../features/offering_enrollments/offering_enrollment_page.dart';
import '../features/offering_management/session_management_page.dart';
import '../features/offerings/pages/offering_detail_page.dart';
import '../features/progress/learner_progress_page.dart';
import '../features/schedule/schedule_page.dart';
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
      builder: (_, __) => const SessionManagementPage(),
    ),
  ],
);

---
## File: lib\app\route_guard.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/auth_provider.dart';

class RouteGuard {
  static bool isAuthenticated(WidgetRef ref) {
    final authState = ref.read(authProvider);

    return authState.value != null;
  }

  static bool isAdmin(WidgetRef ref) {
    final authState = ref.read(authProvider);

    return authState.value?.isAdmin ?? false;
  }
}

---
## File: lib\app\theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),

      scaffoldBackgroundColor: Colors.grey.shade100,

      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),

      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

---
## File: lib\core\api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import 'app_exception.dart';
import 'constants.dart';
import 'storage.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),

        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _initializeInterceptors();
  }

  void _initializeInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await AppStorage.getToken();

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          print('REQUEST => ${options.method} ${options.path}');
          print('DATA => ${options.data}');

          handler.next(options);
        },

        onResponse: (response, handler) {
          print('RESPONSE => ${response.statusCode}');
          print('BODY => ${response.data}');

          handler.next(response);
        },

        onError: (e, handler) {
          debugPrint(
            'REQUEST => ${e.requestOptions.method} '
            '${e.requestOptions.path}',
          );

          debugPrint('DATA => ${e.requestOptions.data}');

          debugPrint('ERROR => ${e.response?.statusCode}');

          debugPrint('MESSAGE => ${e.message}');

          if (e.response?.data != null) {
            debugPrint('RESPONSE DATA => ${e.response?.data}');
          }

          debugPrintStack(stackTrace: e.stackTrace);

          handler.next(e);
        },
      ),
    );
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> patch(String path, {dynamic data}) async {
    try {
      final response = await _dio.patch(path, data: data);

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final response = await _dio.delete(path);

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  AppException _handleError(DioException error) {
    final statusCode = error.response?.statusCode;

    switch (statusCode) {
      case 401:
        return UnauthorizedException('Unauthorized');

      case 422:
        return ValidationException('Validation failed');

      case 500:
        return ServerException('Server error');

      default:
        return NetworkException(error.message ?? 'Something went wrong');
    }
  }
}

---
## File: lib\core\api_response.dart
class ApiResponse<T> {
  final bool success;
  final String message;
  final T data;

  ApiResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic data) fromData,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: fromData(json['data']),
    );
  }
}

---
## File: lib\core\app_exception.dart
class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(super.message);
}

class UnauthorizedException extends AppException {
  UnauthorizedException(super.message);
}

class ValidationException extends AppException {
  ValidationException(super.message);
}

class ServerException extends AppException {
  ServerException(super.message);
}

---
## File: lib\core\app_provider_observer.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    debugPrint('''
PROVIDER UPDATED
${provider.name ?? provider.runtimeType}

NEW VALUE:
$newValue
''');
  }

  @override
  void providerDidFail(
    ProviderBase provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    debugPrint('''
PROVIDER FAILED
${provider.name ?? provider.runtimeType}

ERROR:
$error
''');

    debugPrintStack(stackTrace: stackTrace);
  }
}

---
## File: lib\core\constants.dart
class AppConstants {
  static const String baseUrl = 'http://localhost:8000/api';
}

---
## File: lib\core\enums.dart
enum DeliveryMode { physical, virtual, hybrid }

enum EnrollmentType {
  full_series,
  session_selection,
  drop_in,
  subscription_access,
}

enum OfferingStatus {
  draft,
  published,
  ongoing,
  completed,
  cancelled,
  archived,
}

enum SessionKind {
  instruction,
  lab,
  project,
  assessment,
  orientation,
  qa,
  demo,
  mentoring,
}

enum SessionStatus { draft, scheduled, live, completed, cancelled, archived }

enum EnrollmentStatus { active, cancelled, completed, suspended }

enum PaymentStatus { unpaid, pending, paid, failed, refunded }

enum CompletionStatus { not_started, in_progress, completed, failed }

enum AttendanceStatus { present, absent, late, partial, excused }

enum CapacityMode { offering_only, session_only, both }

enum CompletionRule {
  attend_all_required,
  attend_n_sessions,
  attendance_percentage,
  manual_completion,
}

enum SessionSelectionRule {
  all_sessions,
  any_n_of_m,
  specific_track_only,
  optional_sessions,
}

enum SessionReservationStatus { reserved, waitlisted, cancelled, attended }

---
## File: lib\core\storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  static const _tokenKey = 'auth_token';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
  }
}

---
## File: lib\features\attendance\attendance_management_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums.dart';
import '../../shared/utility/datetime_extension.dart';
import '../dashboard/widgets/dashboard_shell.dart';
import 'attendance_provider.dart';
import 'attendance_status_badge.dart';

class AttendanceManagementPage extends ConsumerWidget {
  const AttendanceManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(attendanceManagementProvider);

    final notifier = ref.read(attendanceManagementProvider.notifier);

    final filters = notifier.filters;

    return DashboardShell(
      title: 'Attendance',

      child: attendanceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, _) => Center(child: Text(error.toString())),

        data: (attendances) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),

                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: notifier.selectedWorkshopId,

                        decoration: const InputDecoration(
                          labelText: 'Workshop',
                        ),

                        items:
                            filters?.workshops.map((e) {
                              return DropdownMenuItem<int>(
                                value: e['id'],

                                child: Text(e['title']),
                              );
                            }).toList() ??
                            [],

                        onChanged: notifier.selectWorkshop,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: notifier.selectedOfferingId,

                        decoration: const InputDecoration(
                          labelText: 'Offering',
                        ),

                        items:
                            filters?.offerings.map((e) {
                              return DropdownMenuItem<int>(
                                value: e['id'],

                                child: Text(e['title']),
                              );
                            }).toList() ??
                            [],

                        onChanged: notifier.selectOffering,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: notifier.selectedSessionId,

                        decoration: const InputDecoration(labelText: 'Session'),

                        items:
                            filters?.sessions.map((e) {
                              return DropdownMenuItem<int>(
                                value: e['id'],

                                child: Text(e['title']),
                              );
                            }).toList() ??
                            [],

                        onChanged: notifier.selectSession,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),

                  itemCount: attendances.length,

                  itemBuilder: (context, index) {
                    final attendance = attendances[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),

                      child: Padding(
                        padding: const EdgeInsets.all(20),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              attendance.student.name,

                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(attendance.student.email),

                            const SizedBox(height: 16),

                            Text(attendance.workshop.title),

                            Text(attendance.offering.title),

                            Text(attendance.session.title),

                            const SizedBox(height: 8),

                            Text(
                              attendance.session.startAt?.readableDateTime ??
                                  '',
                            ),

                            const SizedBox(height: 16),

                            Row(
                              children: [
                                AttendanceStatusBadge(
                                  status: attendance.attendanceStatus,
                                ),

                                const SizedBox(width: 16),

                                Expanded(
                                  child:
                                      DropdownButtonFormField<AttendanceStatus>(
                                        value: attendance.attendanceStatus,

                                        items: AttendanceStatus.values.map((
                                          status,
                                        ) {
                                          return DropdownMenuItem(
                                            value: status,

                                            child: Text(status.name),
                                          );
                                        }).toList(),

                                        onChanged: (value) async {
                                          if (value == null) {
                                            return;
                                          }

                                          await notifier.updateAttendance(
                                            attendanceId: attendance.id,

                                            status: value,
                                          );
                                        },
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

---
## File: lib\features\attendance\attendance_models.dart
import '../../core/enums.dart';
import '../../shared/utility/enum_extension.dart';
import '../../shared/utility/json_utils.dart';

class AttendanceStudent {
  final String id;
  final String name;
  final String email;

  AttendanceStudent({
    required this.id,
    required this.name,
    required this.email,
  });

  factory AttendanceStudent.fromJson(Map<String, dynamic> json) {
    return AttendanceStudent(
      id: json['id'].toString(),
      name: JsonUtils.parseString(json['name']),
      email: JsonUtils.parseString(json['email']),
    );
  }
}

class AttendanceWorkshop {
  final String id;
  final String title;

  AttendanceWorkshop({required this.id, required this.title});

  factory AttendanceWorkshop.fromJson(Map<String, dynamic> json) {
    return AttendanceWorkshop(
      id: json['id'].toString(),
      title: JsonUtils.parseString(json['title']),
    );
  }
}

class AttendanceOffering {
  final String id;
  final String title;

  AttendanceOffering({required this.id, required this.title});

  factory AttendanceOffering.fromJson(Map<String, dynamic> json) {
    return AttendanceOffering(
      id: json['id'].toString(),
      title: JsonUtils.parseString(json['title']),
    );
  }
}

class AttendanceSession {
  final String id;
  final String title;
  final String? startAt;

  AttendanceSession({
    required this.id,
    required this.title,
    required this.startAt,
  });

  factory AttendanceSession.fromJson(Map<String, dynamic> json) {
    return AttendanceSession(
      id: json['id'].toString(),
      title: JsonUtils.parseString(json['title']),
      startAt: json['start_at']?.toString(),
    );
  }
}

class AttendanceModel {
  final int id;

  final int reservationId;

  final AttendanceStatus attendanceStatus;

  final AttendanceStudent student;

  final AttendanceWorkshop workshop;

  final AttendanceOffering offering;

  final AttendanceSession session;

  AttendanceModel({
    required this.id,
    required this.reservationId,
    required this.attendanceStatus,
    required this.student,
    required this.workshop,
    required this.offering,
    required this.session,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: JsonUtils.parseInt(json['id']) ?? 0,

      reservationId: JsonUtils.parseInt(json['reservation_id']) ?? 0,

      attendanceStatus:
          AttendanceStatus.values.byNameOrNull(json['status']) ??
          AttendanceStatus.partial,

      student: AttendanceStudent.fromJson(json['student'] ?? {}),

      workshop: AttendanceWorkshop.fromJson(json['workshop'] ?? {}),

      offering: AttendanceOffering.fromJson(json['offering'] ?? {}),

      session: AttendanceSession.fromJson(json['session'] ?? {}),
    );
  }

  AttendanceModel copyWith({AttendanceStatus? attendanceStatus}) {
    return AttendanceModel(
      id: id,
      reservationId: reservationId,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      student: student,
      workshop: workshop,
      offering: offering,
      session: session,
    );
  }
}

class AttendanceFiltersResponse {
  final List<dynamic> workshops;

  final List<dynamic> offerings;

  final List<dynamic> sessions;

  AttendanceFiltersResponse({
    required this.workshops,
    required this.offerings,
    required this.sessions,
  });

  factory AttendanceFiltersResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return AttendanceFiltersResponse(
      workshops: data['workshops'] ?? [],
      offerings: data['offerings'] ?? [],
      sessions: data['sessions'] ?? [],
    );
  }
}

---
## File: lib\features\attendance\attendance_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums.dart';
import 'attendance_models.dart';
import 'attendance_service.dart';

final attendanceServiceProvider = Provider((ref) => AttendanceService());

final learnerAttendanceProvider = FutureProvider<List<AttendanceModel>>((
  ref,
) async {
  final service = ref.read(attendanceServiceProvider);

  return service.fetchMyAttendances();
});

final attendanceManagementProvider =
    AsyncNotifierProvider<AttendanceManagementNotifier, List<AttendanceModel>>(
      AttendanceManagementNotifier.new,
    );

class AttendanceManagementNotifier
    extends AsyncNotifier<List<AttendanceModel>> {
  late final AttendanceService _service;

  AttendanceFiltersResponse? filters;

  int? selectedWorkshopId;

  int? selectedOfferingId;

  int? selectedSessionId;

  @override
  Future<List<AttendanceModel>> build() async {
    _service = ref.read(attendanceServiceProvider);

    filters = await _service.fetchFilters();

    return _loadAttendances();
  }

  Future<List<AttendanceModel>> _loadAttendances() async {
    return _service.fetchAdminAttendances(
      workshopId: selectedWorkshopId,
      offeringId: selectedOfferingId,
      sessionId: selectedSessionId,
    );
  }

  Future<void> refreshAttendances() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      return _loadAttendances();
    });
  }

  Future<void> selectWorkshop(int? id) async {
    selectedWorkshopId = id;

    selectedOfferingId = null;

    selectedSessionId = null;

    await refreshAttendances();
  }

  Future<void> selectOffering(int? id) async {
    selectedOfferingId = id;

    selectedSessionId = null;

    await refreshAttendances();
  }

  Future<void> selectSession(int? id) async {
    selectedSessionId = id;

    await refreshAttendances();
  }

  Future<void> updateAttendance({
    required int attendanceId,
    required AttendanceStatus status,
  }) async {
    final current = state.value ?? [];

    final index = current.indexWhere((e) => e.id == attendanceId);

    if (index == -1) {
      return;
    }

    final oldItem = current[index];

    current[index] = oldItem.copyWith(attendanceStatus: status);

    state = AsyncData([...current]);

    try {
      await _service.updateAttendance(
        attendanceId: attendanceId,
        status: status.name,
      );
    } catch (e) {
      current[index] = oldItem;

      state = AsyncData([...current]);

      rethrow;
    }
  }
}

---
## File: lib\features\attendance\attendance_roster_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums.dart';
import '../../shared/utility/datetime_extension.dart';
import '../../shared/utility/string_extension.dart';
import 'attendance_models.dart';
import 'attendance_provider.dart';
import 'attendance_status_badge.dart';

class AttendanceRosterCard extends ConsumerWidget {
  final AttendanceModel attendance;

  const AttendanceRosterCard({super.key, required this.attendance});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(attendanceManagementProvider.notifier);

    return Card(
      elevation: 0,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),

        side: BorderSide(color: Colors.grey.shade300),
      ),

      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              attendance.student.name,

              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(
              attendance.student.email,

              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 16),

            Text(
              attendance.workshop.title,

              style: const TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 6),

            Text(attendance.offering.title),

            const SizedBox(height: 6),

            Text(attendance.session.title),

            const SizedBox(height: 6),

            Text(attendance.session.startAt?.readableDateTime ?? ''),

            const SizedBox(height: 18),

            AttendanceStatusBadge(status: attendance.attendanceStatus),

            const Spacer(),

            DropdownButtonFormField<AttendanceStatus>(
              value: attendance.attendanceStatus,

              isExpanded: true,

              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),

              items: AttendanceStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,

                  child: Text(status.name.displayLabel),
                );
              }).toList(),

              onChanged: (value) async {
                if (value == null) {
                  return;
                }

                try {
                  await notifier.updateAttendance(
                    attendanceId: attendance.id,

                    status: value,
                  );
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

---
## File: lib\features\attendance\attendance_service.dart
import '../../core/api_client.dart';
import 'attendance_models.dart';

class AttendanceService {
  final ApiClient _apiClient = ApiClient();

  Future<List<AttendanceModel>> fetchMyAttendances() async {
    final response = await _apiClient.get('/v1/me/attendances');

    final data = response['data'] as List<dynamic>;

    return data.map((e) => AttendanceModel.fromJson(e)).toList();
  }

  Future<List<AttendanceModel>> fetchAdminAttendances({
    int? workshopId,
    int? offeringId,
    int? sessionId,
  }) async {
    final response = await _apiClient.get(
      '/v1/admin/attendances',

      queryParameters: {
        if (workshopId != null) 'workshop_id': workshopId,

        if (offeringId != null) 'offering_id': offeringId,

        if (sessionId != null) 'session_id': sessionId,
      },
    );

    final data = response['data'] as List<dynamic>;

    return data.map((e) => AttendanceModel.fromJson(e)).toList();
  }

  Future<AttendanceFiltersResponse> fetchFilters() async {
    final response = await _apiClient.get('/v1/admin/attendance-filters');

    return AttendanceFiltersResponse.fromJson(response);
  }

  Future<AttendanceModel> updateAttendance({
    required int attendanceId,
    required String status,
  }) async {
    final response = await _apiClient.patch(
      '/v1/admin/attendances/$attendanceId',

      data: {'status': status},
    );

    return AttendanceModel.fromJson(response['data']);
  }
}

---
## File: lib\features\attendance\attendance_status_badge.dart
import 'package:flutter/material.dart';

import '../../core/enums.dart';
import '../../shared/utility/string_extension.dart';

class AttendanceStatusBadge extends StatelessWidget {
  final AttendanceStatus status;

  const AttendanceStatusBadge({super.key, required this.status});

  Color get color {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;

      case AttendanceStatus.absent:
        return Colors.red;

      case AttendanceStatus.late:
        return Colors.orange;

      case AttendanceStatus.partial:
        return Colors.blue;

      case AttendanceStatus.excused:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),

        borderRadius: BorderRadius.circular(30),
      ),

      child: Text(
        status.name.displayLabel,

        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

---
## File: lib\features\attendance\attendance_summary_card.dart
import 'package:flutter/material.dart';

class AttendanceSummaryCard extends StatelessWidget {
  final int total;

  final int present;

  final int absent;

  const AttendanceSummaryCard({
    super.key,
    required this.total,
    required this.present,
    required this.absent,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total == 0 ? 0 : ((present / total) * 100).toInt();

    return Card(
      elevation: 0,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),

        side: BorderSide(color: Colors.grey.shade300),
      ),

      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Attendance',

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            LinearProgressIndicator(value: percentage / 100),

            const SizedBox(height: 16),

            Text('$percentage% Attendance'),

            const SizedBox(height: 8),

            Text('$present Present • $absent Absent'),
          ],
        ),
      ),
    );
  }
}

---
## File: lib\features\attendance\learner_attendance_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums.dart';
import '../../shared/utility/datetime_extension.dart';
import '../dashboard/widgets/dashboard_shell.dart';
import 'attendance_provider.dart';
import 'attendance_status_badge.dart';
import 'attendance_summary_card.dart';

class LearnerAttendancePage extends ConsumerWidget {
  const LearnerAttendancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(learnerAttendanceProvider);

    return DashboardShell(
      title: 'My Attendance',

      child: attendanceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, _) => Center(child: Text(error.toString())),

        data: (attendances) {
          final total = attendances.length;

          final present = attendances
              .where((e) => e.attendanceStatus == AttendanceStatus.present)
              .length;

          final absent = attendances
              .where((e) => e.attendanceStatus == AttendanceStatus.absent)
              .length;

          final late = attendances
              .where((e) => e.attendanceStatus == AttendanceStatus.late)
              .length;

          return ListView(
            padding: const EdgeInsets.all(24),

            children: [
              AttendanceSummaryCard(
                total: total,

                present: present,

                absent: absent,
              ),

              const SizedBox(height: 24),

              Text(
                'Attendance History',

                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 20),

              ...attendances.map((attendance) {
                return Card(
                  elevation: 0,

                  margin: const EdgeInsets.only(bottom: 16),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),

                    side: BorderSide(color: Colors.grey.shade300),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(20),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                attendance.session.title,

                                style: const TextStyle(
                                  fontSize: 18,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            AttendanceStatusBadge(
                              status: attendance.attendanceStatus,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Text(
                          attendance.workshop.title,

                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),

                        const SizedBox(height: 6),

                        Text(attendance.offering.title),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Icon(
                              Icons.schedule,

                              size: 18,

                              color: Colors.grey.shade600,
                            ),

                            const SizedBox(width: 8),

                            Text(
                              attendance.session.startAt?.readableDateTime ??
                                  '',
                            ),
                          ],
                        ),

                        if (attendance.attendanceStatus ==
                            AttendanceStatus.late)
                          Padding(
                            padding: const EdgeInsets.only(top: 14),

                            child: Text(
                              'Marked Late',

                              style: TextStyle(
                                color: Colors.orange.shade700,

                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

---
## File: lib\features\auth\auth_models.dart
class User {
  final int id;
  final String name;
  final String email;
  final List<String> roles;

  final List<String> permissions;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.roles,
    required this.permissions,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      roles: (json['roles'] as List?)?.map((e) => e.toString()).toList() ?? [],
      permissions:
          (json['permissions'] as List?)?.map((e) => e.toString()).toList() ??
          [],
    );
  }

  bool get isAdmin => roles.contains('admin');

  bool get isTrainer => roles.contains('trainer');

  bool get isStudent => roles.contains('student');

  bool can(String permission) {
    return permissions.contains(permission);
  }
}

class AuthResponse {
  final User user;
  final String token;

  AuthResponse({required this.user, required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user']),

      token: json['token'],
    );
  }
}

---
## File: lib\features\auth\auth_provider.dart
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

      // Login only for token
      await service.login(email: email, password: password);

      // Fetch full identity
      final user = await service.me();

      // Store hydrated user
      state = AsyncData(user);

      return true;
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);

      return false;
    }
  }

  Future<void> logout() async {
    final service = ref.read(authServiceProvider);

    try {
      await service.logout();
    } catch (_) {
      // Ignore backend logout failures
    }

    // await AppStorage.clear();

    state = const AsyncData(null);
  }
}

---
## File: lib\features\auth\auth_service.dart
import '../../core/api_client.dart';
import '../../core/api_response.dart';
import '../../core/storage.dart';
import 'auth_models.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/v1/auth/login',

      data: {'email': email, 'password': password},
    );

    final apiResponse = ApiResponse.fromJson(
      response,
      (data) => AuthResponse.fromJson(data),
    );

    await AppStorage.saveToken(apiResponse.data.token);

    return apiResponse.data;
  }

  Future<User> me() async {
    final response = await _apiClient.get('/v1/auth/me');

    final apiResponse = ApiResponse.fromJson(
      response,
      (data) => User.fromJson(data),
    );

    return apiResponse.data;
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/v1/auth/logout');
    } catch (_) {}

    await AppStorage.clearToken();
  }
}

---
## File: lib\features\auth\pages\login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/navigation/app_shell.dart';
import '../auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  final String? redirect;

  const LoginPage({super.key, this.redirect});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = 'student@skillkart.test';
    // _emailController.text = 'admin@skillkart.test';
    _passwordController.text = 'password123';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return AppShell(
      child: Center(
        child: SizedBox(
          width: 400,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Login',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: authState.isLoading
                          ? null
                          : () async {
                              final success = await ref
                                  .read(authProvider.notifier)
                                  .login(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  );

                              if (!mounted) {
                                return;
                              }

                              if (success) {
                                final redirect = widget.redirect != null
                                    ? Uri.decodeComponent(widget.redirect!)
                                    : '/dashboard';

                                context.go(redirect);
                              }
                            },
                      child: authState.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Login'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

---
## File: lib\features\auth\pages\register_page.dart

---
## File: lib\features\categories\category_models.dart
class WorkshopCategory {
  final int id;
  final String name;

  WorkshopCategory({required this.id, required this.name});

  factory WorkshopCategory.fromJson(Map<String, dynamic> json) {
    return WorkshopCategory(id: json['id'], name: json['name']);
  }
}

---
## File: lib\features\categories\category_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'category_models.dart';
import 'category_service.dart';

final categoryServiceProvider = Provider((ref) => CategoryService());

final categoriesProvider = FutureProvider<List<WorkshopCategory>>((ref) async {
  final service = ref.read(categoryServiceProvider);

  return service.fetchCategories();
});

---
## File: lib\features\categories\category_service.dart
import '../../core/api_client.dart';
import '../../core/api_response.dart';
import 'category_models.dart';

class CategoryService {
  final ApiClient _apiClient = ApiClient();

  Future<List<WorkshopCategory>> fetchCategories() async {
    final response = await _apiClient.get('/v1/public/categories');

    final apiResponse = ApiResponse.fromJson(response, (data) {
      return (data as List)
          .map((item) => WorkshopCategory.fromJson(item))
          .toList();
    });

    return apiResponse.data;
  }
}

---
## File: lib\features\certificates\certificates_page.dart
import 'package:flutter/material.dart';

import '../../shared/responsive_layout.dart';
import '../dashboard/widgets/dashboard_shell.dart';
import 'certificate_card.dart';
import 'certificate_models.dart';
import 'certificate_service.dart';

class CertificatesPage extends StatefulWidget {
  const CertificatesPage({super.key});

  @override
  State<CertificatesPage> createState() => _CertificatesPageState();
}

class _CertificatesPageState extends State<CertificatesPage> {
  final _service = CertificateService();

  bool _loading = true;

  List<CertificateModel> certificates = [];

  @override
  void initState() {
    super.initState();

    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });

    try {
      certificates = await _service.fetchCertificates();
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return DashboardShell(
      title: 'Certificates',

      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(24),

              itemCount: certificates.length,

              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveLayout.gridCount(width),

                crossAxisSpacing: 20,

                mainAxisSpacing: 20,

                mainAxisExtent: 320,
              ),

              itemBuilder: (context, index) {
                return CertificateCard(certificate: certificates[index]);
              },
            ),
    );
  }
}

---
## File: lib\features\certificates\certificate_card.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'certificate_models.dart';

class CertificateCard extends StatelessWidget {
  final CertificateModel certificate;

  const CertificateCard({super.key, required this.certificate});

  Future<void> _openCertificate() async {
    final uri = Uri.parse(certificate.certificateUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),

        side: BorderSide(color: Colors.grey.shade300),
      ),

      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Icon(Icons.workspace_premium, size: 48, color: Colors.amber),

            const SizedBox(height: 20),

            Text(
              certificate.offeringTitle,

              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 14),

            Text(certificate.learnerName),

            const SizedBox(height: 10),

            Text(certificate.issuedAt),

            const Spacer(),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: certificate.downloadable ? _openCertificate : null,

                icon: const Icon(Icons.download),

                label: const Text('Download Certificate'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

---
## File: lib\features\certificates\certificate_models.dart
class CertificateModel {
  final int id;

  final String offeringTitle;

  final String learnerName;

  final String issuedAt;

  final String certificateUrl;

  final bool downloadable;

  CertificateModel({
    required this.id,
    required this.offeringTitle,
    required this.learnerName,
    required this.issuedAt,
    required this.certificateUrl,
    required this.downloadable,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      id: json['id'],

      offeringTitle: json['offering_title'] ?? '',

      learnerName: json['learner_name'] ?? '',

      issuedAt: json['issued_at'] ?? '',

      certificateUrl: json['certificate_url'] ?? '',

      downloadable: json['downloadable'] ?? false,
    );
  }
}

---
## File: lib\features\certificates\certificate_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'certificate_models.dart';
import 'certificate_service.dart';

final certificateServiceProvider = Provider((ref) => CertificateService());

final certificateProvider = FutureProvider<List<CertificateModel>>((ref) async {
  final service = ref.read(certificateServiceProvider);

  return service.fetchCertificates();
});

---
## File: lib\features\certificates\certificate_service.dart
import '../../core/api_client.dart';
import 'certificate_models.dart';

class CertificateService {
  final ApiClient _apiClient = ApiClient();

  Future<List<CertificateModel>> fetchCertificates() async {
    final response = await _apiClient.get('/v1/me/certificates');

    final data = response['data'] as List<dynamic>;

    return data.map((e) => CertificateModel.fromJson(e)).toList();
  }
}

---
## File: lib\features\dashboard\dashboard_models.dart
class DashboardStats {
  final int totalStudents;

  final int totalWorkshops;

  final int publishedWorkshops;

  final int totalEnrollments;

  DashboardStats({
    required this.totalStudents,
    required this.totalWorkshops,
    required this.publishedWorkshops,
    required this.totalEnrollments,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalStudents: json['total_students'] ?? 0,

      totalWorkshops: json['total_workshops'] ?? 0,

      publishedWorkshops: json['published_workshops'] ?? 0,

      totalEnrollments: json['total_enrollments'] ?? 0,
    );
  }
}

class RecentEnrollment {
  final int id;

  final int studentId;

  final String studentName;

  final int workshopId;

  final String workshopTitle;

  final String status;

  final String? createdAt;

  RecentEnrollment({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.workshopId,
    required this.workshopTitle,
    required this.status,
    required this.createdAt,
  });

  factory RecentEnrollment.fromJson(Map<String, dynamic> json) {
    return RecentEnrollment(
      id: json['id'],

      studentId: json['student_id'] ?? 0,

      studentName: json['student_name'] ?? '',

      workshopId: json['workshop_id'] ?? 0,

      workshopTitle: json['workshop_title'] ?? '',

      status: json['status'] ?? '',

      createdAt: json['created_at'],
    );
  }
}

class RecentWorkshop {
  final int id;

  final String title;

  final String slug;

  final String status;

  final int ownerId;

  final String ownerName;

  final String? createdAt;

  RecentWorkshop({
    required this.id,
    required this.title,
    required this.slug,
    required this.status,
    required this.ownerId,
    required this.ownerName,
    required this.createdAt,
  });

  factory RecentWorkshop.fromJson(Map<String, dynamic> json) {
    return RecentWorkshop(
      id: json['id'],

      title: json['title'] ?? '',

      slug: json['slug'] ?? '',

      status: json['status'] ?? '',

      ownerId: json['owner_id'] ?? 0,

      ownerName: json['owner_name'] ?? '',

      createdAt: json['created_at'],
    );
  }
}

---
## File: lib\features\dashboard\dashboard_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dashboard_models.dart';
import 'dashboard_service.dart';

final dashboardServiceProvider = Provider((ref) => DashboardService());

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final service = ref.read(dashboardServiceProvider);

  return service.fetchStats();
});

final recentEnrollmentsProvider = FutureProvider<List<RecentEnrollment>>((
  ref,
) async {
  final service = ref.read(dashboardServiceProvider);

  return service.fetchRecentEnrollments();
});

final recentWorkshopsProvider = FutureProvider<List<RecentWorkshop>>((
  ref,
) async {
  final service = ref.read(dashboardServiceProvider);

  return service.fetchRecentWorkshops();
});

---
## File: lib\features\dashboard\dashboard_service.dart
import '../../core/api_client.dart';
import '../../core/api_response.dart';
import 'dashboard_models.dart';

class DashboardService {
  final ApiClient _apiClient = ApiClient();

  Future<DashboardStats> fetchStats() async {
    final response = await _apiClient.get('/v1/dashboard/stats');

    final apiResponse = ApiResponse.fromJson(
      response,
      (data) => DashboardStats.fromJson(data),
    );

    return apiResponse.data;
  }

  Future<List<RecentEnrollment>> fetchRecentEnrollments() async {
    final response = await _apiClient.get('/v1/dashboard/recent-enrollments');

    final apiResponse = ApiResponse.fromJson(response, (data) {
      return (data as List)
          .map((item) => RecentEnrollment.fromJson(item))
          .toList();
    });

    return apiResponse.data;
  }

  Future<List<RecentWorkshop>> fetchRecentWorkshops() async {
    final response = await _apiClient.get('/v1/dashboard/recent-workshops');

    final apiResponse = ApiResponse.fromJson(response, (data) {
      return (data as List)
          .map((item) => RecentWorkshop.fromJson(item))
          .toList();
    });

    return apiResponse.data;
  }
}

---
## File: lib\features\dashboard\pages\dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dashboard_models.dart';
import '../dashboard_provider.dart';
import '../widgets/dashboard_shell.dart';
import '../widgets/stats_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    final enrollmentsAsync = ref.watch(recentEnrollmentsProvider);

    final recentWorkshopsAsync = ref.watch(recentWorkshopsProvider);

    return DashboardShell(
      title: "Dashboard",
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                int crossAxisCount = 4;

                if (width < 1200) {
                  crossAxisCount = 2;
                }

                if (width < 700) {
                  crossAxisCount = 1;
                }

                return GridView.count(
                  crossAxisCount: crossAxisCount,

                  shrinkWrap: true,

                  physics: const NeverScrollableScrollPhysics(),

                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,

                  childAspectRatio: 2.2,

                  children: [
                    ...statsAsync.when(
                      loading: () {
                        return List.generate(4, (index) {
                          return const StatsCard(
                            title: 'Loading...',

                            value: '--',

                            icon: Icons.hourglass_top,
                          );
                        });
                      },

                      error: (error, stackTrace) {
                        return [
                          const StatsCard(
                            title: 'Error',

                            value: '0',

                            icon: Icons.error,
                          ),
                        ];
                      },

                      data: (stats) {
                        return [
                          StatsCard(
                            title: 'Students',

                            value: stats.totalStudents.toString(),

                            icon: Icons.people,
                          ),

                          StatsCard(
                            title: 'Workshops',

                            value: stats.totalWorkshops.toString(),

                            icon: Icons.school,
                          ),

                          StatsCard(
                            title: 'Published',

                            value: stats.publishedWorkshops.toString(),

                            icon: Icons.public,
                          ),

                          StatsCard(
                            title: 'Enrollments',

                            value: stats.totalEnrollments.toString(),

                            icon: Icons.trending_up,
                          ),
                        ];
                      },
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 900;

                if (isMobile) {
                  return Column(
                    children: [
                      _RecentEnrollmentsCard(
                        enrollmentsAsync: enrollmentsAsync,
                      ),

                      const SizedBox(height: 24),

                      _RecentWorkshopsCard(
                        recentWorkshopsAsync: recentWorkshopsAsync,
                      ),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Expanded(
                      child: _RecentEnrollmentsCard(
                        enrollmentsAsync: enrollmentsAsync,
                      ),
                    ),

                    const SizedBox(width: 24),

                    Expanded(
                      child: _RecentWorkshopsCard(
                        recentWorkshopsAsync: recentWorkshopsAsync,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentEnrollmentsCard extends StatelessWidget {
  final AsyncValue<List<RecentEnrollment>> enrollmentsAsync;

  const _RecentEnrollmentsCard({required this.enrollmentsAsync});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Recent Enrollments',

              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            ...enrollmentsAsync.when(
              loading: () {
                return List.generate(5, (index) {
                  return const ListTile(
                    contentPadding: EdgeInsets.zero,

                    title: Text('Loading...'),
                  );
                });
              },

              error: (error, stackTrace) {
                return [ListTile(title: Text(error.toString()))];
              },

              data: (enrollments) {
                return enrollments.map((enrollment) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,

                    leading: const CircleAvatar(child: Icon(Icons.person)),

                    title: Text(enrollment.studentName),

                    subtitle: Text(enrollment.workshopTitle),

                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      crossAxisAlignment: CrossAxisAlignment.end,

                      children: [
                        Text(enrollment.status),

                        const SizedBox(height: 4),

                        Text(
                          enrollment.createdAt ?? '',

                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }).toList();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentWorkshopsCard extends StatelessWidget {
  final AsyncValue<List<RecentWorkshop>> recentWorkshopsAsync;

  const _RecentWorkshopsCard({required this.recentWorkshopsAsync});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Recent Workshops',

              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            ...recentWorkshopsAsync.when(
              loading: () {
                return List.generate(5, (index) {
                  return const ListTile(
                    contentPadding: EdgeInsets.zero,

                    title: Text('Loading...'),
                  );
                });
              },

              error: (error, stackTrace) {
                return [ListTile(title: Text(error.toString()))];
              },

              data: (workshops) {
                return workshops.map((workshop) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,

                    leading: const CircleAvatar(child: Icon(Icons.school)),

                    title: Text(workshop.title),

                    subtitle: Text(workshop.ownerName),

                    trailing: Text(workshop.status),
                  );
                }).toList();
              },
            ),
          ],
        ),
      ),
    );
  }
}

---
## File: lib\features\dashboard\widgets\dashboard_shell.dart
import 'package:flutter/material.dart';

import 'dashboard_sidebar.dart';
import 'dashboard_topbar.dart';

class DashboardShell extends StatelessWidget {
  final Widget child;

  final String? title;

  final List<Widget>? actions;

  const DashboardShell({
    super.key,
    required this.child,
    this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      drawer: isMobile ? const Drawer(child: DashboardSidebar()) : null,

      body: Row(
        children: [
          if (!isMobile) const SizedBox(width: 260, child: DashboardSidebar()),

          Expanded(
            child: Column(
              children: [
                DashboardTopbar(title: title, actions: actions),

                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

---
## File: lib\features\dashboard\widgets\dashboard_sidebar.dart
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

---
## File: lib\features\dashboard\widgets\dashboard_topbar.dart
import 'package:flutter/material.dart';

import '../../../shared/responsive_layout.dart';

class DashboardTopbar extends StatelessWidget {
  final String? title;

  final List<Widget>? actions;

  const DashboardTopbar({super.key, this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isMobile = ResponsiveLayout.isMobile(width);

    return Container(
      height: 72,

      padding: const EdgeInsets.symmetric(horizontal: 24),

      decoration: BoxDecoration(
        color: Colors.white,

        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),

      child: Row(
        children: [
          if (isMobile)
            Builder(
              builder: (context) {
                return IconButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },

                  icon: const Icon(Icons.menu),
                );
              },
            ),

          if (title != null)
            Expanded(
              child: Text(
                title!,

                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            const Spacer(),

          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}

---
## File: lib\features\dashboard\widgets\stats_card.dart
import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;

  final IconData icon;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Row(
          children: [
            Icon(icon, size: 40),

            const SizedBox(width: 24),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(title),

                const SizedBox(height: 8),

                Text(
                  value,

                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

---
## File: lib\features\home\home_page.dart
import 'package:flutter/material.dart';

import '../../shared/navigation/app_shell.dart';
import 'widgets/categories_section.dart';
import 'widgets/featured_workshops_section.dart';
import 'widgets/hero_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShell(
      child: SingleChildScrollView(
        child: Column(
          children: [
            HeroSection(),

            FeaturedWorkshopsSection(),

            CategoriesSection(),
          ],
        ),
      ),
    );
  }
}

---
## File: lib\features\home\widgets\categories_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../categories/category_provider.dart';

class CategoriesSection extends ConsumerWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Padding(
      padding: const EdgeInsets.all(24),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Categories',

            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          categoriesAsync.when(
            loading: () {
              return const CircularProgressIndicator();
            },

            error: (error, stackTrace) {
              return Text(error.toString());
            },

            data: (categories) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,

                children: categories.map((category) {
                  return Chip(label: Text(category.name));
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

---
## File: lib\features\home\widgets\featured_workshops_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/responsive_layout.dart';
import '../../workshops/widgets/compact_workshop_card.dart';
import '../../workshops/workshop_provider.dart';

class FeaturedWorkshopsSection extends ConsumerWidget {
  const FeaturedWorkshopsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workshopsAsync = ref.watch(workshopsProvider);

    return Padding(
      padding: const EdgeInsets.all(24),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Featured Workshops',

            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          workshopsAsync.when(
            loading: () {
              return const Center(child: CircularProgressIndicator());
            },

            error: (error, stackTrace) {
              return Text(error.toString());
            },

            data: (pagination) {
              final workshops = pagination.workshops.take(4).toList();

              return LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;

                  final crossAxisCount = ResponsiveLayout.gridCount(width);

                  return GridView.builder(
                    shrinkWrap: true,

                    physics: const NeverScrollableScrollPhysics(),

                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,

                      crossAxisSpacing: 16,

                      mainAxisSpacing: 16,

                      mainAxisExtent: 340,
                    ),

                    itemCount: workshops.length,

                    itemBuilder: (context, index) {
                      return CompactWorkshopCard(workshop: workshops[index]);
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

---
## File: lib\features\home\widgets\hero_section.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),

      decoration: BoxDecoration(color: Colors.indigo.shade50),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Learn Future Skills',

            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          const SizedBox(
            width: 700,

            child: Text(
              'Join premium workshops on '
              'Flutter, AI, Robotics, '
              'Cybersecurity and more.',

              style: TextStyle(fontSize: 20, height: 1.5),
            ),
          ),

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: () {
              context.go('/workshops');
            },

            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),

              child: Text('Browse Workshops'),
            ),
          ),
        ],
      ),
    );
  }
}

---
## File: lib\features\home\widgets\latest_workshops_section.dart

---
## File: lib\features\learning\learning_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'learning_service.dart';
import 'models/learner_dashboard_model.dart';
import 'models/learning_enrollment_model.dart';

final learningServiceProvider = Provider((ref) => LearningService());

final learnerDashboardProvider = FutureProvider<LearnerDashboardModel>((
  ref,
) async {
  final service = ref.read(learningServiceProvider);

  return service.fetchDashboard();
});

final myEnrollmentsProvider = FutureProvider<List<LearningEnrollmentModel>>((
  ref,
) async {
  final service = ref.read(learningServiceProvider);

  return service.fetchEnrollments();
});

---
## File: lib\features\learning\learning_service.dart
import '../../../core/api_client.dart';
import 'models/learner_dashboard_model.dart';
import 'models/learning_enrollment_model.dart';
import 'models/reservation_model.dart';

class LearningService {
  final ApiClient _apiClient = ApiClient();

  Future<LearnerDashboardModel> fetchDashboard() async {
    final enrollmentsResponse = await _apiClient.get(
      '/v1/me/offering-enrollments',
    );

    final reservationsResponse = await _apiClient.get(
      '/v1/me/session-reservations',
    );

    final enrollmentsData = enrollmentsResponse['data'] as List<dynamic>;

    final reservationsData = reservationsResponse['data'] as List<dynamic>;

    return LearnerDashboardModel(
      enrollments: enrollmentsData
          .map((e) => LearningEnrollmentModel.fromJson(e))
          .toList(),

      upcomingReservations: reservationsData
          .map((e) => ReservationModel.fromJson(e))
          .toList(),
    );
  }

  Future<List<LearningEnrollmentModel>> fetchEnrollments() async {
    final response = await _apiClient.get('/v1/me/offering-enrollments');

    final data = response['data'] as List<dynamic>;

    return data.map((e) => LearningEnrollmentModel.fromJson(e)).toList();
  }

  Future<void> cancelEnrollment(int enrollmentId) async {
    await _apiClient.delete('/v1/me/offering-enrollments/$enrollmentId');
  }
}

---
## File: lib\features\learning\models\learner_dashboard_model.dart
import 'learning_enrollment_model.dart';
import 'reservation_model.dart';

class LearnerDashboardModel {
  final List<LearningEnrollmentModel> enrollments;

  final List<ReservationModel> upcomingReservations;

  LearnerDashboardModel({
    required this.enrollments,
    required this.upcomingReservations,
  });
}

---
## File: lib\features\learning\models\learning_enrollment_model.dart
import '../../certificates/certificate_models.dart';
import '../../offerings/models/offering_model.dart';

class LearningEnrollmentModel {
  final int id;

  final OfferingModel offering;

  final String enrollmentStatus;

  final String paymentStatus;

  final String completionStatus;

  final double progressPercentage;

  final bool certificateEligible;

  final bool certificateIssued;

  final String? enrolledAt;

  final CertificateModel? certificate;

  LearningEnrollmentModel({
    required this.id,
    required this.offering,
    required this.enrollmentStatus,
    required this.paymentStatus,
    required this.completionStatus,
    required this.progressPercentage,
    required this.certificateEligible,
    required this.certificateIssued,
    required this.enrolledAt,
    required this.certificate,
  });

  factory LearningEnrollmentModel.fromJson(Map<String, dynamic> json) {
    return LearningEnrollmentModel(
      id: json['id'],

      offering: OfferingModel.fromJson(json['offering']),

      enrollmentStatus: json['enrollment_status'] ?? '',

      paymentStatus: json['payment_status'] ?? '',

      completionStatus: json['completion_status'] ?? '',

      progressPercentage:
          double.tryParse(json['progress_percentage'].toString()) ?? 0,

      certificateEligible: json['certificate_eligible'] ?? false,

      certificateIssued: json['certificate_issued'] ?? false,

      enrolledAt: json['enrolled_at'],
      certificate: json['certificate'] != null
          ? CertificateModel.fromJson(json['certificate'])
          : null,
    );
  }
}

---
## File: lib\features\learning\models\reservation_model.dart
import '../../offerings/models/session_model.dart';

class ReservationModel {
  final int id;

  final SessionModel session;

  final String status;

  final bool attended;

  final bool checkedIn;

  final String? reservedAt;

  ReservationModel({
    required this.id,
    required this.session,
    required this.status,
    required this.attended,
    required this.checkedIn,
    required this.reservedAt,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'],

      session: SessionModel.fromJson(json['session']),

      status: json['status'] ?? '',

      attended: json['attended'] ?? false,

      checkedIn: json['checked_in'] ?? false,

      reservedAt: json['reserved_at'],
    );
  }
}

---
## File: lib\features\learning\pages\learning_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/navigation/app_shell.dart';
import '../../../shared/utility/string_extension.dart';
import '../learning_provider.dart';
import '../widgets/learner_session_card.dart';

class LearningDetailPage extends ConsumerWidget {
  final int enrollmentId;

  const LearningDetailPage({super.key, required this.enrollmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrollmentsAsync = ref.watch(myEnrollmentsProvider);
    final dashboardAsync = ref.watch(learnerDashboardProvider);

    return AppShell(
      child: enrollmentsAsync.when(
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stackTrace) {
          return Center(child: Text(error.toString()));
        },
        data: (enrollments) {
          final enrollment = enrollments.firstWhere(
            (e) => e.id == enrollmentId,
          );

          final offering = enrollment.offering;

          return dashboardAsync.when(
            loading: () {
              return const Center(child: CircularProgressIndicator());
            },
            error: (error, stackTrace) {
              return Center(child: Text(error.toString()));
            },
            data: (dashboard) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.indigo.shade400,
                            Colors.indigo.shade700,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offering.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            offering.workshop?.title ?? '',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 28),
                          LinearProgressIndicator(
                            value: enrollment.progressPercentage / 100,
                            minHeight: 10,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            '${enrollment.progressPercentage.toStringAsFixed(0)}% Complete',
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              Chip(
                                label: Text(
                                  enrollment.enrollmentStatus.displayLabel,
                                ),
                              ),
                              Chip(
                                label: Text(
                                  enrollment.completionStatus.displayLabel,
                                ),
                              ),
                              if (enrollment.certificateEligible)
                                const Chip(label: Text('Certificate Eligible')),
                              if (enrollment.certificateIssued)
                                const Chip(label: Text('Certificate Issued')),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    const Text(
                      'Learning Sessions',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dashboard.upcomingReservations.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            mainAxisExtent: 280,
                          ),
                      itemBuilder: (context, index) {
                        return LearnerSessionCard(
                          reservation: dashboard.upcomingReservations[index],
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

---
## File: lib\features\learning\pages\my_learning_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums.dart';
import '../../../shared/navigation/app_shell.dart';
import '../../attendance/attendance_provider.dart';
import '../../certificates/certificate_provider.dart';
import '../../progress/progress_provider.dart';
import '../learning_provider.dart';
import '../widgets/enrolled_offering_card.dart';
import '../widgets/learning_stats_section.dart';
import '../widgets/upcoming_session_card.dart';

class MyLearningPage extends ConsumerWidget {
  const MyLearningPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(learnerDashboardProvider);

    final progressAsync = ref.watch(progressProvider);

    final attendanceAsync = ref.watch(learnerAttendanceProvider);

    final certificatesAsync = ref.watch(certificateProvider);

    return AppShell(
      child: dashboardAsync.when(
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },

        error: (error, stackTrace) {
          return Center(child: Text(error.toString()));
        },

        data: (dashboard) {
          return progressAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),

            error: (error, _) => Center(child: Text(error.toString())),

            data: (progressItems) {
              return attendanceAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),

                error: (error, _) => Center(child: Text(error.toString())),

                data: (attendances) {
                  return certificatesAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),

                    error: (error, _) => Center(child: Text(error.toString())),

                    data: (certificates) {
                      final totalProgress = progressItems.isEmpty
                          ? 0.0
                          : progressItems
                                    .map((e) => e.progressPercentage)
                                    .reduce((a, b) => a + b) /
                                progressItems.length;

                      final attended = attendances
                          .where(
                            (e) =>
                                e.attendanceStatus == AttendanceStatus.present,
                          )
                          .length;

                      final attendancePercentage = attendances.isEmpty
                          ? 0
                          : ((attended / attendances.length) * 100).toInt();

                      final eligibleCertificates = progressItems
                          .where((e) => e.certificateEligible)
                          .length;

                      final completedOfferings = progressItems
                          .where(
                            (e) =>
                                e.completionStatus ==
                                CompletionStatus.completed,
                          )
                          .length;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(32),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            const Text(
                              'My Learning',

                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 32),

                            LearningStatsSection(
                              enrollmentsCount: dashboard.enrollments.length,

                              sessionsCount:
                                  dashboard.upcomingReservations.length,
                            ),

                            const SizedBox(height: 32),

                            GridView.count(
                              shrinkWrap: true,

                              physics: const NeverScrollableScrollPhysics(),

                              crossAxisCount: 4,

                              crossAxisSpacing: 20,

                              mainAxisSpacing: 20,

                              childAspectRatio: 1.6,

                              children: [
                                _StatCard(
                                  title: 'Progress',

                                  value: '${totalProgress.toStringAsFixed(0)}%',

                                  icon: Icons.trending_up,
                                ),

                                _StatCard(
                                  title: 'Attendance',

                                  value: '$attendancePercentage%',

                                  icon: Icons.fact_check,
                                ),

                                _StatCard(
                                  title: 'Completed',

                                  value: '$completedOfferings',

                                  icon: Icons.school,
                                ),

                                _StatCard(
                                  title: 'Certificates',

                                  value: '${certificates.length}',

                                  subtitle: '$eligibleCertificates eligible',

                                  icon: Icons.workspace_premium,
                                ),
                              ],
                            ),

                            const SizedBox(height: 56),

                            if (attendancePercentage < 75)
                              Container(
                                width: double.infinity,

                                padding: const EdgeInsets.all(20),

                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(.1),

                                  borderRadius: BorderRadius.circular(20),
                                ),

                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.warning_amber_rounded,

                                      color: Colors.orange,
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Text(
                                        'Your attendance is below the recommended threshold. '
                                        'Attend upcoming sessions to maintain certificate eligibility.',
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            if (attendancePercentage < 75)
                              const SizedBox(height: 40),

                            const Text(
                              'Enrolled Offerings',

                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 24),

                            GridView.builder(
                              shrinkWrap: true,

                              physics: const NeverScrollableScrollPhysics(),

                              itemCount: dashboard.enrollments.length,

                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,

                                    crossAxisSpacing: 20,

                                    mainAxisSpacing: 20,

                                    mainAxisExtent: 320,
                                  ),

                              itemBuilder: (context, index) {
                                return EnrolledOfferingCard(
                                  enrollment: dashboard.enrollments[index],
                                );
                              },
                            ),

                            const SizedBox(height: 56),

                            const Text(
                              'Upcoming Sessions',

                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 24),

                            GridView.builder(
                              shrinkWrap: true,

                              physics: const NeverScrollableScrollPhysics(),

                              itemCount: dashboard.upcomingReservations.length,

                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,

                                    crossAxisSpacing: 20,

                                    mainAxisSpacing: 20,

                                    mainAxisExtent: 260,
                                  ),

                              itemBuilder: (context, index) {
                                return UpcomingSessionCard(
                                  reservation:
                                      dashboard.upcomingReservations[index],
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;

  final String value;

  final String? subtitle;

  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),

        side: BorderSide(color: Colors.grey.shade300),
      ),

      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Icon(icon, size: 30),

            const Spacer(),

            Text(
              value,

              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(title, style: TextStyle(color: Colors.grey.shade700)),

            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),

                child: Text(
                  subtitle!,

                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

---
## File: lib\features\learning\widgets\attendance_badge.dart
import 'package:flutter/material.dart';

class AttendanceBadge extends StatelessWidget {
  final bool attended;

  const AttendanceBadge({super.key, required this.attended});

  @override
  Widget build(BuildContext context) {
    final color = attended ? Colors.green : Colors.orange;

    final label = attended ? 'ATTENDED' : 'PENDING';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

      decoration: BoxDecoration(
        color: color.withOpacity(.12),

        borderRadius: BorderRadius.circular(30),
      ),

      child: Text(
        label,

        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

---
## File: lib\features\learning\widgets\enrolled_offering_card.dart
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utility/string_extension.dart';
import '../learning_provider.dart';
import '../models/learning_enrollment_model.dart';

class EnrolledOfferingCard extends ConsumerStatefulWidget {
  final LearningEnrollmentModel enrollment;

  const EnrolledOfferingCard({super.key, required this.enrollment});

  @override
  ConsumerState<EnrolledOfferingCard> createState() =>
      _EnrolledOfferingCardState();
}

class _EnrolledOfferingCardState extends ConsumerState<EnrolledOfferingCard> {
  bool loading = false;

  Future<void> _cancelEnrollment() async {
    final confirmed = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Enrollment'),

          content: const Text(
            'Are you sure you want to cancel this enrollment?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },

              child: const Text('No'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },

              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final service = ref.read(learningServiceProvider);

      await service.cancelEnrollment(widget.enrollment.id);

      ref.invalidate(learnerDashboardProvider);
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void _downloadCertificate() {
    final certificate = widget.enrollment.certificate;

    if (certificate == null || certificate.certificateUrl.isEmpty) {
      return;
    }

    html.window.open(certificate.certificateUrl, '_blank');
  }

  @override
  Widget build(BuildContext context) {
    final enrollment = widget.enrollment;

    debugPrint(
      'Enrollment ${enrollment.id} '
      'issued=${enrollment.certificateIssued} '
      'eligible=${enrollment.certificateEligible} '
      'certificate=${enrollment.certificate}',
    );

    return Card(
      elevation: 0,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),

        side: BorderSide(color: Colors.grey.shade300),
      ),

      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              enrollment.offering.title,

              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Chip(label: Text(enrollment.enrollmentStatus.displayLabel)),

            const SizedBox(height: 18),

            Text(
              'Progress: '
              '${enrollment.progressPercentage.toStringAsFixed(0)}%',
            ),

            const SizedBox(height: 12),

            LinearProgressIndicator(value: enrollment.progressPercentage / 100),

            const Spacer(),

            if (loading)
              const Center(child: CircularProgressIndicator())
            else ...[
              if (enrollment.certificateIssued &&
                  enrollment.certificate != null)
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    onPressed: _downloadCertificate,

                    icon: const Icon(Icons.workspace_premium),

                    label: const Text('Download Certificate'),
                  ),
                ),

              if (!enrollment.certificateIssued &&
                  enrollment.completionStatus != 'completed')
                Padding(
                  padding: const EdgeInsets.only(top: 12),

                  child: SizedBox(
                    width: double.infinity,

                    child: OutlinedButton.icon(
                      onPressed: _cancelEnrollment,

                      icon: const Icon(Icons.close),

                      label: const Text('Cancel Enrollment'),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

---
## File: lib\features\learning\widgets\learner_session_card.dart
import 'package:flutter/material.dart';

import '../models/reservation_model.dart';
import 'attendance_badge.dart';
import 'reservation_status_badge.dart';

class LearnerSessionCard extends StatelessWidget {
  final ReservationModel reservation;

  const LearnerSessionCard({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    final session = reservation.session;

    return Card(
      elevation: 0,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),

        side: BorderSide(color: Colors.grey.shade300),
      ),

      child: Padding(
        padding: const EdgeInsets.all(22),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                ReservationStatusBadge(status: reservation.status),

                const SizedBox(width: 12),

                AttendanceBadge(attended: reservation.attended),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              session.title,

              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(Icons.schedule, size: 18),

                const SizedBox(width: 8),

                Expanded(child: Text(session.startAt)),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.location_on, size: 18),

                const SizedBox(width: 8),

                Expanded(child: Text(session.venueName ?? 'Virtual Session')),
              ],
            ),

            const Spacer(),

            if (session.isLive)
              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  onPressed: () {},

                  icon: const Icon(Icons.play_arrow),

                  label: const Text('Join Live Session'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

---
## File: lib\features\learning\widgets\learning_stats_section.dart
import 'package:flutter/material.dart';

class LearningStatsSection extends StatelessWidget {
  final int enrollmentsCount;

  final int sessionsCount;

  const LearningStatsSection({
    super.key,
    required this.enrollmentsCount,
    required this.sessionsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,

      children: [
        _StatCard(label: 'Enrollments', value: enrollmentsCount.toString()),

        _StatCard(label: 'Upcoming Sessions', value: sessionsCount.toString()),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;

  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,

      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: Colors.indigo.shade50,

        borderRadius: BorderRadius.circular(24),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),

          const SizedBox(height: 14),

          Text(
            value,

            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

---
## File: lib\features\learning\widgets\reservation_status_badge.dart
import 'package:flutter/material.dart';

class ReservationStatusBadge extends StatelessWidget {
  final String status;

  const ReservationStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (status.toLowerCase()) {
      case 'reserved':
        color = Colors.blue;
        break;

      case 'attended':
        color = Colors.green;
        break;

      case 'waitlisted':
        color = Colors.orange;
        break;

      case 'cancelled':
        color = Colors.red;
        break;

      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

      decoration: BoxDecoration(
        color: color.withOpacity(.12),

        borderRadius: BorderRadius.circular(30),
      ),

      child: Text(
        status.toUpperCase(),

        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

---
## File: lib\features\learning\widgets\upcoming_session_card.dart
import 'package:flutter/material.dart';

import '../../../shared/utility/datetime_extension.dart';
import '../models/reservation_model.dart';

class UpcomingSessionCard extends StatelessWidget {
  final ReservationModel reservation;

  const UpcomingSessionCard({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    final session = reservation.session;

    return Card(
      elevation: 0,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),

        side: BorderSide(color: Colors.grey.shade300),
      ),

      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              session.title,

              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 14),

            Text(session.startAt.readableDateTime),

            const SizedBox(height: 14),

            Chip(label: Text(reservation.status)),

            const Spacer(),

            if (session.isLive)
              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: () {},

                  child: const Text('Join Session'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

---
## File: lib\features\notifications\notifications_page.dart

---
## File: lib\features\notifications\notification_badge.dart

---
## File: lib\features\notifications\notification_initializer.dart

---
## File: lib\features\notifications\notification_models.dart

---
## File: lib\features\notifications\notification_provider.dart

---
## File: lib\features\notifications\notification_router.dart

---
## File: lib\features\notifications\notification_service.dart

---
## File: lib\features\offerings\offering_service.dart
import '../../../core/api_client.dart';
import 'models/offering_model.dart';

class OfferingService {
  final ApiClient _apiClient = ApiClient();

  Future<List<OfferingModel>> getWorkshopOfferings(String workshopSlug) async {
    final response = await _apiClient.get(
      '/v1/public/workshops/$workshopSlug/offerings',
    );

    final data = response['data'] as List<dynamic>;

    return data.map((e) => OfferingModel.fromJson(e)).toList();
  }

  Future<OfferingModel> getOffering(String slug) async {
    final response = await _apiClient.get('/v1/public/offerings/$slug');

    final data = response['data'];

    return OfferingModel.fromJson(data);
  }

  Future<void> enroll(int offeringId) async {
    await _apiClient.post('/v1/me/offerings/$offeringId/enroll');
  }
}

---
## File: lib\features\offerings\models\offering_model.dart
import '../../../core/enums.dart';
import '../../../shared/utility/enum_extension.dart';
import '../../../shared/utility/json_utils.dart';
import '../../workshops/workshop_models.dart';
import 'session_model.dart';

class OfferingModel {
  final int id;
  final String title;
  final String slug;

  final Workshop? workshop;

  final DeliveryMode deliveryMode;
  final EnrollmentType enrollmentType;
  final SessionSelectionRule sessionSelectionRule;
  final CompletionRule completionRule;
  final CapacityMode capacityMode;

  final int? minimumSessionsRequired;
  final int? maximumSessionsSelectable;

  final String? startDate;
  final String? endDate;

  final String? enrollmentOpenAt;
  final String? enrollmentCloseAt;

  final int? capacity;
  final String price;

  final String timezone;

  final String? venueName;
  final String? venueAddress;

  final String? meetingLink;

  final bool certificateEnabled;

  final List<SessionModel> sessions;

  final OfferingStatus status;

  final String? notes;

  final bool isUpcoming;
  final bool hasStarted;
  final bool hasEnded;

  OfferingModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.workshop,
    required this.deliveryMode,
    required this.enrollmentType,
    required this.sessionSelectionRule,
    required this.completionRule,
    required this.capacityMode,
    required this.minimumSessionsRequired,
    required this.maximumSessionsSelectable,
    required this.startDate,
    required this.endDate,
    required this.enrollmentOpenAt,
    required this.enrollmentCloseAt,
    required this.capacity,
    required this.price,
    required this.timezone,
    required this.venueName,
    required this.venueAddress,
    required this.meetingLink,
    required this.certificateEnabled,
    required this.sessions,
    required this.status,
    required this.notes,
    required this.isUpcoming,
    required this.hasStarted,
    required this.hasEnded,
  });

  factory OfferingModel.fromJson(Map<String, dynamic> json) {
    return OfferingModel(
      id: json['id'],
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      workshop: json['workshop'] != null
          ? Workshop.fromJson(json['workshop'])
          : null,
      deliveryMode:
          DeliveryMode.values.byNameOrNull(json['delivery_mode']) ??
          DeliveryMode.virtual,
      enrollmentType:
          EnrollmentType.values.byNameOrNull(json['enrollment_type']) ??
          EnrollmentType.full_series,
      sessionSelectionRule:
          SessionSelectionRule.values.byNameOrNull(
            json['session_selection_rule'],
          ) ??
          SessionSelectionRule.all_sessions,
      completionRule:
          CompletionRule.values.byNameOrNull(json['completion_rule']) ??
          CompletionRule.manual_completion,
      capacityMode:
          CapacityMode.values.byNameOrNull(json['capacity_mode']) ??
          CapacityMode.offering_only,
      minimumSessionsRequired: json['minimum_sessions_required'],
      maximumSessionsSelectable: json['maximum_sessions_selectable'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      enrollmentOpenAt: json['enrollment_open_at'],
      enrollmentCloseAt: json['enrollment_close_at'],
      capacity: JsonUtils.parseInt(json['capacity']),
      price: json['price']?.toString() ?? '0',
      timezone: json['timezone'] ?? '',
      venueName: json['venue_name'],
      venueAddress: json['venue_address'],
      meetingLink: json['meeting_link'],
      certificateEnabled: json['certificate_enabled'] ?? false,
      sessions: (json['sessions'] as List<dynamic>? ?? [])
          .map((e) => SessionModel.fromJson(e))
          .toList(),
      status:
          OfferingStatus.values.byNameOrNull(json['status']) ??
          OfferingStatus.draft,
      notes: json['notes'],
      isUpcoming: json['is_upcoming'] ?? false,
      hasStarted: json['has_started'] ?? false,
      hasEnded: json['has_ended'] ?? false,
    );
  }
}

---
## File: lib\features\offerings\models\session_model.dart
import '../../../core/enums.dart';
import '../../../shared/utility/enum_extension.dart';

class SessionModel {
  final int id;
  final int? sessionNumber;
  final String title;
  final SessionKind sessionKind;
  final DeliveryMode deliveryMode;

  final String startAt;
  final String endAt;
  final String timezone;

  final int? durationMinutes;

  final String? venueName;
  final String? venueAddress;
  final String? meetingLink;

  final String? agendaSummary;
  final String? materialsRequired;
  final String? prework;
  final String? homework;

  final int? capacity;

  final bool waitlistEnabled;
  final bool bookable;
  final bool attendanceRequired;

  final String completionWeight;

  final String? recordingUrl;
  final String? slidesUrl;

  final List<dynamic>? resources;

  final SessionStatus status;

  final bool isUpcoming;
  final bool isLive;
  final bool isCompleted;

  SessionModel({
    required this.id,
    required this.sessionNumber,
    required this.title,
    required this.sessionKind,
    required this.deliveryMode,
    required this.startAt,
    required this.endAt,
    required this.timezone,
    required this.durationMinutes,
    required this.venueName,
    required this.venueAddress,
    required this.meetingLink,
    required this.agendaSummary,
    required this.materialsRequired,
    required this.prework,
    required this.homework,
    required this.capacity,
    required this.waitlistEnabled,
    required this.bookable,
    required this.attendanceRequired,
    required this.completionWeight,
    required this.recordingUrl,
    required this.slidesUrl,
    required this.resources,
    required this.status,
    required this.isUpcoming,
    required this.isLive,
    required this.isCompleted,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'],
      sessionNumber: json['session_number'],
      title: json['title'] ?? '',
      sessionKind:
          SessionKind.values.byNameOrNull(json['session_kind']) ??
          SessionKind.instruction,
      deliveryMode:
          DeliveryMode.values.byNameOrNull(json['delivery_mode']) ??
          DeliveryMode.virtual,
      startAt: json['start_at'] ?? '',
      endAt: json['end_at'] ?? '',
      timezone: json['timezone'] ?? '',
      durationMinutes: json['duration_minutes'],
      venueName: json['venue_name'],
      venueAddress: json['venue_address'],
      meetingLink: json['meeting_link'],
      agendaSummary: json['agenda_summary'],
      materialsRequired: json['materials_required'],
      prework: json['prework'],
      homework: json['homework'],
      capacity: json['capacity'],
      waitlistEnabled: json['waitlist_enabled'] ?? false,
      bookable: json['bookable'] ?? false,
      attendanceRequired: json['attendance_required'] ?? false,
      completionWeight: json['completion_weight']?.toString() ?? '0',
      recordingUrl: json['recording_url'],
      slidesUrl: json['slides_url'],
      resources: json['resources'],
      status:
          SessionStatus.values.byNameOrNull(json['status']) ??
          SessionStatus.draft,
      isUpcoming: json['is_upcoming'] ?? false,
      isLive: json['is_live'] ?? false,
      isCompleted: json['is_completed'] ?? false,
    );
  }
}

---
## File: lib\features\offerings\pages\offering_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontned_laravel/shared/utility/string_extension.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/navigation/app_shell.dart';
import '../../auth/auth_provider.dart';
import '../providers/offering_enrollment_provider.dart';
import '../providers/offering_provider.dart';
import '../widgets/delivery_mode_badge.dart';
import '../widgets/session_timeline.dart';

class OfferingDetailPage extends ConsumerStatefulWidget {
  final String slug;

  const OfferingDetailPage({super.key, required this.slug});

  @override
  ConsumerState<OfferingDetailPage> createState() => _OfferingDetailPageState();
}

class _OfferingDetailPageState extends ConsumerState<OfferingDetailPage> {
  bool _isEnrolling = false;

  Future<void> _enroll(int offeringId) async {
    final user = ref.read(authProvider).valueOrNull;

    if (user == null) {
      context.go('/login?redirect=/offerings/${widget.slug}');

      return;
    }

    setState(() {
      _isEnrolling = true;
    });

    try {
      await ref.read(offeringEnrollmentProvider.notifier).enroll(offeringId);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Enrollment successful')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isEnrolling = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final offeringAsync = ref.watch(offeringDetailProvider(widget.slug));

    return AppShell(
      child: offeringAsync.when(
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },

        error: (error, stackTrace) {
          return Center(child: Text(error.toString()));
        },

        data: (offering) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),

                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(28),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      DeliveryModeBadge(mode: offering.deliveryMode),

                      const SizedBox(height: 20),

                      Text(
                        offering.title,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        offering.workshop?.title ?? '',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey.shade700,
                        ),
                      ),

                      const SizedBox(height: 24),

                      Wrap(
                        spacing: 16,
                        runSpacing: 16,

                        children: [
                          Chip(label: Text(offering.status.name)),

                          Chip(
                            label: Text('${offering.sessions.length} Sessions'),
                          ),

                          if (offering.certificateEnabled)
                            const Chip(label: Text('Certificate Included')),
                        ],
                      ),

                      const SizedBox(height: 28),

                      ElevatedButton(
                        onPressed: _isEnrolling
                            ? null
                            : () => _enroll(offering.id),

                        child: _isEnrolling
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                child: Text('Enroll Now'),
                              ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),

                    border: Border.all(color: Colors.grey.shade300),
                  ),

                  child: Wrap(
                    spacing: 20,
                    runSpacing: 20,

                    children: [
                      _InfoTile(
                        label: 'Sessions',
                        value: '${offering.sessions.length}',
                      ),

                      _InfoTile(
                        label: 'Enrollment Type',
                        value: offering.enrollmentType.name.displayLabel,
                      ),

                      _InfoTile(
                        label: 'Completion Rule',
                        value: offering.completionRule.name.displayLabel,
                      ),

                      _InfoTile(
                        label: 'Selection Rule',
                        value: offering.sessionSelectionRule.name.displayLabel,
                      ),

                      _InfoTile(
                        label: 'Capacity',
                        value: '${offering.capacity ?? '-'}',
                      ),

                      _InfoTile(label: 'Timezone', value: offering.timezone),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                const Text(
                  'Session Timeline',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 24),

                SessionTimeline(sessions: offering.sessions),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

---
## File: lib\features\offerings\providers\offering_enrollment_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'offering_provider.dart';

final offeringEnrollmentProvider =
    StateNotifierProvider<OfferingEnrollmentNotifier, AsyncValue<void>>(
      (ref) => OfferingEnrollmentNotifier(ref),
    );

class OfferingEnrollmentNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  OfferingEnrollmentNotifier(this.ref) : super(const AsyncData(null));

  Future<void> enroll(int offeringId) async {
    state = const AsyncLoading();

    try {
      final service = ref.read(offeringServiceProvider);

      await service.enroll(offeringId);

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

---
## File: lib\features\offerings\providers\offering_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/offering_model.dart';
import '../offering_service.dart';

final offeringServiceProvider = Provider((ref) => OfferingService());

final workshopOfferingsProvider =
    FutureProvider.family<List<OfferingModel>, String>((
      ref,
      workshopSlug,
    ) async {
      final service = ref.read(offeringServiceProvider);

      return service.getWorkshopOfferings(workshopSlug);
    });

final offeringDetailProvider = FutureProvider.family<OfferingModel, String>((
  ref,
  slug,
) async {
  final service = ref.read(offeringServiceProvider);

  return service.getOffering(slug);
});

---
## File: lib\features\offerings\widgets\delivery_mode_badge.dart
import 'package:flutter/material.dart';

import '../../../core/enums.dart';

class DeliveryModeBadge extends StatelessWidget {
  final DeliveryMode mode;

  const DeliveryModeBadge({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    IconData icon;

    switch (mode) {
      case DeliveryMode.virtual:
        icon = Icons.videocam;
        break;

      case DeliveryMode.hybrid:
        icon = Icons.sync;
        break;

      case DeliveryMode.physical:
        icon = Icons.location_on;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(.08),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(mode.name.toUpperCase()),
        ],
      ),
    );
  }
}

---
## File: lib\features\offerings\widgets\offering_card.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/offering_model.dart';
import 'delivery_mode_badge.dart';

class OfferingCard extends StatelessWidget {
  final OfferingModel offering;

  const OfferingCard({super.key, required this.offering});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push('/offerings/${offering.slug}');
      },
      borderRadius: BorderRadius.circular(20),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DeliveryModeBadge(mode: offering.deliveryMode),

              const SizedBox(height: 16),

              Text(
                offering.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text('${offering.sessions.length} Sessions'),

              const SizedBox(height: 8),

              Text('₹ ${offering.price}'),

              const SizedBox(height: 8),

              Text(
                offering.startDate != null
                    ? offering.startDate!.split('T').first
                    : 'Date TBD',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

---
## File: lib\features\offerings\widgets\session_card.dart
import 'package:flutter/material.dart';

import '../../../shared/utility/datetime_extension.dart';
import '../../sessions/widgets/session_reservation_button.dart';
import '../models/session_model.dart';
import 'delivery_mode_badge.dart';
import 'session_kind_badge.dart';

class SessionCard extends StatelessWidget {
  final SessionModel session;

  const SessionCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),

        side: BorderSide(color: Colors.grey.shade300),
      ),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                SessionKindBadge(kind: session.sessionKind),

                const SizedBox(width: 10),

                DeliveryModeBadge(mode: session.deliveryMode),

                const Spacer(),

                _StatusBadge(session: session),
              ],
            ),

            const SizedBox(height: 18),

            Text(
              session.title,

              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.schedule, size: 18),

                const SizedBox(width: 8),

                Expanded(child: Text(session.startAt.rangeTo(session.endAt))),
              ],
            ),

            if (session.venueName != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),

                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 18),

                    const SizedBox(width: 8),

                    Expanded(child: Text(session.venueName!)),
                  ],
                ),
              ),

            if (session.agendaSummary != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),

                child: Text(
                  session.agendaSummary!,
                  style: TextStyle(height: 1.5, color: Colors.grey.shade700),
                ),
              ),

            const SizedBox(height: 20),

            Wrap(
              spacing: 12,
              runSpacing: 12,

              children: [
                if (session.durationMinutes != null)
                  Chip(label: Text('${session.durationMinutes} mins')),

                if (session.attendanceRequired)
                  const Chip(label: Text('Attendance Required')),

                if (session.waitlistEnabled)
                  const Chip(label: Text('Waitlist Enabled')),
              ],
            ),

            const SizedBox(height: 24),

            SessionReservationButton(
              sessionId: session.id,
              bookable: session.bookable,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final SessionModel session;

  const _StatusBadge({required this.session});

  @override
  Widget build(BuildContext context) {
    String label;

    Color color;

    if (session.isLive) {
      label = 'LIVE';
      color = Colors.red;
    } else if (session.isCompleted) {
      label = 'COMPLETED';
      color = Colors.green;
    } else if (session.isUpcoming) {
      label = 'UPCOMING';
      color = Colors.blue;
    } else {
      label = session.status.name.toUpperCase();

      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

      decoration: BoxDecoration(
        color: color.withOpacity(.12),

        borderRadius: BorderRadius.circular(30),
      ),

      child: Text(
        label,

        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

---
## File: lib\features\offerings\widgets\session_kind_badge.dart
import 'package:flutter/material.dart';

import '../../../core/enums.dart';

class SessionKindBadge extends StatelessWidget {
  final SessionKind kind;

  const SessionKindBadge({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(.08),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        kind.name.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

---
## File: lib\features\offerings\widgets\session_timeline.dart
import 'package:flutter/material.dart';

import '../models/session_model.dart';
import 'session_card.dart';

class SessionTimeline extends StatelessWidget {
  final List<SessionModel> sessions;

  const SessionTimeline({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: sessions
          .map(
            (session) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: SessionCard(session: session),
            ),
          )
          .toList(),
    );
  }
}

---
## File: lib\features\offering_enrollments\offering_enrollment_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/utility/datetime_extension.dart';
import '../../shared/utility/string_extension.dart';
import 'offering_enrollment_models.dart';
import 'offering_enrollment_provider.dart';

class OfferingEnrollmentDialog extends ConsumerStatefulWidget {
  final OfferingEnrollmentModel enrollment;

  const OfferingEnrollmentDialog({super.key, required this.enrollment});

  @override
  ConsumerState<OfferingEnrollmentDialog> createState() =>
      _OfferingEnrollmentDialogState();
}

class _OfferingEnrollmentDialogState
    extends ConsumerState<OfferingEnrollmentDialog> {
  bool loading = false;

  Future<void> _issueCertificate() async {
    setState(() {
      loading = true;
    });

    try {
      final service = ref.read(offeringEnrollmentServiceProvider);

      await service.issueCertificate(widget.enrollment.id);

      ref.invalidate(offeringEnrollmentProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Certificate issued successfully')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final enrollment = widget.enrollment;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),

      child: Container(
        width: 700,

        padding: const EdgeInsets.all(32),

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Enrollment Details',

                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              _Section(
                title: 'Learner',

                children: [
                  _InfoRow(label: 'Name', value: enrollment.learnerName),

                  _InfoRow(label: 'Email', value: enrollment.learnerEmail),
                ],
              ),

              const SizedBox(height: 28),

              _Section(
                title: 'Offering',

                children: [
                  _InfoRow(label: 'Title', value: enrollment.offeringTitle),

                  _InfoRow(
                    label: 'Enrolled At',

                    value: enrollment.enrolledAt.readableDateTime,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              _Section(
                title: 'Learning Progress',

                children: [
                  _InfoRow(
                    label: 'Enrollment Status',

                    value: enrollment.enrollmentStatus.name.displayLabel,
                  ),

                  _InfoRow(
                    label: 'Completion Status',

                    value: enrollment.completionStatus.name.displayLabel,
                  ),

                  _InfoRow(
                    label: 'Progress',

                    value:
                        '${enrollment.progressPercentage.toStringAsFixed(0)}%',
                  ),

                  _InfoRow(
                    label: 'Attendance',

                    value:
                        '${enrollment.attendedSessions} / '
                        '${enrollment.requiredSessions}',
                  ),
                ],
              ),

              const SizedBox(height: 28),

              _Section(
                title: 'Certificates',

                children: [
                  _InfoRow(
                    label: 'Eligible',

                    value: enrollment.certificateEligible ? 'Yes' : 'No',
                  ),

                  _InfoRow(
                    label: 'Issued',

                    value: enrollment.certificateIssued ? 'Yes' : 'No',
                  ),
                ],
              ),

              const SizedBox(height: 36),

              if (loading)
                const Center(child: CircularProgressIndicator())
              else if (enrollment.certificateEligible &&
                  !enrollment.certificateIssued)
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    onPressed: _issueCertificate,

                    icon: const Icon(Icons.workspace_premium),

                    label: const Text('Issue Certificate'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;

  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          title,

          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 18),

        ...children,
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;

  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          SizedBox(
            width: 180,

            child: Text(label, style: TextStyle(color: Colors.grey.shade700)),
          ),

          Expanded(
            child: Text(
              value,

              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

---
## File: lib\features\offering_enrollments\offering_enrollment_models.dart
import '../../core/enums.dart';
import '../../shared/utility/enum_extension.dart';
import '../../shared/utility/json_utils.dart';

class OfferingEnrollmentModel {
  final int id;

  final String learnerName;

  final String learnerEmail;

  final String offeringTitle;

  final EnrollmentStatus enrollmentStatus;

  final CompletionStatus completionStatus;

  final double progressPercentage;

  final bool certificateEligible;

  final bool certificateIssued;

  final int attendedSessions;

  final int requiredSessions;

  final String enrolledAt;

  OfferingEnrollmentModel({
    required this.id,
    required this.learnerName,
    required this.learnerEmail,
    required this.offeringTitle,
    required this.enrollmentStatus,
    required this.completionStatus,
    required this.progressPercentage,
    required this.certificateEligible,
    required this.certificateIssued,
    required this.attendedSessions,
    required this.requiredSessions,
    required this.enrolledAt,
  });

  factory OfferingEnrollmentModel.fromJson(Map<String, dynamic> json) {
    final student = json['student'] ?? {};

    final offering = json['offering'] ?? {};

    return OfferingEnrollmentModel(
      id: JsonUtils.parseInt(json['id']) ?? 0,

      learnerName: JsonUtils.parseString(student['name']),

      learnerEmail: JsonUtils.parseString(student['email']),

      offeringTitle: JsonUtils.parseString(offering['title']),

      enrollmentStatus:
          EnrollmentStatus.values.byNameOrNull(json['status']) ??
          EnrollmentStatus.suspended,

      completionStatus:
          CompletionStatus.values.byNameOrNull(json['completion_status']) ??
          CompletionStatus.not_started,

      progressPercentage: JsonUtils.parseDouble(json['progress_percentage']),

      certificateEligible: JsonUtils.parseBool(json['certificate_eligible']),

      certificateIssued: JsonUtils.parseBool(json['certificate_issued']),

      attendedSessions: JsonUtils.parseInt(json['attended_sessions']) ?? 0,

      requiredSessions: JsonUtils.parseInt(json['required_sessions']) ?? 0,

      enrolledAt: JsonUtils.parseString(json['enrolled_at']),
    );
  }
}

---
## File: lib\features\offering_enrollments\offering_enrollment_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/utility/datetime_extension.dart';
import '../../shared/utility/string_extension.dart';
import '../dashboard/widgets/dashboard_shell.dart';
import 'offering_enrollment_dialog.dart';
import 'offering_enrollment_provider.dart';

class AdminOfferingEnrollmentPage extends ConsumerWidget {
  const AdminOfferingEnrollmentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrollmentsAsync = ref.watch(offeringEnrollmentProvider);

    return DashboardShell(
      title: 'Offering Enrollments',

      child: enrollmentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, stackTrace) {
          debugPrint(error.toString());

          debugPrintStack(stackTrace: stackTrace);

          return Center(child: Text(error.toString()));
        },

        data: (enrollments) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: Card(
              elevation: 0,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),

                side: BorderSide(color: Colors.grey.shade300),
              ),

              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,

                child: DataTable(
                  headingRowHeight: 64,

                  dataRowHeight: 72,

                  columns: const [
                    DataColumn(label: Text('Learner')),

                    DataColumn(label: Text('Offering')),

                    DataColumn(label: Text('Enrollment')),

                    DataColumn(label: Text('Completion')),

                    DataColumn(label: Text('Progress')),

                    DataColumn(label: Text('Attendance')),

                    DataColumn(label: Text('Certificate')),

                    DataColumn(label: Text('Enrolled')),
                  ],

                  rows: enrollments.map((enrollment) {
                    return DataRow(
                      onSelectChanged: (_) {
                        showDialog(
                          context: context,

                          builder: (_) {
                            return OfferingEnrollmentDialog(
                              enrollment: enrollment,
                            );
                          },
                        );
                      },

                      cells: [
                        DataCell(
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,

                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                enrollment.learnerName,

                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                enrollment.learnerEmail,

                                style: TextStyle(
                                  fontSize: 12,

                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        DataCell(
                          SizedBox(
                            width: 240,

                            child: Text(enrollment.offeringTitle),
                          ),
                        ),

                        DataCell(
                          Chip(
                            backgroundColor:
                                enrollment.enrollmentStatus.name == 'cancelled'
                                ? Colors.red.withOpacity(.1)
                                : null,

                            label: Text(
                              enrollment.enrollmentStatus.name.displayLabel,
                            ),
                          ),
                        ),

                        DataCell(
                          Chip(
                            label: Text(
                              enrollment.completionStatus.name.displayLabel,
                            ),
                          ),
                        ),

                        DataCell(
                          SizedBox(
                            width: 120,

                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,

                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),

                                  child: LinearProgressIndicator(
                                    minHeight: 8,

                                    value: enrollment.progressPercentage / 100,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  '${enrollment.progressPercentage.toStringAsFixed(0)}%',
                                ),
                              ],
                            ),
                          ),
                        ),

                        DataCell(
                          Text(
                            '${enrollment.attendedSessions} / '
                            '${enrollment.requiredSessions}',
                          ),
                        ),

                        DataCell(
                          Icon(
                            enrollment.certificateIssued
                                ? Icons.verified
                                : enrollment.certificateEligible
                                ? Icons.workspace_premium
                                : Icons.hourglass_bottom,

                            color: enrollment.certificateIssued
                                ? Colors.green
                                : enrollment.certificateEligible
                                ? Colors.orange
                                : Colors.grey,
                          ),
                        ),

                        DataCell(Text(enrollment.enrolledAt.readableDate)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

---
## File: lib\features\offering_enrollments\offering_enrollment_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'offering_enrollment_models.dart';
import 'offering_enrollment_service.dart';

final offeringEnrollmentServiceProvider = Provider(
  (ref) => OfferingEnrollmentService(),
);

final offeringEnrollmentProvider =
    FutureProvider<List<OfferingEnrollmentModel>>((ref) async {
      final service = ref.read(offeringEnrollmentServiceProvider);

      return service.fetchEnrollments();
    });

final offeringEnrollmentSearchProvider = StateProvider<String>((ref) => '');

---
## File: lib\features\offering_enrollments\offering_enrollment_service.dart
import '../../core/api_client.dart';
import 'offering_enrollment_models.dart';

class OfferingEnrollmentService {
  final ApiClient _apiClient = ApiClient();

  Future<List<OfferingEnrollmentModel>> fetchEnrollments() async {
    final response = await _apiClient.get('/v1/admin/offering-enrollments');

    final data = response['data'] as List<dynamic>;

    return data.map((e) => OfferingEnrollmentModel.fromJson(e)).toList();
  }

  Future<void> issueCertificate(int enrollmentId) async {
    await _apiClient.post('/v1/admin/enrollments/$enrollmentId/certificate');
  }
}

---
## File: lib\features\offering_management\offering_form_dialog.dart
import 'package:flutter/material.dart';

import 'offering_management_models.dart';
import 'offering_management_service.dart';

class OfferingFormDialog extends StatefulWidget {
  final AdminOffering? offering;

  const OfferingFormDialog({super.key, this.offering});

  @override
  State<OfferingFormDialog> createState() => _OfferingFormDialogState();
}

class _OfferingFormDialogState extends State<OfferingFormDialog> {
  final _formKey = GlobalKey<FormState>();

  final _service = OfferingManagementService();

  late TextEditingController _titleController;

  late TextEditingController _slugController;

  String _status = 'published';

  String _deliveryMode = 'virtual';

  bool _certificateEnabled = true;

  bool _loading = false;

  bool get isEdit => widget.offering != null;

  @override
  void initState() {
    super.initState();

    final offering = widget.offering;

    _titleController = TextEditingController(text: offering?.title ?? '');

    _slugController = TextEditingController(text: offering?.slug ?? '');

    if (offering != null) {
      _status = offering.status;

      _deliveryMode = offering.deliveryMode;

      _certificateEnabled = offering.certificateEnabled;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final data = {
        'title': _titleController.text,

        'slug': _slugController.text,

        'status': _status,

        'delivery_mode': _deliveryMode,

        'certificate_enabled': _certificateEnabled,
      };

      if (isEdit) {
        await _service.updateOffering(
          offeringId: widget.offering!.id,

          data: data,
        );
      } else {
        await _service.createOffering(data: data);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,

        padding: const EdgeInsets.all(32),

        child: Form(
          key: _formKey,

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Text(
                isEdit ? 'Edit Offering' : 'Create Offering',

                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 32),

              TextFormField(
                controller: _titleController,

                decoration: const InputDecoration(labelText: 'Title'),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: _slugController,

                decoration: const InputDecoration(labelText: 'Slug'),
              ),

              const SizedBox(height: 24),

              DropdownButtonFormField<String>(
                value: _status,

                items: const [
                  DropdownMenuItem(
                    value: 'published',

                    child: Text('Published'),
                  ),

                  DropdownMenuItem(value: 'draft', child: Text('Draft')),
                ],

                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },

                decoration: const InputDecoration(labelText: 'Status'),
              ),

              const SizedBox(height: 24),

              DropdownButtonFormField<String>(
                value: _deliveryMode,

                items: const [
                  DropdownMenuItem(value: 'virtual', child: Text('Virtual')),

                  DropdownMenuItem(value: 'physical', child: Text('Physical')),

                  DropdownMenuItem(value: 'hybrid', child: Text('Hybrid')),
                ],

                onChanged: (value) {
                  setState(() {
                    _deliveryMode = value!;
                  });
                },

                decoration: const InputDecoration(labelText: 'Delivery Mode'),
              ),

              const SizedBox(height: 24),

              SwitchListTile(
                value: _certificateEnabled,

                onChanged: (value) {
                  setState(() {
                    _certificateEnabled = value;
                  });
                },

                title: const Text('Certificate Enabled'),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,

                  child: _loading
                      ? const CircularProgressIndicator()
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18),

                          child: Text(
                            isEdit ? 'Update Offering' : 'Create Offering',
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

---
## File: lib\features\offering_management\offering_management_models.dart
class AdminOffering {
  final int id;

  final String title;

  final String slug;

  final String status;

  final String deliveryMode;

  final String? startDate;

  final String? endDate;

  final int sessionsCount;

  final int enrollmentsCount;

  final bool certificateEnabled;

  AdminOffering({
    required this.id,
    required this.title,
    required this.slug,
    required this.status,
    required this.deliveryMode,
    required this.startDate,
    required this.endDate,
    required this.sessionsCount,
    required this.enrollmentsCount,
    required this.certificateEnabled,
  });

  factory AdminOffering.fromJson(Map<String, dynamic> json) {
    return AdminOffering(
      id: json['id'],

      title: json['title'] ?? '',

      slug: json['slug'] ?? '',

      status: json['status'] ?? '',

      deliveryMode: json['delivery_mode'] ?? '',

      startDate: json['start_date'],

      endDate: json['end_date'],

      sessionsCount: json['sessions_count'] ?? 0,

      enrollmentsCount: json['enrollments_count'] ?? 0,

      certificateEnabled: json['certificate_enabled'] ?? false,
    );
  }
}

class AdminSession {
  final int id;

  final String title;

  final String sessionKind;

  final String status;

  final String startAt;

  final String endAt;

  final int reservationsCount;

  final bool attendanceRequired;

  AdminSession({
    required this.id,
    required this.title,
    required this.sessionKind,
    required this.status,
    required this.startAt,
    required this.endAt,
    required this.reservationsCount,
    required this.attendanceRequired,
  });

  factory AdminSession.fromJson(Map<String, dynamic> json) {
    return AdminSession(
      id: json['id'],

      title: json['title'] ?? '',

      sessionKind: json['session_kind'] ?? '',

      status: json['status'] ?? '',

      startAt: json['start_at'] ?? '',

      endAt: json['end_at'] ?? '',

      reservationsCount: json['reservations_count'] ?? 0,

      attendanceRequired: json['attendance_required'] ?? false,
    );
  }
}

---
## File: lib\features\offering_management\offering_management_page.dart
import 'package:flutter/material.dart';

import '../../../shared/utility/string_extension.dart';
import '../../shared/responsive_layout.dart';
import '../dashboard/widgets/dashboard_shell.dart';
import 'offering_form_dialog.dart';
import 'offering_management_models.dart';
import 'offering_management_service.dart';
import 'session_management_page.dart';

class OfferingManagementPage extends StatefulWidget {
  const OfferingManagementPage({super.key});

  @override
  State<OfferingManagementPage> createState() => _OfferingManagementPageState();
}

class _OfferingManagementPageState extends State<OfferingManagementPage> {
  final _service = OfferingManagementService();

  bool _loading = true;

  List<AdminOffering> offerings = [];

  @override
  void initState() {
    super.initState();

    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });

    try {
      offerings = await _service.fetchOfferings();
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _createOffering() async {
    final created = await showDialog<bool>(
      context: context,

      builder: (_) {
        return const OfferingFormDialog();
      },
    );

    if (created == true) {
      _load();
    }
  }

  Future<void> _editOffering(AdminOffering offering) async {
    final updated = await showDialog<bool>(
      context: context,

      builder: (_) {
        return OfferingFormDialog(offering: offering);
      },
    );

    if (updated == true) {
      _load();
    }
  }

  Future<void> _deleteOffering(AdminOffering offering) async {
    final confirmed =
        await showDialog<bool>(
          context: context,

          builder: (_) {
            return AlertDialog(
              title: const Text('Delete Offering'),

              content: Text('Delete "${offering.title}"?'),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },

                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },

                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    await _service.deleteOffering(offering.id);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Offering deleted')));
    }

    _load();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: 'Offerings',

      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),

              ElevatedButton.icon(
                onPressed: _createOffering,

                icon: const Icon(Icons.add),

                label: const Text('Create Offering'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    itemCount: offerings.length,

                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          ResponsiveLayout.isDesktop(
                            MediaQuery.of(context).size.width,
                          )
                          ? 3
                          : 1,

                      crossAxisSpacing: 20,

                      mainAxisSpacing: 20,

                      mainAxisExtent: 280,
                    ),

                    itemBuilder: (context, index) {
                      final offering = offerings[index];

                      return Card(
                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),

                          side: BorderSide(color: Colors.grey.shade300),
                        ),

                        child: Padding(
                          padding: const EdgeInsets.all(24),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Chip(label: Text(offering.status.displayLabel)),

                              const SizedBox(height: 18),

                              Text(
                                offering.title,

                                style: const TextStyle(
                                  fontSize: 22,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 14),

                              Text(offering.deliveryMode),

                              const Spacer(),

                              Text('${offering.sessionsCount} Sessions'),

                              const SizedBox(height: 8),

                              Text('${offering.enrollmentsCount} Enrollments'),

                              const SizedBox(height: 24),

                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,

                                          MaterialPageRoute(
                                            builder: (_) =>
                                                SessionManagementPage(
                                                  offering: offering,
                                                ),
                                          ),
                                        );
                                      },

                                      child: const Text('Sessions'),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  IconButton(
                                    onPressed: () => _editOffering(offering),

                                    icon: const Icon(Icons.edit),
                                  ),

                                  IconButton(
                                    onPressed: () => _deleteOffering(offering),

                                    icon: const Icon(Icons.delete),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

---
## File: lib\features\offering_management\offering_management_service.dart
import '../../core/api_client.dart';
import 'offering_management_models.dart';

class OfferingManagementService {
  final ApiClient _apiClient = ApiClient();

  Future<List<AdminOffering>> fetchOfferings() async {
    final response = await _apiClient.get('/v1/admin/offerings');

    final data = response['data'] as List<dynamic>;

    return data.map((e) => AdminOffering.fromJson(e)).toList();
  }

  Future<void> createOffering({required Map<String, dynamic> data}) async {
    await _apiClient.post('/v1/admin/offerings', data: data);
  }

  Future<void> updateOffering({
    required int offeringId,
    required Map<String, dynamic> data,
  }) async {
    await _apiClient.put('/v1/admin/offerings/$offeringId', data: data);
  }

  Future<void> deleteOffering(int offeringId) async {
    await _apiClient.delete('/v1/admin/offerings/$offeringId');
  }

  Future<List<AdminSession>> fetchSessions(int offeringId) async {
    final response = await _apiClient.get(
      '/v1/admin/offerings/$offeringId/sessions',
    );

    final data = response['data'] as List<dynamic>;

    return data.map((e) => AdminSession.fromJson(e)).toList();
  }

  Future<void> createSession({
    required int offeringId,
    required Map<String, dynamic> data,
  }) async {
    await _apiClient.post(
      '/v1/admin/offerings/$offeringId/sessions',
      data: data,
    );
  }

  Future<void> updateSession({
    required int sessionId,
    required Map<String, dynamic> data,
  }) async {
    await _apiClient.put('/v1/admin/sessions/$sessionId', data: data);
  }

  Future<void> deleteSession(int sessionId) async {
    await _apiClient.delete('/v1/admin/sessions/$sessionId');
  }
}

---
## File: lib\features\offering_management\session_form_dialog.dart
import 'package:flutter/material.dart';

import '../../../shared/utility/enum_extension.dart';
import '../../core/enums.dart';
import 'offering_management_models.dart';
import 'offering_management_service.dart';

class SessionFormDialog extends StatefulWidget {
  final int offeringId;

  final AdminSession? session;

  const SessionFormDialog({super.key, required this.offeringId, this.session});

  @override
  State<SessionFormDialog> createState() => _SessionFormDialogState();
}

class _SessionFormDialogState extends State<SessionFormDialog> {
  final _formKey = GlobalKey<FormState>();

  final _service = OfferingManagementService();

  late TextEditingController _titleController;

  late TextEditingController _startAtController;

  late TextEditingController _endAtController;

  SessionKind _sessionKind = SessionKind.instruction;

  SessionStatus _status = SessionStatus.scheduled;

  bool _attendanceRequired = true;

  bool _loading = false;

  bool get isEdit => widget.session != null;

  @override
  void initState() {
    super.initState();

    final session = widget.session;

    _titleController = TextEditingController(text: session?.title ?? '');

    _startAtController = TextEditingController(text: session?.startAt ?? '');

    _endAtController = TextEditingController(text: session?.endAt ?? '');

    if (session != null) {
      _attendanceRequired = session.attendanceRequired;

      _sessionKind =
          SessionKind.values.byNameOrNull(session.sessionKind) ??
          SessionKind.instruction;

      _status =
          SessionStatus.values.byNameOrNull(session.status) ??
          SessionStatus.draft;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final data = {
        'title': _titleController.text,

        'session_kind': _sessionKind.name,

        'status': _status.name,

        'start_at': _startAtController.text,

        'end_at': _endAtController.text,

        'attendance_required': _attendanceRequired,
      };

      if (isEdit) {
        await _service.updateSession(sessionId: widget.session!.id, data: data);
      } else {
        await _service.createSession(offeringId: widget.offeringId, data: data);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 700,

        padding: const EdgeInsets.all(32),

        child: Form(
          key: _formKey,

          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                Text(
                  isEdit ? 'Edit Session' : 'Create Session',

                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 32),

                TextFormField(
                  controller: _titleController,

                  decoration: const InputDecoration(labelText: 'Session Title'),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 24),

                DropdownButtonFormField<SessionKind>(
                  value: _sessionKind,

                  items: SessionKind.values
                      .map(
                        (e) => DropdownMenuItem(value: e, child: Text(e.name)),
                      )
                      .toList(),

                  onChanged: (value) {
                    setState(() {
                      _sessionKind = value!;
                    });
                  },

                  decoration: const InputDecoration(labelText: 'Session Kind'),
                ),

                const SizedBox(height: 24),

                DropdownButtonFormField<SessionStatus>(
                  value: _status,

                  items: SessionStatus.values
                      .map(
                        (e) => DropdownMenuItem(value: e, child: Text(e.name)),
                      )
                      .toList(),

                  onChanged: (value) {
                    setState(() {
                      _status = value!;
                    });
                  },

                  decoration: const InputDecoration(labelText: 'Status'),
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: _startAtController,

                  decoration: const InputDecoration(labelText: 'Start At'),
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: _endAtController,

                  decoration: const InputDecoration(labelText: 'End At'),
                ),

                const SizedBox(height: 24),

                SwitchListTile(
                  value: _attendanceRequired,

                  onChanged: (value) {
                    setState(() {
                      _attendanceRequired = value;
                    });
                  },

                  title: const Text('Attendance Required'),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,

                    child: _loading
                        ? const CircularProgressIndicator()
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18),

                            child: Text(
                              isEdit ? 'Update Session' : 'Create Session',
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

---
## File: lib\features\offering_management\session_management_page.dart
import 'package:flutter/material.dart';

import '../../../shared/utility/string_extension.dart';
import '../../shared/responsive_layout.dart';
import '../dashboard/widgets/dashboard_shell.dart';
import 'offering_management_models.dart';
import 'offering_management_service.dart';
import 'session_form_dialog.dart';

class SessionManagementPage extends StatefulWidget {
  final AdminOffering offering;

  const SessionManagementPage({super.key, required this.offering});

  @override
  State<SessionManagementPage> createState() => _SessionManagementPageState();
}

class _SessionManagementPageState extends State<SessionManagementPage> {
  final _service = OfferingManagementService();

  bool _loading = true;

  List<AdminSession> sessions = [];

  @override
  void initState() {
    super.initState();

    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });

    try {
      sessions = await _service.fetchSessions(widget.offering.id);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _createSession() async {
    final created = await showDialog<bool>(
      context: context,

      builder: (_) {
        return SessionFormDialog(offeringId: widget.offering.id);
      },
    );

    if (created == true) {
      _load();
    }
  }

  Future<void> _editSession(AdminSession session) async {
    final updated = await showDialog<bool>(
      context: context,

      builder: (_) {
        return SessionFormDialog(
          offeringId: widget.offering.id,

          session: session,
        );
      },
    );

    if (updated == true) {
      _load();
    }
  }

  Future<void> _deleteSession(AdminSession session) async {
    final confirmed =
        await showDialog<bool>(
          context: context,

          builder: (_) {
            return AlertDialog(
              title: const Text('Delete Session'),

              content: Text('Delete "${session.title}"?'),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },

                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },

                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    await _service.deleteSession(session.id);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Session deleted')));
    }

    _load();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: '${widget.offering.title} Sessions',

      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),

              ElevatedButton.icon(
                onPressed: _createSession,

                icon: const Icon(Icons.add),

                label: const Text('Create Session'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    itemCount: sessions.length,

                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          ResponsiveLayout.isDesktop(
                            MediaQuery.of(context).size.width,
                          )
                          ? 3
                          : 1,

                      crossAxisSpacing: 20,

                      mainAxisSpacing: 20,

                      mainAxisExtent: 300,
                    ),

                    itemBuilder: (context, index) {
                      final session = sessions[index];

                      return Card(
                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),

                          side: BorderSide(color: Colors.grey.shade300),
                        ),

                        child: Padding(
                          padding: const EdgeInsets.all(24),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Chip(label: Text(session.status.displayLabel)),

                              const SizedBox(height: 18),

                              Text(
                                session.title,

                                style: const TextStyle(
                                  fontSize: 22,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 14),

                              Text(session.sessionKind),

                              const SizedBox(height: 10),

                              Text(session.startAt),

                              const Spacer(),

                              Text('${session.reservationsCount} Reservations'),

                              const SizedBox(height: 10),

                              if (session.attendanceRequired)
                                const Chip(label: Text('Attendance Required')),

                              const SizedBox(height: 20),

                              Row(
                                children: [
                                  const Spacer(),

                                  IconButton(
                                    onPressed: () => _editSession(session),

                                    icon: const Icon(Icons.edit),
                                  ),

                                  IconButton(
                                    onPressed: () => _deleteSession(session),

                                    icon: const Icon(Icons.delete),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

---
## File: lib\features\progress\learner_progress_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/responsive_layout.dart';
import '../dashboard/widgets/dashboard_shell.dart';
import 'progress_provider.dart';
import 'progress_summary_card.dart';
import 'progress_timeline_card.dart';

class LearnerProgressPage extends ConsumerWidget {
  const LearnerProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressProvider);

    final width = MediaQuery.of(context).size.width;

    return DashboardShell(
      title: 'Progress',

      child: progressAsync.when(
        data: (items) {
          return GridView.builder(
            padding: const EdgeInsets.all(24),

            itemCount: items.length,

            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveLayout.gridCount(width),

              crossAxisSpacing: 20,

              mainAxisSpacing: 20,

              mainAxisExtent: 380,
            ),

            itemBuilder: (context, index) {
              final item = items[index];

              return Column(
                children: [
                  Expanded(child: ProgressSummaryCard(progress: item)),

                  const SizedBox(height: 20),

                  ProgressTimelineCard(
                    attended: item.attendedSessions,

                    required: item.requiredSessions,

                    total: item.totalSessions,
                  ),
                ],
              );
            },
          );
        },

        error: (error, _) => Center(child: Text(error.toString())),

        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

---
## File: lib\features\progress\progress_models.dart
import '../../core/enums.dart';
import '../../shared/utility/enum_extension.dart';
import '../../shared/utility/json_utils.dart';

class ProgressModel {
  final int enrollmentId;

  final String offeringTitle;

  final double progressPercentage;

  final CompletionStatus completionStatus;

  final bool certificateEligible;

  final bool certificateIssued;

  final int attendedSessions;

  final int totalSessions;

  final int requiredSessions;

  ProgressModel({
    required this.enrollmentId,
    required this.offeringTitle,
    required this.progressPercentage,
    required this.completionStatus,
    required this.certificateEligible,
    required this.certificateIssued,
    required this.attendedSessions,
    required this.totalSessions,
    required this.requiredSessions,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      enrollmentId: JsonUtils.parseInt(json['id']) ?? 0,

      offeringTitle: json['offering']?['title'] ?? '',

      progressPercentage: JsonUtils.parseDouble(json['progress_percentage']),

      completionStatus:
          CompletionStatus.values.byNameOrNull(json['completion_status']) ??
          CompletionStatus.not_started,

      certificateEligible: json['certificate_eligible'] ?? false,

      certificateIssued: json['certificate_issued'] ?? false,

      attendedSessions: JsonUtils.parseInt(json['attended_sessions']) ?? 0,

      totalSessions: JsonUtils.parseInt(json['total_sessions']) ?? 0,

      requiredSessions: JsonUtils.parseInt(json['required_sessions']) ?? 0,
    );
  }
}

---
## File: lib\features\progress\progress_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'progress_models.dart';
import 'progress_service.dart';

final progressServiceProvider = Provider((ref) => ProgressService());

final progressProvider = FutureProvider<List<ProgressModel>>((ref) async {
  final service = ref.read(progressServiceProvider);

  return service.fetchProgress();
});

---
## File: lib\features\progress\progress_service.dart
import '../../core/api_client.dart';
import 'progress_models.dart';

class ProgressService {
  final ApiClient _apiClient = ApiClient();

  Future<List<ProgressModel>> fetchProgress() async {
    final response = await _apiClient.get('/v1/me/offering-enrollments');

    final data = response['data'] as List<dynamic>;

    return data.map((e) => ProgressModel.fromJson(e)).toList();
  }
}

---
## File: lib\features\progress\progress_summary_card.dart
import 'package:flutter/material.dart';

import '../../shared/utility/string_extension.dart';
import 'progress_models.dart';

class ProgressSummaryCard extends StatelessWidget {
  final ProgressModel progress;

  const ProgressSummaryCard({super.key, required this.progress});

  Color get progressColor {
    if (progress.progressPercentage >= 100) {
      return Colors.green;
    }

    if (progress.progressPercentage >= 60) {
      return Colors.orange;
    }

    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),

        side: BorderSide(color: Colors.grey.shade300),
      ),

      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              progress.offeringTitle,

              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            LinearProgressIndicator(
              value: progress.progressPercentage / 100,

              color: progressColor,

              minHeight: 10,
            ),

            const SizedBox(height: 18),

            Text('${progress.progressPercentage.toStringAsFixed(0)}% Complete'),

            const SizedBox(height: 10),

            Text(
              '${progress.attendedSessions} / '
              '${progress.requiredSessions} '
              'Required Sessions Attended',
            ),

            const SizedBox(height: 20),

            Wrap(
              spacing: 12,
              runSpacing: 12,

              children: [
                Chip(label: Text(progress.completionStatus.name.displayLabel)),

                Chip(
                  label: Text(
                    progress.certificateEligible
                        ? 'Certificate Eligible'
                        : 'Not Eligible Yet',
                  ),
                ),

                if (progress.certificateIssued)
                  const Chip(label: Text('Certificate Issued')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

---
## File: lib\features\progress\progress_timeline_card.dart
import 'package:flutter/material.dart';

class ProgressTimelineCard extends StatelessWidget {
  final int attended;

  final int required;

  final int total;

  const ProgressTimelineCard({
    super.key,
    required this.attended,
    required this.required,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),

        side: BorderSide(color: Colors.grey.shade300),
      ),

      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Learning Progress',

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            _buildRow(label: 'Sessions Attended', value: '$attended / $total'),

            _buildRow(label: 'Required Sessions', value: '$required'),

            _buildRow(
              label: 'Remaining Sessions',

              value: '${required - attended}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(label),

          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

---
## File: lib\features\schedule\schedule_models.dart
class ScheduledSession {
  final int id;

  final String title;

  final String offeringTitle;

  final String sessionKind;

  final String status;

  final String reservationStatus;

  final String startAt;

  final String endAt;

  final bool isLive;

  final bool attended;

  final bool missed;

  ScheduledSession({
    required this.id,
    required this.title,
    required this.offeringTitle,
    required this.sessionKind,
    required this.status,
    required this.reservationStatus,
    required this.startAt,
    required this.endAt,
    required this.isLive,
    required this.attended,
    required this.missed,
  });

  factory ScheduledSession.fromJson(Map<String, dynamic> json) {
    return ScheduledSession(
      id: json['id'],

      title: json['title'] ?? '',

      offeringTitle: json['offering_title'] ?? '',

      sessionKind: json['session_kind'] ?? '',

      status: json['status'] ?? '',

      reservationStatus: json['reservation_status'] ?? '',

      startAt: json['start_at'] ?? '',

      endAt: json['end_at'] ?? '',

      isLive: json['is_live'] ?? false,

      attended: json['attended'] ?? false,

      missed: json['missed'] ?? false,
    );
  }
}

---
## File: lib\features\schedule\schedule_page.dart
import 'package:flutter/material.dart';

import '../../shared/responsive_layout.dart';
import '../dashboard/widgets/dashboard_shell.dart';
import 'schedule_models.dart';
import 'schedule_service.dart';
import 'schedule_session_card.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final _service = ScheduleService();

  bool _loading = true;

  List<ScheduledSession> sessions = [];

  @override
  void initState() {
    super.initState();

    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });

    try {
      sessions = await _service.fetchSchedule();
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return DashboardShell(
      title: 'My Schedule',

      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(24),

              itemCount: sessions.length,

              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveLayout.gridCount(width),

                crossAxisSpacing: 20,

                mainAxisSpacing: 20,

                mainAxisExtent: 320,
              ),

              itemBuilder: (context, index) {
                return ScheduleSessionCard(session: sessions[index]);
              },
            ),
    );
  }
}

---
## File: lib\features\schedule\schedule_service.dart
import '../../core/api_client.dart';
import 'schedule_models.dart';

class ScheduleService {
  final ApiClient _apiClient = ApiClient();

  Future<List<ScheduledSession>> fetchSchedule() async {
    final response = await _apiClient.get('/v1/me/schedule');

    final data = response['data'] as List<dynamic>;

    return data.map((e) => ScheduledSession.fromJson(e)).toList();
  }
}

---
## File: lib\features\schedule\schedule_session_card.dart
import 'package:flutter/material.dart';

import 'schedule_models.dart';

class ScheduleSessionCard extends StatelessWidget {
  final ScheduledSession session;

  const ScheduleSessionCard({super.key, required this.session});

  Color get statusColor {
    if (session.isLive) {
      return Colors.red;
    }

    if (session.attended) {
      return Colors.green;
    }

    if (session.missed) {
      return Colors.orange;
    }

    return Colors.blue;
  }

  String get statusLabel {
    if (session.isLive) {
      return 'LIVE';
    }

    if (session.attended) {
      return 'ATTENDED';
    }

    if (session.missed) {
      return 'MISSED';
    }

    return session.reservationStatus.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),

        side: BorderSide(color: Colors.grey.shade300),
      ),

      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

              decoration: BoxDecoration(
                color: statusColor.withOpacity(.12),

                borderRadius: BorderRadius.circular(30),
              ),

              child: Text(
                statusLabel,

                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              session.title,

              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text(session.offeringTitle),

            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(Icons.schedule, size: 18),

                const SizedBox(width: 8),

                Expanded(child: Text(session.startAt)),
              ],
            ),

            const Spacer(),

            if (session.isLive)
              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  onPressed: () {},

                  icon: const Icon(Icons.play_arrow),

                  label: const Text('Join Session'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

---
## File: lib\features\sessions\session_reservation_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_reservation_service.dart';

final sessionReservationServiceProvider = Provider(
  (ref) => SessionReservationService(),
);

final sessionReservationProvider =
    StateNotifierProvider<SessionReservationNotifier, AsyncValue<void>>(
      (ref) => SessionReservationNotifier(ref),
    );

class SessionReservationNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  SessionReservationNotifier(this.ref) : super(const AsyncData(null));

  Future<void> reserveSession(int sessionId) async {
    state = const AsyncLoading();

    try {
      final service = ref.read(sessionReservationServiceProvider);

      await service.reserveSession(sessionId);

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

---
## File: lib\features\sessions\session_reservation_service.dart
import '../../../core/api_client.dart';

class SessionReservationService {
  final ApiClient _apiClient = ApiClient();

  Future<void> reserveSession(int sessionId) async {
    await _apiClient.post('/v1/me/sessions/$sessionId/reserve');
  }

  Future<void> cancelReservation(int reservationId) async {
    await _apiClient.post('/v1/me/session-reservations/$reservationId/cancel');
  }
}

---
## File: lib\features\sessions\widgets\session_reservation_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/auth_provider.dart';
import '../session_reservation_provider.dart';

class SessionReservationButton extends ConsumerStatefulWidget {
  final int sessionId;
  final bool bookable;

  const SessionReservationButton({
    super.key,
    required this.sessionId,
    required this.bookable,
  });

  @override
  ConsumerState<SessionReservationButton> createState() =>
      _SessionReservationButtonState();
}

class _SessionReservationButtonState
    extends ConsumerState<SessionReservationButton> {
  bool _loading = false;

  Future<void> _reserve() async {
    final user = ref.read(authProvider).valueOrNull;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first')));

      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await ref
          .read(sessionReservationProvider.notifier)
          .reserveSession(widget.sessionId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session reserved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.bookable) {
      return OutlinedButton(onPressed: null, child: const Text('Not Bookable'));
    }

    return ElevatedButton(
      onPressed: _loading ? null : _reserve,

      child: _loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Reserve Seat'),
    );
  }
}

---
## File: lib\features\session_management\session_form_dialog.dart

---
## File: lib\features\session_management\session_management_models.dart
class ManagedSession {
  final int id;
  final int workshopOfferingId;
  final int? sessionNumber;

  final String title;
  final String sessionKind;
  final String deliveryMode;

  final String startAt;
  final String endAt;

  final String status;

  ManagedSession({
    required this.id,
    required this.workshopOfferingId,
    required this.sessionNumber,
    required this.title,
    required this.sessionKind,
    required this.deliveryMode,
    required this.startAt,
    required this.endAt,
    required this.status,
  });

  factory ManagedSession.fromJson(Map<String, dynamic> json) {
    return ManagedSession(
      id: json['id'],
      workshopOfferingId:
          json['workshop_offering_id'] ?? json['offering']?['id'] ?? 0,
      sessionNumber: json['session_number'],
      title: json['title'] ?? '',
      sessionKind: json['session_kind'] ?? '',
      deliveryMode: json['delivery_mode'] ?? '',
      startAt: json['start_at'] ?? '',
      endAt: json['end_at'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

---
## File: lib\features\session_management\session_management_page.dart

---
## File: lib\features\session_management\session_management_service.dart
final sessionManagementServiceProvider = Provider(
  (ref) => SessionManagementService(),
);

class SessionManagementService {
  final ApiClient _apiClient = ApiClient();

  Future<List<ManagedSession>> fetchSessions() async {
    final response = await _apiClient.get('/v1/admin/sessions');

    final apiResponse = ApiResponse.fromJson(response, (data) {
      final items = data as List;

      return items.map((e) => ManagedSession.fromJson(e)).toList();
    });

    return apiResponse.data;
  }

  Future<void> deleteSession(int id) async {
    await _apiClient.delete('/v1/admin/sessions/$id');
  }

  Future<void> createSession(Map<String, dynamic> payload) async {
    await _apiClient.post('/v1/admin/sessions', data: payload);
  }

  Future<void> updateSession(int id, Map<String, dynamic> payload) async {
    await _apiClient.put('/v1/admin/sessions/$id', data: payload);
  }
}

---
## File: lib\features\workshops\workshop_models.dart
class Workshop {
  final int id;
  final String title;
  final String slug;

  final String? shortDescription;
  final String? fullDescription;
  final String? thumbnail;
  final String? thumbnailUrl;
  final String? videoUrl;
  final String price;
  final String status;
  final bool isFeatured;
  final WorkshopCategory? category;

  Workshop({
    required this.id,
    required this.title,
    required this.slug,
    required this.shortDescription,
    required this.fullDescription,
    required this.thumbnail,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.price,
    required this.status,
    required this.isFeatured,
    required this.category,
  });

  factory Workshop.fromJson(Map<String, dynamic> json) {
    return Workshop(
      id: json['id'],

      title: json['title'] ?? '',

      slug: json['slug'] ?? '',

      shortDescription: json['short_description'],

      fullDescription: json['full_description'],
      thumbnail: json['thumbnail'],

      thumbnailUrl: json['thumbnail_url'],

      videoUrl: json['video_url'],
      price: json['price'] ?? '0',
      status: json['status'] ?? '',

      isFeatured: json['is_featured'] == 1,

      category: json['category'] != null
          ? WorkshopCategory.fromJson(json['category'])
          : null,
    );
  }
}

class WorkshopCategory {
  final int id;

  final String name;

  WorkshopCategory({required this.id, required this.name});

  factory WorkshopCategory.fromJson(Map<String, dynamic> json) {
    return WorkshopCategory(id: json['id'], name: json['name'] ?? '');
  }
}

---
## File: lib\features\workshops\workshop_pagination.dart
import 'workshop_models.dart';

class WorkshopPagination {
  final List<Workshop> workshops;

  final int currentPage;
  final int lastPage;

  WorkshopPagination({
    required this.workshops,
    required this.currentPage,
    required this.lastPage,
  });

  factory WorkshopPagination.fromJson(Map<String, dynamic> json) {
    final items = json['data'] as List;

    return WorkshopPagination(
      workshops: items.map((item) => Workshop.fromJson(item)).toList(),

      currentPage: json['current_page'] ?? 1,

      lastPage: json['last_page'] ?? 1,
    );
  }
}

---
## File: lib\features\workshops\workshop_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontned_laravel/features/workshops/workshop_pagination.dart';

import 'workshop_models.dart';
import 'workshop_service.dart';

final workshopServiceProvider = Provider((ref) => WorkshopService());
final searchProvider = StateProvider<String>((ref) => '');

final selectedCategoryProvider = StateProvider<int?>((ref) => null);
final workshopsProvider = FutureProvider<WorkshopPagination>((ref) async {
  final service = ref.read(workshopServiceProvider);

  final search = ref.watch(searchProvider);

  final categoryId = ref.watch(selectedCategoryProvider);

  return service.fetchWorkshops(search: search, categoryId: categoryId);
});

final workshopDetailProvider = FutureProvider.family<Workshop, String>((
  ref,
  slug,
) async {
  final service = ref.read(workshopServiceProvider);

  return service.fetchWorkshopDetail(slug);
});
final currentPageProvider = StateProvider<int>((ref) => 1);

---
## File: lib\features\workshops\workshop_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/api_response.dart';
import 'workshop_models.dart';
import 'workshop_pagination.dart';

final workshopServiceProvider = Provider((ref) => WorkshopService());

class WorkshopService {
  final ApiClient _apiClient = ApiClient();

  Future<WorkshopPagination> fetchWorkshops({
    String? search,
    int? categoryId,
    int page = 1,
  }) async {
    final response = await _apiClient.get(
      '/v1/public/workshops',

      queryParameters: {
        'page': page,

        if (search != null && search.isNotEmpty) 'search': search,

        if (categoryId != null) 'category_id': categoryId,
      },
    );

    final apiResponse = ApiResponse.fromJson(response, (data) {
      return WorkshopPagination.fromJson(data);
    });

    return apiResponse.data;
  }

  Future<Workshop> fetchWorkshopDetail(String slug) async {
    final response = await _apiClient.get('/v1/public/workshops/$slug');

    final apiResponse = ApiResponse.fromJson(
      response,
      (data) => Workshop.fromJson(data),
    );

    return apiResponse.data;
  }

  Future<Workshop> fetchWorkshopBySlug(String slug) async {
    final response = await _apiClient.get('/v1/public/workshops/$slug');

    final apiResponse = ApiResponse.fromJson(
      response,
      (data) => Workshop.fromJson(data),
    );

    return apiResponse.data;
  }

  Future<void> enrollWorkshop(int workshopId) async {
    await _apiClient.post('/v1/enrollments', data: {'workshop_id': workshopId});
  }
}

---
## File: lib\features\workshops\workshop_skeleton.dart
import 'package:flutter/material.dart';

class WorkshopSkeleton extends StatelessWidget {
  const WorkshopSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              height: 24,
              width: double.infinity,

              color: Colors.grey.shade300,
            ),

            const SizedBox(height: 16),

            Container(
              height: 16,
              width: double.infinity,

              color: Colors.grey.shade300,
            ),

            const SizedBox(height: 8),

            Container(height: 16, width: 120, color: Colors.grey.shade300),

            const Spacer(),

            Container(height: 20, width: 80, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}

---
## File: lib\features\workshops\pages\workshop_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../shared/navigation/app_shell.dart';
import '../../../shared/utility/string_extension.dart';
import '../../offerings/providers/offering_provider.dart';
import '../../offerings/widgets/offering_card.dart';
import '../workshop_models.dart';
import '../workshop_service.dart';

final workshopDetailProvider = FutureProvider.family<Workshop, String>((
  ref,
  slug,
) async {
  final service = ref.read(workshopServiceProvider);
  return service.fetchWorkshopBySlug(slug);
});

class WorkshopDetailPage extends ConsumerStatefulWidget {
  final String slug;

  const WorkshopDetailPage({super.key, required this.slug});

  @override
  ConsumerState<WorkshopDetailPage> createState() => _WorkshopDetailPageState();
}

class _WorkshopDetailPageState extends ConsumerState<WorkshopDetailPage> {
  bool _isEnrolling = false;

  Future<void> _openVideo(String url) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(uri);

    if (!launched && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open video')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final workshopAsync = ref.watch(workshopDetailProvider(widget.slug));
    final offeringsAsync = ref.watch(workshopOfferingsProvider(widget.slug));
    return AppShell(
      child: workshopAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        data: (workshop) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (workshop.thumbnailUrl != null)
                  if (workshop.thumbnailUrl != null &&
                      workshop.thumbnailUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),

                      child: AspectRatio(
                        aspectRatio: 16 / 9,

                        child: Image.network(
                          workshop.thumbnailUrl!,

                          fit: BoxFit.cover,

                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade300,

                              child: const Center(
                                child: Icon(Icons.image, size: 64),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(48),
                  color: Colors.indigo.shade50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (workshop.isFeatured == true)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Text(
                            'Featured',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        workshop.title,
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        workshop.shortDescription ?? '',
                        style: const TextStyle(fontSize: 20, height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          Chip(
                            label: Text(
                              workshop.category?.name.displayLabel ?? '',
                            ),
                          ),
                          Chip(label: Text(workshop.status.displayLabel)),
                          Chip(label: Text('₹ ${workshop.price}')),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          if (workshop.videoUrl != null &&
                              workshop.videoUrl!.isNotEmpty)
                            OutlinedButton.icon(
                              onPressed: () async {
                                await _openVideo(workshop.videoUrl!);
                              },
                              icon: const Icon(Icons.play_circle_outline),
                              label: const Text('Watch Intro Video'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Workshop Details',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        workshop.fullDescription ?? '',
                        style: const TextStyle(fontSize: 18, height: 1.8),
                      ),
                      const SizedBox(height: 56),

                      const Text(
                        'Available Offerings',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 24),

                      offeringsAsync.when(
                        loading: () {
                          return const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },

                        error: (error, stackTrace) {
                          return Text(error.toString());
                        },

                        data: (offerings) {
                          if (offerings.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'No offerings available currently.',
                              ),
                            );
                          }

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: offerings.length,

                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20,
                                  mainAxisExtent: 240,
                                ),

                            itemBuilder: (context, index) {
                              return OfferingCard(offering: offerings[index]);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

---
## File: lib\features\workshops\pages\workshop_listing_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/empty_state.dart';
import '../../../shared/error_state.dart';
import '../../../shared/navigation/app_shell.dart';
import '../../../shared/responsive_layout.dart';
import '../../categories/category_provider.dart';
import '../widgets/workshop_card.dart';
import '../workshop_provider.dart';
import '../workshop_skeleton.dart';

class WorkshopListingPage extends ConsumerStatefulWidget {
  const WorkshopListingPage({super.key});

  @override
  ConsumerState<WorkshopListingPage> createState() =>
      _WorkshopListingPageState();
}

class _WorkshopListingPageState extends ConsumerState<WorkshopListingPage> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();

    _debounce?.cancel();

    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(searchProvider.notifier).state = value;

      ref.read(currentPageProvider.notifier).state = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final workshopsAsync = ref.watch(workshopsProvider);

    final categoriesAsync = ref.watch(categoriesProvider);

    final selectedCategory = ref.watch(selectedCategoryProvider);

    return AppShell(
      child: workshopsAsync.when(
        loading: () {
          return GridView.builder(
            padding: const EdgeInsets.all(16),

            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,

              crossAxisSpacing: 16,
              mainAxisSpacing: 16,

              mainAxisExtent: 420,
            ),

            itemCount: 8,

            itemBuilder: (context, index) {
              return const WorkshopSkeleton();
            },
          );
        },

        error: (error, stackTrace) {
          return ErrorState(
            message: error.toString(),

            onRetry: () {
              ref.invalidate(workshopsProvider);
            },
          );
        },

        data: (pagination) {
          final workshops = pagination.workshops;

          if (workshops.isEmpty) {
            return const EmptyState(
              title: 'No Workshops Found',

              message: 'Try changing your search or category filters.',
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),

                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,

                  crossAxisAlignment: WrapCrossAlignment.center,

                  children: [
                    SizedBox(
                      width: 400,

                      child: TextField(
                        controller: _searchController,

                        decoration: const InputDecoration(
                          hintText: 'Search workshops',

                          prefixIcon: Icon(Icons.search),

                          border: OutlineInputBorder(),
                        ),

                        onChanged: _onSearchChanged,
                      ),
                    ),

                    categoriesAsync.when(
                      loading: () {
                        return const SizedBox(
                          width: 24,
                          height: 24,

                          child: CircularProgressIndicator(),
                        );
                      },

                      error: (error, stackTrace) {
                        return const SizedBox();
                      },

                      data: (categories) {
                        return DropdownButton<int?>(
                          value: selectedCategory,

                          hint: const Text('Category'),

                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,

                              child: Text('All'),
                            ),

                            ...categories.map((category) {
                              return DropdownMenuItem<int?>(
                                value: category.id,

                                child: Text(category.name),
                              );
                            }),
                          ],

                          onChanged: (value) {
                            ref.read(selectedCategoryProvider.notifier).state =
                                value;

                            ref.read(currentPageProvider.notifier).state = 1;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;

                    final crossAxisCount = ResponsiveLayout.gridCount(width);

                    return Column(
                      children: [
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),

                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,

                                  crossAxisSpacing: 16,

                                  mainAxisSpacing: 16,

                                  mainAxisExtent: 420,
                                ),

                            itemCount: workshops.length,

                            itemBuilder: (context, index) {
                              return WorkshopCard(workshop: workshops[index]);
                            },
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(16),

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              ElevatedButton(
                                onPressed: pagination.currentPage > 1
                                    ? () {
                                        ref
                                            .read(currentPageProvider.notifier)
                                            .state--;
                                      }
                                    : null,

                                child: const Text('Prev'),
                              ),

                              const SizedBox(width: 24),

                              Text(
                                'Page '
                                '${pagination.currentPage} '
                                'of '
                                '${pagination.lastPage}',
                              ),

                              const SizedBox(width: 24),

                              ElevatedButton(
                                onPressed:
                                    pagination.currentPage < pagination.lastPage
                                    ? () {
                                        ref
                                            .read(currentPageProvider.notifier)
                                            .state++;
                                      }
                                    : null,

                                child: const Text('Next'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

---
## File: lib\features\workshops\widgets\compact_workshop_card.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../workshop_models.dart';

class CompactWorkshopCard extends StatelessWidget {
  final Workshop workshop;

  const CompactWorkshopCard({super.key, required this.workshop});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,

      child: Card(
        clipBehavior: Clip.antiAlias,

        child: InkWell(
          onTap: () {
            context.go('/workshops/${workshop.slug}');
          },

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              AspectRatio(
                aspectRatio: 16 / 9,

                child:
                    workshop.thumbnailUrl != null &&
                        workshop.thumbnailUrl!.isNotEmpty
                    ? Image.network(
                        workshop.thumbnailUrl!,

                        fit: BoxFit.cover,

                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade300,

                            child: const Center(child: Icon(Icons.image)),
                          );
                        },
                      )
                    : Container(color: Colors.grey.shade300),
              ),

              Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      workshop.title,

                      maxLines: 2,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 18,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      workshop.shortDescription ?? '',

                      maxLines: 2,

                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      '₹${workshop.price}',

                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

---
## File: lib\features\workshops\widgets\workshop_card.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../workshop_models.dart';

class WorkshopCard extends StatelessWidget {
  final Workshop workshop;

  const WorkshopCard({super.key, required this.workshop});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,

      elevation: 2,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: InkWell(
        onTap: () {
          context.go('/workshops/${workshop.slug}');
        },

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            AspectRatio(
              aspectRatio: 16 / 9,

              child:
                  workshop.thumbnailUrl != null &&
                      workshop.thumbnailUrl!.isNotEmpty
                  ? Image.network(
                      workshop.thumbnailUrl!,

                      fit: BoxFit.cover,

                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade300,

                          child: const Center(
                            child: Icon(Icons.image, size: 48),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey.shade300,

                      child: const Center(child: Icon(Icons.image, size: 48)),
                    ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      workshop.title,

                      maxLines: 2,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 22,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Expanded(
                      child: Text(
                        workshop.shortDescription ?? '',

                        maxLines: 3,

                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Text(
                          '₹${workshop.price}',

                          style: const TextStyle(
                            fontSize: 18,

                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        ElevatedButton(
                          onPressed: () {
                            context.go('/workshops/${workshop.slug}');
                          },

                          child: const Text('View'),
                        ),
                      ],
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

---
## File: lib\features\workshops\widgets\workshop_grid.dart

---
## File: lib\features\workshops\widgets\workshop_search_bar.dart

---
## File: lib\features\workshop_management\workshop_form_dialog.dart
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontned_laravel/features/workshop_management/workshop_management_page.dart';

import 'workshop_management_models.dart';
import 'workshop_management_service.dart';

class WorkshopFormDialog extends ConsumerStatefulWidget {
  final ManagedWorkshop? workshop;

  const WorkshopFormDialog({super.key, this.workshop});

  @override
  ConsumerState<WorkshopFormDialog> createState() => _WorkshopFormDialogState();
}

class _WorkshopFormDialogState extends ConsumerState<WorkshopFormDialog> {
  late final TextEditingController _titleController;

  late final TextEditingController _slugController;

  late final TextEditingController _shortDescriptionController;

  late final TextEditingController _fullDescriptionController;

  late final TextEditingController _priceController;

  late final TextEditingController _videoUrlController;

  String _status = 'draft';

  int? _categoryId;

  bool _isFeatured = false;

  bool _isSaving = false;

  Uint8List? _thumbnailBytes;

  String? _thumbnailName;

  bool get isEdit => widget.workshop != null;

  @override
  void initState() {
    super.initState();

    final workshop = widget.workshop;

    _titleController = TextEditingController(text: workshop?.title ?? '');

    _slugController = TextEditingController(text: workshop?.slug ?? '');

    _shortDescriptionController = TextEditingController(
      text: workshop?.shortDescription ?? '',
    );

    _fullDescriptionController = TextEditingController(
      text: workshop?.fullDescription ?? '',
    );

    _priceController = TextEditingController(text: workshop?.price ?? '');

    _videoUrlController = TextEditingController(text: workshop?.videoUrl ?? '');

    _status = workshop?.status ?? 'draft';

    _categoryId = workshop?.categoryId;

    _isFeatured = workshop?.isFeatured ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();

    _slugController.dispose();

    _shortDescriptionController.dispose();

    _fullDescriptionController.dispose();

    _priceController.dispose();

    _videoUrlController.dispose();

    super.dispose();
  }

  Future<void> _pickThumbnail() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null) {
      return;
    }

    final file = result.files.first;

    setState(() {
      _thumbnailBytes = file.bytes;

      _thumbnailName = file.name;
    });
  }

  Future<void> _save() async {
    if (_categoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select category')));

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final service = ref.read(workshopManagementServiceProvider);

      if (isEdit) {
        await service.updateWorkshop(
          id: widget.workshop!.id,

          categoryId: _categoryId!,

          title: _titleController.text,

          slug: _slugController.text,

          shortDescription: _shortDescriptionController.text,

          fullDescription: _fullDescriptionController.text,

          isFeatured: _isFeatured,

          price: _priceController.text,

          status: _status,

          videoUrl: _videoUrlController.text,

          thumbnailBytes: _thumbnailBytes,

          thumbnailName: _thumbnailName,
        );
      } else {
        await service.createWorkshop(
          categoryId: _categoryId!,

          title: _titleController.text,

          slug: _slugController.text,

          shortDescription: _shortDescriptionController.text,

          fullDescription: _fullDescriptionController.text,

          isFeatured: _isFeatured,

          price: _priceController.text,

          status: _status,

          videoUrl: _videoUrlController.text,

          thumbnailBytes: _thumbnailBytes,

          thumbnailName: _thumbnailName,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(workshopCategoriesProvider);

    return AlertDialog(
      title: Text(isEdit ? 'Edit Workshop' : 'Create Workshop'),

      content: SizedBox(
        width: 520,

        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              TextField(
                controller: _titleController,

                decoration: const InputDecoration(labelText: 'Title'),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _slugController,

                decoration: const InputDecoration(labelText: 'Slug'),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _shortDescriptionController,

                maxLines: 2,

                decoration: const InputDecoration(
                  labelText: 'Short Description',
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _fullDescriptionController,

                maxLines: 6,

                decoration: const InputDecoration(
                  labelText: 'Full Description',
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _priceController,

                keyboardType: TextInputType.number,

                decoration: const InputDecoration(labelText: 'Price'),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _videoUrlController,

                decoration: const InputDecoration(
                  labelText: 'Video URL',
                  hintText: 'https://youtube.com/...',
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Workshop Thumbnail',

                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: _pickThumbnail,

                icon: const Icon(Icons.upload),

                label: const Text('Choose Thumbnail'),
              ),

              const SizedBox(height: 16),

              if (_thumbnailBytes != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),

                  child: Image.memory(
                    _thumbnailBytes!,

                    height: 180,

                    width: double.infinity,

                    fit: BoxFit.cover,
                  ),
                )
              else if (widget.workshop?.thumbnailUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),

                  child: Image.network(
                    widget.workshop!.thumbnailUrl!,

                    height: 180,

                    width: double.infinity,

                    fit: BoxFit.cover,
                  ),
                ),

              const SizedBox(height: 24),

              categoriesAsync.when(
                loading: () {
                  return const Center(child: CircularProgressIndicator());
                },

                error: (error, stackTrace) {
                  return Text(error.toString());
                },

                data: (categories) {
                  return DropdownButtonFormField<int>(
                    value: _categoryId,

                    decoration: const InputDecoration(labelText: 'Category'),

                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,

                        child: Text(category.name),
                      );
                    }).toList(),

                    onChanged: (value) {
                      setState(() {
                        _categoryId = value;
                      });
                    },
                  );
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _status,

                decoration: const InputDecoration(labelText: 'Status'),

                items: const [
                  DropdownMenuItem(value: 'draft', child: Text('Draft')),

                  DropdownMenuItem(
                    value: 'published',

                    child: Text('Published'),
                  ),

                  DropdownMenuItem(value: 'archived', child: Text('Archived')),
                ],

                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              CheckboxListTile(
                value: _isFeatured,

                contentPadding: EdgeInsets.zero,

                title: const Text('Featured Workshop'),

                onChanged: (value) {
                  setState(() {
                    _isFeatured = value ?? false;
                  });
                },
              ),
            ],
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: _isSaving
              ? null
              : () {
                  Navigator.pop(context);
                },

          child: const Text('Cancel'),
        ),

        ElevatedButton(
          onPressed: _isSaving ? null : _save,

          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,

                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEdit ? 'Update' : 'Create'),
        ),
      ],
    );
  }
}

---
## File: lib\features\workshop_management\workshop_management_models.dart
class ManagedWorkshop {
  final int id;

  final int categoryId;

  final String title;

  final String slug;

  final String shortDescription;

  final String fullDescription;
  final String? thumbnail;
  final String? thumbnailUrl;
  final String? videoUrl;
  final String status;

  final String price;

  final bool isFeatured;

  final String? createdAt;

  ManagedWorkshop({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.slug,
    required this.shortDescription,
    required this.fullDescription,
    required this.thumbnail,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.status,
    required this.price,
    required this.isFeatured,
    required this.createdAt,
  });

  factory ManagedWorkshop.fromJson(Map<String, dynamic> json) {
    return ManagedWorkshop(
      id: json['id'],

      categoryId: json['category_id'] ?? 0,

      title: json['title'] ?? '',

      slug: json['slug'] ?? '',

      shortDescription: json['short_description'] ?? '',

      fullDescription: json['full_description'] ?? '',
      thumbnail: json['thumbnail'],
      thumbnailUrl: json['thumbnail_url'],
      videoUrl: json['video_url'],
      status: json['status'] ?? '',

      price: (json['price'] ?? '0').toString(),

      isFeatured: json['is_featured'] == 1,

      createdAt: json['created_at'],
    );
  }
}

class WorkshopCategory {
  final int id;

  final String name;

  WorkshopCategory({required this.id, required this.name});

  factory WorkshopCategory.fromJson(Map<String, dynamic> json) {
    return WorkshopCategory(id: json['id'], name: json['name'] ?? '');
  }
}

---
## File: lib\features\workshop_management\workshop_management_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontned_laravel/features/workshop_management/workshop_form_dialog.dart';

import '../dashboard/widgets/dashboard_shell.dart';
import 'workshop_management_models.dart';
import 'workshop_management_service.dart';

final managedWorkshopsProvider = FutureProvider<List<ManagedWorkshop>>((
  ref,
) async {
  final service = ref.read(workshopManagementServiceProvider);

  return service.fetchWorkshops();
});

final workshopCategoriesProvider = FutureProvider<List<WorkshopCategory>>((
  ref,
) async {
  final service = ref.read(workshopManagementServiceProvider);

  return service.fetchCategories();
});

class WorkshopManagementPage extends ConsumerWidget {
  const WorkshopManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workshopsAsync = ref.watch(managedWorkshopsProvider);

    return DashboardShell(
      title: "Workshops",
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                const Text(
                  'Workshop Management',

                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),

                const Spacer(),

                ElevatedButton.icon(
                  onPressed: () async {
                    final created = await showDialog<bool>(
                      context: context,

                      builder: (context) {
                        return const WorkshopFormDialog();
                      },
                    );

                    if (created == true) {
                      ref.invalidate(managedWorkshopsProvider);
                    }
                  },

                  icon: const Icon(Icons.add),

                  label: const Text('Create Workshop'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Expanded(
              child: Card(
                child: workshopsAsync.when(
                  loading: () {
                    return const Center(child: CircularProgressIndicator());
                  },

                  error: (error, stackTrace) {
                    return Center(child: Text(error.toString()));
                  },

                  data: (workshops) {
                    if (workshops.isEmpty) {
                      return const Center(child: Text('No workshops found'));
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,

                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Title')),

                          DataColumn(label: Text('Status')),

                          DataColumn(label: Text('Price')),

                          DataColumn(label: Text('Created')),

                          DataColumn(label: Text('Actions')),
                        ],

                        rows: workshops.map((workshop) {
                          return DataRow(
                            cells: [
                              DataCell(Text(workshop.title)),

                              DataCell(_StatusChip(status: workshop.status)),

                              DataCell(Text('₹ ${workshop.price}')),

                              DataCell(Text(workshop.createdAt ?? '')),

                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        final updated = await showDialog<bool>(
                                          context: context,

                                          builder: (context) {
                                            return WorkshopFormDialog(
                                              workshop: workshop,
                                            );
                                          },
                                        );

                                        if (updated == true) {
                                          ref.invalidate(
                                            managedWorkshopsProvider,
                                          );
                                        }
                                      },

                                      icon: const Icon(Icons.edit),
                                    ),

                                    IconButton(
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,

                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text(
                                                'Delete Workshop?',
                                              ),

                                              content: const Text(
                                                'This action cannot be undone.',
                                              ),

                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                      context,
                                                      false,
                                                    );
                                                  },

                                                  child: const Text('Cancel'),
                                                ),

                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                      context,
                                                      true,
                                                    );
                                                  },

                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (confirm != true) {
                                          return;
                                        }

                                        await ref
                                            .read(
                                              workshopManagementServiceProvider,
                                            )
                                            .deleteWorkshop(workshop.id);

                                        ref.invalidate(
                                          managedWorkshopsProvider,
                                        );
                                      },

                                      icon: const Icon(Icons.delete),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;

    if (status == 'published') {
      color = Colors.green;
    }

    if (status == 'draft') {
      color = Colors.orange;
    }

    return Chip(
      label: Text(status),

      backgroundColor: color.withOpacity(0.15),

      side: BorderSide.none,

      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }
}

---
## File: lib\features\workshop_management\workshop_management_service.dart
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/api_response.dart';
import 'workshop_management_models.dart';

final workshopManagementServiceProvider = Provider(
  (ref) => WorkshopManagementService(),
);

class WorkshopManagementService {
  final ApiClient _apiClient = ApiClient();

  Future<List<ManagedWorkshop>> fetchWorkshops() async {
    final response = await _apiClient.get('/v1/workshops');

    final apiResponse = ApiResponse.fromJson(response, (data) {
      final items = data['data'] as List;

      return items.map((item) => ManagedWorkshop.fromJson(item)).toList();
    });

    return apiResponse.data;
  }

  Future<void> deleteWorkshop(int id) async {
    await _apiClient.delete('/v1/workshops/$id');
  }

  Future<void> createWorkshop({
    required int categoryId,

    required String title,

    required String slug,

    required String shortDescription,

    required String fullDescription,

    required String price,

    required String status,

    required bool isFeatured,

    String? videoUrl,

    Uint8List? thumbnailBytes,

    String? thumbnailName,
  }) async {
    final formData = FormData.fromMap({
      'category_id': categoryId,

      'title': title,

      'slug': slug,

      'short_description': shortDescription,

      'full_description': fullDescription,

      'price': double.tryParse(price) ?? 0,

      'status': status,

      'is_featured': isFeatured ? 1 : 0,

      'video_url': videoUrl,
    });

    if (thumbnailBytes != null && thumbnailName != null) {
      formData.files.add(
        MapEntry(
          'thumbnail',

          MultipartFile.fromBytes(thumbnailBytes, filename: thumbnailName),
        ),
      );
    }

    await _apiClient.post('/v1/workshops', data: formData);
  }

  Future<void> updateWorkshop({
    required int id,

    required int categoryId,

    required String title,

    required String slug,

    required String shortDescription,

    required String fullDescription,

    required String price,

    required String status,

    required bool isFeatured,

    String? videoUrl,

    Uint8List? thumbnailBytes,

    String? thumbnailName,
  }) async {
    final formData = FormData.fromMap({
      'category_id': categoryId,

      'title': title,

      'slug': slug,

      'short_description': shortDescription,

      'full_description': fullDescription,

      'price': double.tryParse(price) ?? 0,

      'status': status,

      'is_featured': isFeatured ? 1 : 0,

      'video_url': videoUrl,

      '_method': 'PUT',
    });

    if (thumbnailBytes != null && thumbnailName != null) {
      formData.files.add(
        MapEntry(
          'thumbnail',

          MultipartFile.fromBytes(thumbnailBytes, filename: thumbnailName),
        ),
      );
    }

    await _apiClient.post('/v1/workshops/$id', data: formData);
  }

  Future<List<WorkshopCategory>> fetchCategories() async {
    final response = await _apiClient.get('/v1/categories');

    final apiResponse = ApiResponse.fromJson(response, (data) {
      final items = data['data'] as List;

      return items.map((item) => WorkshopCategory.fromJson(item)).toList();
    });

    return apiResponse.data;
  }
}

---
## File: lib\shared\app_scaffold.dart
import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget child;

  const AppScaffold({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),

          child: child,
        ),
      ),
    );
  }
}

---
## File: lib\shared\empty_state.dart
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String message;

  const EmptyState({super.key, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(Icons.search_off, size: 72),

            const SizedBox(height: 24),

            Text(
              title,

              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

---
## File: lib\shared\error_state.dart
import 'package:flutter/material.dart';

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(Icons.error_outline, size: 72, color: Colors.red),

            const SizedBox(height: 24),

            Text(message, textAlign: TextAlign.center),

            if (onRetry != null) ...[
              const SizedBox(height: 24),

              ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}

---
## File: lib\shared\responsive_layout.dart
class ResponsiveLayout {
  static bool isMobile(double width) {
    return width < 768;
  }

  static bool isTablet(double width) {
    return width >= 768 && width < 1024;
  }

  static bool isDesktop(double width) {
    return width >= 1024;
  }

  static int gridCount(double width) {
    if (isDesktop(width)) return 4;

    if (isTablet(width)) return 2;

    return 1;
  }
}

---
## File: lib\shared\models\paginated_response.dart
class PaginatedResponse<T> {
  final List<T> items;

  final int currentPage;

  final int lastPage;

  final int total;

  const PaginatedResponse({
    required this.items,

    required this.currentPage,

    required this.lastPage,

    required this.total,
  });
}

---
## File: lib\shared\navigation\app_footer.dart
import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(24),

      color: Colors.grey.shade200,

      child: const Center(child: Text('© 2026 SkillGarage')),
    );
  }
}

---
## File: lib\shared\navigation\app_header.dart
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

---
## File: lib\shared\navigation\app_shell.dart
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

---
## File: lib\shared\navigation\mobile_drawer.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MobileDrawer extends StatelessWidget {
  const MobileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.all(24),

              child: Text(
                'SkillKart',

                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),

            ListTile(
              title: const Text('Home'),

              onTap: () {
                context.go('/');
              },
            ),

            ListTile(
              title: const Text('Workshops'),

              onTap: () {
                context.go('/workshops');
              },
            ),
          ],
        ),
      ),
    );
  }
}

---
## File: lib\shared\navigation\protected_page.dart
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

---
## File: lib\shared\navigation\role_protected_page.dart
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
                context.go('/my-learning');
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

---
## File: lib\shared\utility\datetime_extension.dart
import 'package:intl/intl.dart';

extension DateTimeExtension on String {
  String get readableDateTime {
    try {
      final date = DateTime.parse(this);

      return DateFormat('dd MMM yyyy • hh:mm a').format(date.toLocal());
    } catch (_) {
      return this;
    }
  }

  String get readableDate {
    try {
      final date = DateTime.parse(this);

      return DateFormat('dd MMM yyyy').format(date.toLocal());
    } catch (_) {
      return this;
    }
  }

  String get readableTime {
    try {
      final date = DateTime.parse(this);

      return DateFormat('hh:mm a').format(date.toLocal());
    } catch (_) {
      return this;
    }
  }

  String rangeTo(String end) {
    try {
      final startDate = DateTime.parse(this);

      final endDate = DateTime.parse(end);

      final sameDay =
          startDate.year == endDate.year &&
          startDate.month == endDate.month &&
          startDate.day == endDate.day;

      if (sameDay) {
        return '${DateFormat('dd MMM yyyy').format(startDate.toLocal())} • '
            '${DateFormat('hh:mm a').format(startDate.toLocal())}'
            ' → '
            '${DateFormat('hh:mm a').format(endDate.toLocal())}';
      }

      return '${DateFormat('dd MMM yyyy • hh:mm a').format(startDate.toLocal())}'
          ' → '
          '${DateFormat('dd MMM yyyy • hh:mm a').format(endDate.toLocal())}';
    } catch (_) {
      return '$this → $end';
    }
  }
}

---
## File: lib\shared\utility\enum_extension.dart
extension EnumByName<T extends Enum> on Iterable<T> {
  T? byNameOrNull(String? value) {
    if (value == null) {
      return null;
    }

    try {
      return byName(value);
    } catch (_) {
      return null;
    }
  }
}

---
## File: lib\shared\utility\json_utils.dart
class JsonUtils {
  static String parseString(dynamic value) {
    if (value == null) {
      return '';
    }

    return value.toString();
  }

  static int? parseInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }

  static double parseDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  static bool parseBool(dynamic value) {
    if (value == null) {
      return false;
    }

    if (value is bool) {
      return value;
    }

    if (value is int) {
      return value == 1;
    }

    final normalized = value.toString().toLowerCase();

    return normalized == 'true' || normalized == '1';
  }

  static List<T> parseList<T>(dynamic value) {
    if (value is List<T>) {
      return value;
    }

    return [];
  }

  static DateTime? parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}

---
## File: lib\shared\utility\string_extension.dart
extension StringExtension on String {
  String get displayLabel {
    return split('_')
        .map(
          (word) =>
              word.isEmpty ? word : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ');
  }
}

---
