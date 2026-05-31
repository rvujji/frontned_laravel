import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'offering_enrollment_models.dart';
import 'offering_enrollment_service.dart';

final offeringEnrollmentServiceProvider = Provider<OfferingEnrollmentService>(
  (ref) => OfferingEnrollmentService(),
);

class EnrollmentFilters {
  final int? workshopId;
  final int? offeringId;
  final int? studentId;
  final String? completionStatus;
  final String search;
  final int page;
  final int perPage;

  const EnrollmentFilters({
    this.workshopId,
    this.offeringId,
    this.studentId,
    this.completionStatus,
    this.search = '',
    this.page = 1,
    this.perPage = 15,
  });

  EnrollmentFilters copyWith({
    int? workshopId,
    int? offeringId,
    int? studentId,
    String? completionStatus,
    String? search,
    int? page,
    int? perPage,
    bool clearWorkshop = false,
    bool clearOffering = false,
    bool clearStudent = false,
    bool clearCompletionStatus = false,
  }) {
    return EnrollmentFilters(
      workshopId: clearWorkshop ? null : (workshopId ?? this.workshopId),

      offeringId: clearOffering ? null : (offeringId ?? this.offeringId),

      studentId: clearStudent ? null : (studentId ?? this.studentId),

      completionStatus: clearCompletionStatus
          ? null
          : (completionStatus ?? this.completionStatus),

      search: search ?? this.search,

      page: page ?? this.page,

      perPage: perPage ?? this.perPage,
    );
  }
}

final enrollmentFiltersProvider = StateProvider<EnrollmentFilters>(
  (ref) => const EnrollmentFilters(),
);

final enrollmentFiltersLookupProvider =
    FutureProvider<EnrollmentFiltersResponse>((ref) async {
      final service = ref.read(offeringEnrollmentServiceProvider);

      return service.fetchFilters();
    });

final offeringEnrollmentProvider = FutureProvider<PaginatedEnrollments>((
  ref,
) async {
  final service = ref.read(offeringEnrollmentServiceProvider);

  final filters = ref.watch(enrollmentFiltersProvider);

  return service.fetchEnrollments(
    workshopId: filters.workshopId,
    offeringId: filters.offeringId,
    studentId: filters.studentId,
    completionStatus: filters.completionStatus,
    search: filters.search.trim().isEmpty ? null : filters.search.trim(),
    page: filters.page,
    perPage: filters.perPage,
  );
});
