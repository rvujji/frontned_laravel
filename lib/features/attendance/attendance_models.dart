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
