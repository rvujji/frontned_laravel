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
