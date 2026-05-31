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
