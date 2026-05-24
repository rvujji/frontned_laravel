class Enrollment {
  final int id;

  final int workshopId;

  final int studentId;

  final String status;

  final String? enrolledAt;

  final String studentName;

  final String workshopTitle;

  const Enrollment({
    required this.id,

    required this.workshopId,

    required this.studentId,

    required this.status,

    required this.studentName,

    required this.workshopTitle,

    this.enrolledAt,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: json['id'] ?? 0,

      workshopId: json['workshop_id'] ?? 0,

      studentId: json['student_id'] ?? 0,

      status: json['status'] ?? '',

      enrolledAt: json['enrolled_at'],

      studentName: json['student']?['name']?.toString() ?? '',

      workshopTitle: json['workshop']?['title']?.toString() ?? '',
    );
  }
}
