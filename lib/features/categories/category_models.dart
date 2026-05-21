class WorkshopCategory {
  final int id;
  final String name;

  WorkshopCategory({required this.id, required this.name});

  factory WorkshopCategory.fromJson(Map<String, dynamic> json) {
    return WorkshopCategory(id: json['id'], name: json['name']);
  }
}
