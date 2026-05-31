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
