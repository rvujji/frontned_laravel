enum DeliveryMode { physical, virtual, hybrid }

enum EnrollmentType {
  full_series,
  session_selection,
  drop_in,
  subscription_access,
}

enum OfferingStatus {
  draft,
  published,
  ongoing,
  completed,
  cancelled,
  archived,
}

enum SessionKind {
  instruction,
  lab,
  project,
  assessment,
  orientation,
  qa,
  demo,
  mentoring,
}

enum SessionStatus { draft, scheduled, live, completed, cancelled, archived }

enum EnrollmentStatus { active, cancelled, completed, suspended }

enum PaymentStatus { unpaid, pending, paid, failed, refunded }

enum CompletionStatus { not_started, in_progress, completed, failed }

enum AttendanceStatus { present, absent, late, partial, excused }

enum CapacityMode { offering_only, session_only, both }

enum CompletionRule {
  attend_all_required,
  attend_n_sessions,
  attendance_percentage,
  manual_completion,
}

enum SessionSelectionRule {
  all_sessions,
  any_n_of_m,
  specific_track_only,
  optional_sessions,
}

enum SessionReservationStatus { reserved, waitlisted, cancelled, attended }
