class DashboardStats {
  final int totalStudents;

  final int totalWorkshops;

  final int publishedWorkshops;

  final int totalEnrollments;

  DashboardStats({
    required this.totalStudents,
    required this.totalWorkshops,
    required this.publishedWorkshops,
    required this.totalEnrollments,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalStudents: json['total_students'] ?? 0,

      totalWorkshops: json['total_workshops'] ?? 0,

      publishedWorkshops: json['published_workshops'] ?? 0,

      totalEnrollments: json['total_enrollments'] ?? 0,
    );
  }
}

class RecentEnrollment {
  final int id;

  final int studentId;

  final String studentName;

  final int workshopId;

  final String workshopTitle;

  final String status;

  final String? createdAt;

  RecentEnrollment({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.workshopId,
    required this.workshopTitle,
    required this.status,
    required this.createdAt,
  });

  factory RecentEnrollment.fromJson(Map<String, dynamic> json) {
    return RecentEnrollment(
      id: json['id'],

      studentId: json['student_id'] ?? 0,

      studentName: json['student_name'] ?? '',

      workshopId: json['workshop_id'] ?? 0,

      workshopTitle: json['workshop_title'] ?? '',

      status: json['status'] ?? '',

      createdAt: json['created_at'],
    );
  }
}

class RecentWorkshop {
  final int id;

  final String title;

  final String slug;

  final String status;

  final int ownerId;

  final String ownerName;

  final String? createdAt;

  RecentWorkshop({
    required this.id,
    required this.title,
    required this.slug,
    required this.status,
    required this.ownerId,
    required this.ownerName,
    required this.createdAt,
  });

  factory RecentWorkshop.fromJson(Map<String, dynamic> json) {
    return RecentWorkshop(
      id: json['id'],

      title: json['title'] ?? '',

      slug: json['slug'] ?? '',

      status: json['status'] ?? '',

      ownerId: json['owner_id'] ?? 0,

      ownerName: json['owner_name'] ?? '',

      createdAt: json['created_at'],
    );
  }
}
