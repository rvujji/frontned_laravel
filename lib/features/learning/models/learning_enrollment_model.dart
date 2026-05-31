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
