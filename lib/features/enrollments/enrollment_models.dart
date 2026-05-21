class Enrollment {
  final int id;

  final int workshopId;
  final int studentId;

  final String status;

  final String? enrolledAt;

  final String? cancelledAt;

  final String? completedAt;

  final String? createdAt;

  final String workshopTitle;

  final String studentName;

  Enrollment({
    required this.id,
    required this.workshopId,
    required this.studentId,
    required this.status,
    required this.enrolledAt,
    required this.cancelledAt,
    required this.completedAt,
    required this.createdAt,
    required this.workshopTitle,
    required this.studentName,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: json['id'],

      workshopId: json['workshop_id'] ?? 0,

      studentId: json['student_id'] ?? 0,

      status: json['status'] ?? '',

      enrolledAt: json['enrolled_at'],

      cancelledAt: json['cancelled_at'],

      completedAt: json['completed_at'],

      createdAt: json['created_at'],

      workshopTitle: json['workshop']?['title'] ?? '',

      studentName: json['student']?['name'] ?? '',
    );
  }
}
