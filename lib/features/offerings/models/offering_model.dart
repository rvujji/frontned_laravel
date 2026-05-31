import '../../../core/enums.dart';
import '../../../shared/utility/enum_extension.dart';
import '../../../shared/utility/json_utils.dart';
import '../../workshops/workshop_models.dart';
import 'session_model.dart';

class OfferingModel {
  final int id;
  final String title;
  final String slug;

  final Workshop? workshop;

  final DeliveryMode deliveryMode;
  final EnrollmentType enrollmentType;
  final SessionSelectionRule sessionSelectionRule;
  final CompletionRule completionRule;
  final CapacityMode capacityMode;

  final int? minimumSessionsRequired;
  final int? maximumSessionsSelectable;

  final String? startDate;
  final String? endDate;

  final String? enrollmentOpenAt;
  final String? enrollmentCloseAt;

  final int? capacity;
  final String price;

  final String timezone;

  final String? venueName;
  final String? venueAddress;

  final String? meetingLink;

  final bool certificateEnabled;

  final List<SessionModel> sessions;

  final OfferingStatus status;

  final String? notes;

  final bool isUpcoming;
  final bool hasStarted;
  final bool hasEnded;

  OfferingModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.workshop,
    required this.deliveryMode,
    required this.enrollmentType,
    required this.sessionSelectionRule,
    required this.completionRule,
    required this.capacityMode,
    required this.minimumSessionsRequired,
    required this.maximumSessionsSelectable,
    required this.startDate,
    required this.endDate,
    required this.enrollmentOpenAt,
    required this.enrollmentCloseAt,
    required this.capacity,
    required this.price,
    required this.timezone,
    required this.venueName,
    required this.venueAddress,
    required this.meetingLink,
    required this.certificateEnabled,
    required this.sessions,
    required this.status,
    required this.notes,
    required this.isUpcoming,
    required this.hasStarted,
    required this.hasEnded,
  });

  factory OfferingModel.fromJson(Map<String, dynamic> json) {
    return OfferingModel(
      id: json['id'],
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      workshop: json['workshop'] != null
          ? Workshop.fromJson(json['workshop'])
          : null,
      deliveryMode:
          DeliveryMode.values.byNameOrNull(json['delivery_mode']) ??
          DeliveryMode.virtual,
      enrollmentType:
          EnrollmentType.values.byNameOrNull(json['enrollment_type']) ??
          EnrollmentType.full_series,
      sessionSelectionRule:
          SessionSelectionRule.values.byNameOrNull(
            json['session_selection_rule'],
          ) ??
          SessionSelectionRule.all_sessions,
      completionRule:
          CompletionRule.values.byNameOrNull(json['completion_rule']) ??
          CompletionRule.manual_completion,
      capacityMode:
          CapacityMode.values.byNameOrNull(json['capacity_mode']) ??
          CapacityMode.offering_only,
      minimumSessionsRequired: json['minimum_sessions_required'],
      maximumSessionsSelectable: json['maximum_sessions_selectable'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      enrollmentOpenAt: json['enrollment_open_at'],
      enrollmentCloseAt: json['enrollment_close_at'],
      capacity: JsonUtils.parseInt(json['capacity']),
      price: json['price']?.toString() ?? '0',
      timezone: json['timezone'] ?? '',
      venueName: json['venue_name'],
      venueAddress: json['venue_address'],
      meetingLink: json['meeting_link'],
      certificateEnabled: json['certificate_enabled'] ?? false,
      sessions: (json['sessions'] as List<dynamic>? ?? [])
          .map((e) => SessionModel.fromJson(e))
          .toList(),
      status:
          OfferingStatus.values.byNameOrNull(json['status']) ??
          OfferingStatus.draft,
      notes: json['notes'],
      isUpcoming: json['is_upcoming'] ?? false,
      hasStarted: json['has_started'] ?? false,
      hasEnded: json['has_ended'] ?? false,
    );
  }
}
