class AdminOffering {
  final int id;

  final String title;

  final String slug;

  final String status;

  final String deliveryMode;

  final String? startDate;

  final String? endDate;

  final int sessionsCount;

  final int enrollmentsCount;

  final bool certificateEnabled;

  final int? workshopId;
  final String? workshopTitle;
  final String enrollmentType;

  final String sessionSelectionRule;

  final String completionRule;

  final String capacityMode;

  final int minimumSessionsRequired;

  final int maximumSessionsSelectable;

  AdminOffering({
    required this.id,
    required this.title,
    required this.slug,
    required this.status,
    required this.deliveryMode,
    required this.startDate,
    required this.endDate,
    required this.sessionsCount,
    required this.enrollmentsCount,
    required this.certificateEnabled,
    required this.workshopId,
    required this.workshopTitle,
    required this.enrollmentType,
    required this.sessionSelectionRule,
    required this.completionRule,
    required this.capacityMode,
    required this.minimumSessionsRequired,
    required this.maximumSessionsSelectable,
  });

  factory AdminOffering.fromJson(Map<String, dynamic> json) {
    return AdminOffering(
      id: json['id'],

      title: json['title'] ?? '',

      slug: json['slug'] ?? '',

      status: json['status'] ?? '',

      deliveryMode: json['delivery_mode'] ?? '',

      startDate: json['start_date'],

      endDate: json['end_date'],

      sessionsCount: json['sessions_count'] ?? 0,

      enrollmentsCount: json['enrollments_count'] ?? 0,

      certificateEnabled: json['certificate_enabled'] ?? false,

      workshopId: json['workshop']?['id'],

      workshopTitle: json['workshop']?['title'],

      enrollmentType: json['enrollment_type'] ?? '',

      sessionSelectionRule: json['session_selection_rule'] ?? '',

      completionRule: json['completion_rule'] ?? '',

      capacityMode: json['capacity_mode'] ?? '',

      minimumSessionsRequired: json['minimum_sessions_required'] ?? 0,

      maximumSessionsSelectable: json['maximum_sessions_selectable'] ?? 0,
    );
  }
}

class AdminSession {
  final int id;

  final String title;

  final String sessionKind;

  final String status;

  final String startAt;

  final String endAt;

  final int reservationsCount;

  final bool attendanceRequired;

  AdminSession({
    required this.id,
    required this.title,
    required this.sessionKind,
    required this.status,
    required this.startAt,
    required this.endAt,
    required this.reservationsCount,
    required this.attendanceRequired,
  });

  factory AdminSession.fromJson(Map<String, dynamic> json) {
    return AdminSession(
      id: json['id'],

      title: json['title'] ?? '',

      sessionKind: json['session_kind'] ?? '',

      status: json['status'] ?? '',

      startAt: json['start_at'] ?? '',

      endAt: json['end_at'] ?? '',

      reservationsCount: json['reservations_count'] ?? 0,

      attendanceRequired: json['attendance_required'] ?? false,
    );
  }
}

class OfferingWorkshop {
  final int id;
  final String title;

  OfferingWorkshop({required this.id, required this.title});

  factory OfferingWorkshop.fromJson(Map<String, dynamic> json) {
    return OfferingWorkshop(id: json['id'], title: json['title'] ?? '');
  }
}
