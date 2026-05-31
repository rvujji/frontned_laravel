import '../../core/enums.dart';
import '../../shared/utility/enum_extension.dart';
import '../../shared/utility/json_utils.dart';

class OfferingEnrollmentModel {
  final int id;

  final int workshopId;
  final String workshopTitle;

  final int offeringId;
  final String offeringTitle;

  final int studentId;
  final String learnerName;
  final String learnerEmail;

  final EnrollmentStatus enrollmentStatus;
  final CompletionStatus completionStatus;

  final double progressPercentage;
  final double attendancePercentage;

  final bool certificateEligible;
  final bool certificateIssued;

  final int attendedSessions;
  final int totalSessions;

  final String enrolledAt;

  OfferingEnrollmentModel({
    required this.id,
    required this.workshopId,
    required this.workshopTitle,
    required this.offeringId,
    required this.offeringTitle,
    required this.studentId,
    required this.learnerName,
    required this.learnerEmail,
    required this.enrollmentStatus,
    required this.completionStatus,
    required this.progressPercentage,
    required this.attendancePercentage,
    required this.certificateEligible,
    required this.certificateIssued,
    required this.attendedSessions,
    required this.totalSessions,
    required this.enrolledAt,
  });

  factory OfferingEnrollmentModel.fromJson(Map<String, dynamic> json) {
    final workshop = Map<String, dynamic>.from(json['workshop'] ?? {});

    final offering = Map<String, dynamic>.from(json['offering'] ?? {});

    final student = Map<String, dynamic>.from(json['student'] ?? {});

    return OfferingEnrollmentModel(
      id: JsonUtils.parseInt(json['id']) ?? 0,

      workshopId: JsonUtils.parseInt(workshop['id']) ?? 0,

      workshopTitle: JsonUtils.parseString(workshop['title']),

      offeringId: JsonUtils.parseInt(offering['id']) ?? 0,

      offeringTitle: JsonUtils.parseString(offering['title']),

      studentId: JsonUtils.parseInt(student['id']) ?? 0,

      learnerName: JsonUtils.parseString(student['name']),

      learnerEmail: JsonUtils.parseString(student['email']),

      enrollmentStatus:
          EnrollmentStatus.values.byNameOrNull(json['status']) ??
          EnrollmentStatus.suspended,

      completionStatus:
          CompletionStatus.values.byNameOrNull(json['completion_status']) ??
          CompletionStatus.not_started,

      progressPercentage: JsonUtils.parseDouble(json['progress_percentage']),

      attendancePercentage: JsonUtils.parseDouble(
        json['attendance_percentage'],
      ),

      certificateEligible: JsonUtils.parseBool(json['certificate_eligible']),

      certificateIssued: JsonUtils.parseBool(json['certificate_issued']),

      attendedSessions: JsonUtils.parseInt(json['attended_sessions']) ?? 0,

      totalSessions: JsonUtils.parseInt(json['total_sessions']) ?? 0,

      enrolledAt: JsonUtils.parseString(json['enrolled_at']),
    );
  }
}

class PaginatedEnrollments {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  final List<OfferingEnrollmentModel> data;

  PaginatedEnrollments({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.data,
  });

  factory PaginatedEnrollments.fromJson(Map<String, dynamic> json) {
    final items = (json['data'] as List<dynamic>? ?? [])
        .map(
          (e) => OfferingEnrollmentModel.fromJson(Map<String, dynamic>.from(e)),
        )
        .toList();

    return PaginatedEnrollments(
      currentPage: JsonUtils.parseInt(json['current_page']) ?? 1,

      lastPage: JsonUtils.parseInt(json['last_page']) ?? 1,

      perPage: JsonUtils.parseInt(json['per_page']) ?? 15,

      total: JsonUtils.parseInt(json['total']) ?? 0,

      data: items,
    );
  }
}

class EnrollmentWorkshopFilter {
  final int id;
  final String title;

  EnrollmentWorkshopFilter({required this.id, required this.title});

  factory EnrollmentWorkshopFilter.fromJson(Map<String, dynamic> json) {
    return EnrollmentWorkshopFilter(
      id: JsonUtils.parseInt(json['id']) ?? 0,
      title: JsonUtils.parseString(json['title']),
    );
  }
}

class EnrollmentOfferingFilter {
  final int id;
  final int workshopId;
  final String title;

  EnrollmentOfferingFilter({
    required this.id,
    required this.workshopId,
    required this.title,
  });

  factory EnrollmentOfferingFilter.fromJson(Map<String, dynamic> json) {
    return EnrollmentOfferingFilter(
      id: JsonUtils.parseInt(json['id']) ?? 0,

      workshopId: JsonUtils.parseInt(json['workshop_id']) ?? 0,

      title: JsonUtils.parseString(json['title']),
    );
  }
}

class EnrollmentStudentFilter {
  final int id;
  final String name;

  EnrollmentStudentFilter({required this.id, required this.name});

  factory EnrollmentStudentFilter.fromJson(Map<String, dynamic> json) {
    return EnrollmentStudentFilter(
      id: JsonUtils.parseInt(json['id']) ?? 0,

      name: JsonUtils.parseString(json['name']),
    );
  }
}

class EnrollmentFiltersResponse {
  final List<EnrollmentWorkshopFilter> workshops;
  final List<EnrollmentOfferingFilter> offerings;
  final List<EnrollmentStudentFilter> students;
  final List<String> completionStatuses;

  EnrollmentFiltersResponse({
    required this.workshops,
    required this.offerings,
    required this.students,
    required this.completionStatuses,
  });

  factory EnrollmentFiltersResponse.fromJson(Map<String, dynamic> json) {
    return EnrollmentFiltersResponse(
      workshops: (json['workshops'] as List<dynamic>? ?? [])
          .map(
            (e) =>
                EnrollmentWorkshopFilter.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),

      offerings: (json['offerings'] as List<dynamic>? ?? [])
          .map(
            (e) =>
                EnrollmentOfferingFilter.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),

      students: (json['students'] as List<dynamic>? ?? [])
          .map(
            (e) =>
                EnrollmentStudentFilter.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),

      completionStatuses: (json['completion_statuses'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
