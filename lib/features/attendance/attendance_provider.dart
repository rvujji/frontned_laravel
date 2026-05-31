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
