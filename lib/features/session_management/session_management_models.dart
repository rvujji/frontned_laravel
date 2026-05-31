import '../../core/enums.dart';

class SessionManagementModel {
  final int id;
  final int workshopOfferingId;
  final int? sessionNumber;

  final String title;

  final SessionKind sessionKind;
  final DeliveryMode deliveryMode;
  final SessionStatus status;

  final int? trainerId;
  final int? assistantTrainerId;

  final DateTime? startAt;
  final DateTime? endAt;

  final String? timezone;

  final int durationMinutes;

  final String? venueName;
  final String? venueAddress;

  final String? meetingLink;
  final String? meetingPassword;

  final int capacity;

  final bool waitlistEnabled;
  final bool bookable;
  final bool attendanceRequired;

  final double completionWeight;

  final String? agendaSummary;
  final String? materialsRequired;
  final String? prework;
  final String? homework;

  final String? recordingUrl;
  final String? slidesUrl;

  final List<dynamic> resources;

  final String? notes;

  final int? workshopId;
  final String? workshopTitle;

  final int? offeringId;
  final String? offeringTitle;

  final int reservationCount;

  const SessionManagementModel({
    required this.id,
    required this.workshopOfferingId,
    required this.sessionNumber,
    required this.title,
    required this.sessionKind,
    required this.deliveryMode,
    required this.status,
    required this.trainerId,
    required this.assistantTrainerId,
    required this.startAt,
    required this.endAt,
    required this.timezone,
    required this.durationMinutes,
    required this.venueName,
    required this.venueAddress,
    required this.meetingLink,
    required this.meetingPassword,
    required this.capacity,
    required this.waitlistEnabled,
    required this.bookable,
    required this.attendanceRequired,
    required this.completionWeight,
    required this.agendaSummary,
    required this.materialsRequired,
    required this.prework,
    required this.homework,
    required this.recordingUrl,
    required this.slidesUrl,
    required this.resources,
    required this.notes,
    required this.workshopId,
    required this.workshopTitle,
    required this.offeringId,
    required this.offeringTitle,
    required this.reservationCount,
  });

  factory SessionManagementModel.fromJson(Map<String, dynamic> json) {
    return SessionManagementModel(
      id: json['id'] ?? 0,
      workshopOfferingId: json['offering']?['id'] ?? 0,
      sessionNumber: json['session_number'],
      title: json['title'] ?? '',
      sessionKind: _parseSessionKind(json['session_kind']),
      deliveryMode: _parseDeliveryMode(json['delivery_mode']),
      status: _parseSessionStatus(json['status']),
      trainerId: json['trainer_id'],
      assistantTrainerId: json['assistant_trainer_id'],
      startAt: json['start_at'] != null
          ? DateTime.tryParse(json['start_at'].toString())
          : null,
      endAt: json['end_at'] != null
          ? DateTime.tryParse(json['end_at'].toString())
          : null,
      timezone: json['timezone'],
      durationMinutes: json['duration_minutes'] ?? 0,
      venueName: json['venue_name'],
      venueAddress: json['venue_address'],
      meetingLink: json['meeting_link'],
      meetingPassword: json['meeting_password'],
      capacity: json['capacity'] ?? 0,
      waitlistEnabled: json['waitlist_enabled'] ?? false,
      bookable: json['bookable'] ?? false,
      attendanceRequired: json['attendance_required'] ?? false,
      completionWeight:
          double.tryParse('${json['completion_weight'] ?? 0}') ?? 0,
      agendaSummary: json['agenda_summary'],
      materialsRequired: json['materials_required'],
      prework: json['prework'],
      homework: json['homework'],
      recordingUrl: json['recording_url'],
      slidesUrl: json['slides_url'],
      resources: (json['resources'] as List?) ?? const [],
      notes: json['notes'],
      workshopId: json['workshop']?['id'],
      workshopTitle: json['workshop']?['title'],

      offeringId: json['offering']?['id'],
      offeringTitle: json['offering']?['title'],
      reservationCount: json['reservation_count'] ?? 0,
    );
  }

