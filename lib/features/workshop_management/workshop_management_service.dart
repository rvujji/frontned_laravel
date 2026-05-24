import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/api_response.dart';
import 'workshop_management_models.dart';

final workshopManagementServiceProvider = Provider(
  (ref) => WorkshopManagementService(),
);

class WorkshopManagementService {
  final ApiClient _apiClient = ApiClient();

  Future<List<ManagedWorkshop>> fetchWorkshops() async {
    final response = await _apiClient.get('/v1/workshops');

    final apiResponse = ApiResponse.fromJson(response, (data) {
      final items = data['data'] as List;

      return items.map((item) => ManagedWorkshop.fromJson(item)).toList();
    });

    return apiResponse.data;
  }

  Future<void> deleteWorkshop(int id) async {
    await _apiClient.delete('/v1/workshops/$id');
  }

  Future<void> createWorkshop({
    required int categoryId,

    required String title,

    required String slug,

    required String shortDescription,

    required String fullDescription,

    required String price,

    required String status,

    required bool isFeatured,

    String? videoUrl,

    Uint8List? thumbnailBytes,

    String? thumbnailName,
  }) async {
    final formData = FormData.fromMap({
      'category_id': categoryId,

      'title': title,

      'slug': slug,

      'short_description': shortDescription,

      'full_description': fullDescription,

      'price': double.tryParse(price) ?? 0,

      'status': status,

      'is_featured': isFeatured ? 1 : 0,

      'video_url': videoUrl,
    });

    if (thumbnailBytes != null && thumbnailName != null) {
      formData.files.add(
        MapEntry(
          'thumbnail',

          MultipartFile.fromBytes(thumbnailBytes, filename: thumbnailName),
        ),
      );
    }

    await _apiClient.post('/v1/workshops', data: formData);
  }

  Future<void> updateWorkshop({
    required int id,

    required int categoryId,

    required String title,

    required String slug,

    required String shortDescription,

    required String fullDescription,

    required String price,

    required String status,

    required bool isFeatured,

    String? videoUrl,

    Uint8List? thumbnailBytes,

    String? thumbnailName,
  }) async {
    final formData = FormData.fromMap({
      'category_id': categoryId,

      'title': title,

      'slug': slug,

      'short_description': shortDescription,

      'full_description': fullDescription,

      'price': double.tryParse(price) ?? 0,

      'status': status,

      'is_featured': isFeatured ? 1 : 0,

      'video_url': videoUrl,

      '_method': 'PUT',
    });

    if (thumbnailBytes != null && thumbnailName != null) {
      formData.files.add(
        MapEntry(
          'thumbnail',

          MultipartFile.fromBytes(thumbnailBytes, filename: thumbnailName),
        ),
      );
    }

    await _apiClient.post('/v1/workshops/$id', data: formData);
  }

  Future<List<WorkshopCategory>> fetchCategories() async {
    final response = await _apiClient.get('/v1/categories');

    final apiResponse = ApiResponse.fromJson(response, (data) {
      final items = data['data'] as List;

      return items.map((item) => WorkshopCategory.fromJson(item)).toList();
    });

    return apiResponse.data;
  }
}
