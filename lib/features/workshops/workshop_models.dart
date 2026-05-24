class Workshop {
  final int id;
  final String title;
  final String slug;

  final String? shortDescription;
  final String? fullDescription;
  final String? thumbnail;
  final String? thumbnailUrl;
  final String? videoUrl;
  final String price;
  final String status;
  final bool isFeatured;
  final WorkshopCategory? category;

  Workshop({
    required this.id,
    required this.title,
    required this.slug,
    required this.shortDescription,
    required this.fullDescription,
    required this.thumbnail,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.price,
    required this.status,
    required this.isFeatured,
    required this.category,
  });

  factory Workshop.fromJson(Map<String, dynamic> json) {
    return Workshop(
      id: json['id'],

      title: json['title'] ?? '',

      slug: json['slug'] ?? '',

      shortDescription: json['short_description'],

      fullDescription: json['full_description'],
      thumbnail: json['thumbnail'],

      thumbnailUrl: json['thumbnail_url'],

      videoUrl: json['video_url'],
      price: json['price'] ?? '0',
      status: json['status'] ?? '',

      isFeatured: json['is_featured'] == 1,

      category: json['category'] != null
          ? WorkshopCategory.fromJson(json['category'])
          : null,
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