  Map<String, dynamic> toRequest() {
    return {
      'workshop_offering_id': workshopOfferingId,
      'session_number': sessionNumber,
      'title': title,
      'session_kind': sessionKind.name,
      'delivery_mode': deliveryMode.name,
      'trainer_id': trainerId,
      'assistant_trainer_id': assistantTrainerId,
      'start_at': startAt?.toIso8601String(),
      'end_at': endAt?.toIso8601String(),
      'timezone': timezone,
      'duration_minutes': durationMinutes,
      'venue_name': venueName,
      'venue_address': venueAddress,
      'meeting_link': meetingLink,
      'meeting_password': meetingPassword,
      'capacity': capacity,
      'waitlist_enabled': waitlistEnabled,
      'bookable': bookable,
      'attendance_required': attendanceRequired,
      'completion_weight': completionWeight,
      'agenda_summary': agendaSummary,
      'materials_required': materialsRequired,
      'prework': prework,
      'homework': homework,
      'recording_url': recordingUrl,
      'slides_url': slidesUrl,
      'resources': resources,
      'status': status.name,
      'notes': notes,
    };
  }

  SessionManagementModel copyWith({
    int? id,
    int? workshopOfferingId,
    int? sessionNumber,
    String? title,
    SessionKind? sessionKind,
    DeliveryMode? deliveryMode,
    SessionStatus? status,
    int? trainerId,
    int? assistantTrainerId,
    DateTime? startAt,
    DateTime? endAt,
    String? timezone,
    int? durationMinutes,
    String? venueName,
    String? venueAddress,
    String? meetingLink,
    String? meetingPassword,
    int? capacity,
    bool? waitlistEnabled,
    bool? bookable,
    bool? attendanceRequired,
    double? completionWeight,
    String? agendaSummary,
    String? materialsRequired,
    String? prework,
    String? homework,
    String? recordingUrl,
    String? slidesUrl,
    List<dynamic>? resources,
    String? notes,
    int? workshopId,
    String? workshopTitle,
    int? offeringId,
    String? offeringTitle,
    int? reservationCount,
  }) {
    return SessionManagementModel(
      id: id ?? this.id,
      workshopOfferingId: workshopOfferingId ?? this.workshopOfferingId,
      sessionNumber: sessionNumber ?? this.sessionNumber,
      title: title ?? this.title,
      sessionKind: sessionKind ?? this.sessionKind,
      deliveryMode: deliveryMode ?? this.deliveryMode,
      status: status ?? this.status,
      trainerId: trainerId ?? this.trainerId,
      assistantTrainerId: assistantTrainerId ?? this.assistantTrainerId,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      timezone: timezone ?? this.timezone,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      venueName: venueName ?? this.venueName,
      venueAddress: venueAddress ?? this.venueAddress,
      meetingLink: meetingLink ?? this.meetingLink,
      meetingPassword: meetingPassword ?? this.meetingPassword,
      capacity: capacity ?? this.capacity,
      waitlistEnabled: waitlistEnabled ?? this.waitlistEnabled,
      bookable: bookable ?? this.bookable,
      attendanceRequired: attendanceRequired ?? this.attendanceRequired,
      completionWeight: completionWeight ?? this.completionWeight,
      agendaSummary: agendaSummary ?? this.agendaSummary,
      materialsRequired: materialsRequired ?? this.materialsRequired,
      prework: prework ?? this.prework,
      homework: homework ?? this.homework,
      recordingUrl: recordingUrl ?? this.recordingUrl,
      slidesUrl: slidesUrl ?? this.slidesUrl,
      resources: resources ?? this.resources,
      notes: notes ?? this.notes,
      workshopId: workshopId ?? this.workshopId,
      workshopTitle: workshopTitle ?? this.workshopTitle,

      offeringId: offeringId ?? this.offeringId,
      offeringTitle: offeringTitle ?? this.offeringTitle,
      reservationCount: reservationCount ?? this.reservationCount,
    );
  }
}

SessionKind _parseSessionKind(dynamic value) {
  final text = value?.toString().toLowerCase() ?? '';

  return SessionKind.values.firstWhere(
    (e) => e.name.toLowerCase() == text,
    orElse: () => SessionKind.values.first,
  );
}

DeliveryMode _parseDeliveryMode(dynamic value) {
  final text = value?.toString().toLowerCase() ?? '';

  return DeliveryMode.values.firstWhere(
    (e) => e.name.toLowerCase() == text,
    orElse: () => DeliveryMode.values.first,
  );
}

SessionStatus _parseSessionStatus(dynamic value) {
  final text = value?.toString().toLowerCase() ?? '';

  return SessionStatus.values.firstWhere(
    (e) => e.name.toLowerCase() == text,
    orElse: () => SessionStatus.values.first,
  );
}

class SessionListResponse {
  final List<SessionManagementModel> sessions;

  const SessionListResponse({required this.sessions});
}
