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
