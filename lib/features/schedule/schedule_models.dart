class ScheduledSession {
  final int id;

  final String title;

  final String offeringTitle;

  final String sessionKind;

  final String status;

  final String reservationStatus;

  final String startAt;

  final String endAt;

  final bool isLive;

  final bool attended;

  final bool missed;

  ScheduledSession({
    required this.id,
    required this.title,
    required this.offeringTitle,
    required this.sessionKind,
    required this.status,
    required this.reservationStatus,
    required this.startAt,
    required this.endAt,
    required this.isLive,
    required this.attended,
    required this.missed,
  });

  factory ScheduledSession.fromJson(Map<String, dynamic> json) {
    return ScheduledSession(
      id: json['id'],

      title: json['title'] ?? '',

      offeringTitle: json['offering_title'] ?? '',

      sessionKind: json['session_kind'] ?? '',

      status: json['status'] ?? '',

      reservationStatus: json['reservation_status'] ?? '',

      startAt: json['start_at'] ?? '',

      endAt: json['end_at'] ?? '',

      isLive: json['is_live'] ?? false,

      attended: json['attended'] ?? false,

      missed: json['missed'] ?? false,
    );
  }
}
