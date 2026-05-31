import '../../offerings/models/session_model.dart';

class ReservationModel {
  final int id;

  final SessionModel session;

  final String status;

  final bool attended;

  final bool checkedIn;

  final String? reservedAt;

  ReservationModel({
    required this.id,
    required this.session,
    required this.status,
    required this.attended,
    required this.checkedIn,
    required this.reservedAt,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'],

      session: SessionModel.fromJson(json['session']),

      status: json['status'] ?? '',

      attended: json['attended'] ?? false,

      checkedIn: json['checked_in'] ?? false,

      reservedAt: json['reserved_at'],
    );
  }
}
