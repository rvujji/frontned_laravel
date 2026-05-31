import '../../../core/enums.dart';
import '../../../shared/utility/enum_extension.dart';

class SessionModel {
  final int id;
  final int? sessionNumber;
  final String title;
  final SessionKind sessionKind;
  final DeliveryMode deliveryMode;

  final String startAt;
  final String endAt;
  final String timezone;

  final int? durationMinutes;

  final String? venueName;
  final String? venueAddress;
  final String? meetingLink;

  final String? agendaSummary;
  final String? materialsRequired;
  final String? prework;
  final String? homework;

  final int? capacity;

  final bool waitlistEnabled;
  final bool bookable;
  final bool attendanceRequired;

  final String completionWeight;

  final String? recordingUrl;
  final String? slidesUrl;

  final List<dynamic>? resources;

  final SessionStatus status;

  final bool isUpcoming;
  final bool isLive;
  final bool isCompleted;

  SessionModel({
    required this.id,
    required this.sessionNumber,
    required this.title,
    required this.sessionKind,
    required this.deliveryMode,
    required this.startAt,
    required this.endAt,
    required this.timezone,
    required this.durationMinutes,
    required this.venueName,
    required this.venueAddress,
    required this.meetingLink,
    required this.agendaSummary,
    required this.materialsRequired,
    required this.prework,
    required this.homework,
    required this.capacity,
    required this.waitlistEnabled,
    required this.bookable,
    required this.attendanceRequired,
    required this.completionWeight,
    required this.recordingUrl,
    required this.slidesUrl,
    required this.resources,
    required this.status,
    required this.isUpcoming,
    required this.isLive,
    required this.isCompleted,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'],
      sessionNumber: json['session_number'],
      title: json['title'] ?? '',
      sessionKind:
          SessionKind.values.byNameOrNull(json['session_kind']) ??
          SessionKind.instruction,
      deliveryMode:
          DeliveryMode.values.byNameOrNull(json['delivery_mode']) ??
          DeliveryMode.virtual,
      startAt: json['start_at'] ?? '',
      endAt: json['end_at'] ?? '',
      timezone: json['timezone'] ?? '',
      durationMinutes: json['duration_minutes'],
      venueName: json['venue_name'],
      venueAddress: json['venue_address'],
      meetingLink: json['meeting_link'],
      agendaSummary: json['agenda_summary'],
      materialsRequired: json['materials_required'],
      prework: json['prework'],
      homework: json['homework'],
      capacity: json['capacity'],
      waitlistEnabled: json['waitlist_enabled'] ?? false,
      bookable: json['bookable'] ?? false,
      attendanceRequired: json['attendance_required'] ?? false,
      completionWeight: json['completion_weight']?.toString() ?? '0',
      recordingUrl: json['recording_url'],
      slidesUrl: json['slides_url'],
      resources: json['resources'],
      status:
          SessionStatus.values.byNameOrNull(json['status']) ??
          SessionStatus.draft,
      isUpcoming: json['is_upcoming'] ?? false,
      isLive: json['is_live'] ?? false,
      isCompleted: json['is_completed'] ?? false,
    );
  }
}
