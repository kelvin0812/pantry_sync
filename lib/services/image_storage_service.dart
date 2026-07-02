import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Handles food image uploads to Supabase Storage.
/// Images are captured by the fridge camera on door close,
/// then uploaded and linked to inventory items.
///
/// Supabase free tier: 1GB storage (plenty for food photos)
class ImageStorageService {
  // Singleton
  static final ImageStorageService _instance =
      ImageStorageService._internal();
  factory ImageStorageService() => _instance;
  ImageStorageService._internal();

  static const String _bucketName = 'food-images';

  SupabaseClient get _client => Supabase.instance.client;

  /// Upload a food image and return its public URL.
  ///
  /// [imageBytes] - The image data (JPEG/PNG from camera)
  /// [fileName] - Optional custom filename. Auto-generates if null.
  /// Returns the public URL of the uploaded image.
  Future<String?> uploadFoodImage(
    Uint8List imageBytes, {
    String? fileName,
  }) async {
    try {
      final name = fileName ??
          'scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'scans/$name';

      await _client.storage
          .from(_bucketName)
          .uploadBinary(path, imageBytes, fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ));

      // Get public URL
      final url = _client.storage
          .from(_bucketName)
          .getPublicUrl(path);

      return url;
    } catch (e) {
      return null;
    }
  }

  /// Upload a full fridge scan image (wider shot)
  Future<String?> uploadFridgeScan(Uint8List imageBytes) async {
    return uploadFoodImage(
      imageBytes,
      fileName: 'fridge_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
  }

  /// Delete a food image by its URL
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Extract path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      // URL format: .../storage/v1/object/public/food-images/scans/filename.jpg
      final bucketIndex = pathSegments.indexOf(_bucketName);
      if (bucketIndex >= 0) {
        final filePath =
            pathSegments.sublist(bucketIndex + 1).join('/');
        await _client.storage.from(_bucketName).remove([filePath]);
      }
    } catch (_) {
      // Silently fail — image cleanup is non-critical
    }
  }

  /// Get all stored food image URLs
  Future<List<String>> listImages() async {
    try {
      final files = await _client.storage
          .from(_bucketName)
          .list(path: 'scans');

      return files.map((file) {
        return _client.storage
            .from(_bucketName)
            .getPublicUrl('scans/${file.name}');
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
