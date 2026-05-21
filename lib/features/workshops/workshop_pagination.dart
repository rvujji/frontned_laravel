import 'workshop_models.dart';

class WorkshopPagination {
  final List<Workshop> workshops;

  final int currentPage;
  final int lastPage;

  WorkshopPagination({
    required this.workshops,
    required this.currentPage,
    required this.lastPage,
  });

  factory WorkshopPagination.fromJson(Map<String, dynamic> json) {
    final items = json['data'] as List;

    return WorkshopPagination(
      workshops: items.map((item) => Workshop.fromJson(item)).toList(),

      currentPage: json['current_page'] ?? 1,

      lastPage: json['last_page'] ?? 1,
    );
  }
}
