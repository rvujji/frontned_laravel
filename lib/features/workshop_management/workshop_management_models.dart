class ManagedWorkshop {
  final int id;

  final int categoryId;

  final String title;

  final String slug;

  final String shortDescription;

  final String fullDescription;
  final String? thumbnail;
  final String? thumbnailUrl;
  final String? videoUrl;
  final String status;

  final String price;

  final bool isFeatured;

  final String? createdAt;

  ManagedWorkshop({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.slug,
    required this.shortDescription,
    required this.fullDescription,
    required this.thumbnail,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.status,
    required this.price,
    required this.isFeatured,
    required this.createdAt,
  });

  factory ManagedWorkshop.fromJson(Map<String, dynamic> json) {
    return ManagedWorkshop(
      id: json['id'],

      categoryId: json['category_id'] ?? 0,

      title: json['title'] ?? '',

      slug: json['slug'] ?? '',

      shortDescription: json['short_description'] ?? '',

      fullDescription: json['full_description'] ?? '',
      thumbnail: json['thumbnail'],
      thumbnailUrl: json['thumbnail_url'],
      videoUrl: json['video_url'],
      status: json['status'] ?? '',

      price: (json['price'] ?? '0').toString(),

      isFeatured: json['is_featured'] == 1,

      createdAt: json['created_at'],
    );
  }
}

class WorkshopCategory {
  final int id;

  final String name;

  WorkshopCategory({required this.id, required this.name});

  factory WorkshopCategory.fromJson(Map<String, dynamic> json) {
    return WorkshopCategory(id: json['id'], name: json['name'] ?? '');
  }
}
