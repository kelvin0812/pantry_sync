import 'dart:convert';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/food_item.dart';
import 'nutrition_database.dart';

/// Auto-scan service that monitors the Storage bucket for new images
/// and automatically analyzes them with Gemini Vision.
///
/// Call [startListening] once in main.dart to begin watching for new uploads.
/// When ESP32 uploads a new photo, this service:
///   1. Detects the new file
///   2. Downloads it
///   3. Sends to Gemini Vision
///   4. Inserts detected food items into inventory table
class AutoScanService {
  // Singleton
  static final AutoScanService _instance = AutoScanService._internal();
  factory AutoScanService() => _instance;
  AutoScanService._internal();

  static const String _bucketName = 'Inventory';
  static const String _geminiApiKey = 'AIzaSyDs9K3KOOIL7UxCHmbR2uwdt55PwYz8_5c';

  GenerativeModel? _model;
  final NutritionDatabase _nutritionDb = NutritionDatabase();
  String? _lastProcessedFile;
  bool _isProcessing = false;

  SupabaseClient get _client => Supabase.instance.client;

  /// Initialize Gemini model
  void initialize() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: _geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.2,
        responseMimeType: 'application/json',
      ),
    );
  }

  /// Check for new images and analyze them.
  /// Call this periodically (e.g., every 10 seconds) or after door close event.
  Future<List<FoodItem>> checkAndAnalyzeNewImages() async {
    if (_isProcessing || _model == null) return [];
    _isProcessing = true;

    try {
      // List files in bucket
      final files = await _client.storage
          .from(_bucketName)
          .list();

      if (files.isEmpty) {
        _isProcessing = false;
        return [];
      }

      // Get the newest file (sort by name which contains timestamp)
      files.sort((a, b) => b.name.compareTo(a.name));
      final newestFile = files.first;
      final fileName = newestFile.name;

      // Skip if already processed
      if (fileName == _lastProcessedFile) {
        _isProcessing = false;
        return [];
      }

      // Skip non-image files
      if (!fileName.toLowerCase().endsWith('.jpg') &&
          !fileName.toLowerCase().endsWith('.jpeg') &&
          !fileName.toLowerCase().endsWith('.png')) {
        _isProcessing = false;
        return [];
      }

      // Download the image
      final Uint8List imageBytes = await _client.storage
          .from(_bucketName)
          .download(fileName);

      // Analyze with Gemini
      final items = await _analyzeImage(imageBytes, fileName);

      // Mark as processed
      _lastProcessedFile = fileName;

      // Insert into database
      if (items.isNotEmpty) {
        await _insertItems(items);
      }

      _isProcessing = false;
      return items;
    } catch (e) {
      _isProcessing = false;
      return [];
    }
  }

  /// Analyze a specific image by filename
  Future<List<FoodItem>> analyzeImage(String fileName) async {
    if (_model == null) return [];

    try {
      final Uint8List imageBytes = await _client.storage
          .from(_bucketName)
          .download(fileName);

      return await _analyzeImage(imageBytes, fileName);
    } catch (e) {
      return [];
    }
  }

  /// Core: Send image to Gemini Vision and parse results
  Future<List<FoodItem>> _analyzeImage(
      Uint8List imageBytes, String fileName) async {
    final prompt = '''
Analyze this fridge image and identify all visible food items.

For each food item, provide:
- "name": the common name of the food (in English)
- "category": one of [Protein, Carbs, Vegetables, Fruits, Dairy, Condiments, Beverages, Snacks, Other]
- "estimated_quantity_grams": estimated weight in grams based on visual size

Return ONLY a JSON array. Example:
[{"name": "Eggs", "category": "Protein", "estimated_quantity_grams": 360}]

If no food is visible, return an empty array: []
''';

    final content = Content.multi([
      TextPart(prompt),
      DataPart('image/jpeg', imageBytes),
    ]);

    final response = await _model!.generateContent([content]);
    final responseText = response.text;

    if (responseText == null || responseText.isEmpty) return [];

    final List<dynamic> detected = jsonDecode(responseText);
    final List<FoodItem> items = [];
    final imageUrl = _client.storage
        .from(_bucketName)
        .getPublicUrl(fileName);

    for (int i = 0; i < detected.length; i++) {
      final item = detected[i] as Map<String, dynamic>;
      final name = item['name'] as String? ?? 'Unknown';
      final category = item['category'] as String? ?? 'Other';
      final quantity =
          (item['estimated_quantity_grams'] as num?)?.toDouble() ?? 100.0;

      final nutrition = _nutritionDb.getNutrition(name);

      items.add(FoodItem(
        id: '${DateTime.now().millisecondsSinceEpoch}_$i',
        name: name,
        category: category,
        quantity: quantity,
        protein: nutrition.proteinPer100g,
        carbs: nutrition.carbsPer100g,
        fat: nutrition.fatPer100g,
        calories: nutrition.caloriesPer100g,
        detectedAt: DateTime.now(),
        imageUrl: imageUrl,
      ));
    }

    return items;
  }

  /// Insert detected items into Supabase inventory table
  Future<void> _insertItems(List<FoodItem> items) async {
    // Clear old inventory (each scan replaces previous items)
    await _client.from('inventory').delete().neq('id', 0);

    // Insert new items
    for (final item in items) {
      await _client.from('inventory').insert({
        'name': item.name,
        'category': item.category,
        'quantity': item.quantity,
        'protein': item.protein,
        'carbs': item.carbs,
        'fat': item.fat,
        'calories': item.calories,
        'detected_at': item.detectedAt.toIso8601String(),
        'image_url': item.imageUrl,
      });
    }
  }

  /// Manually trigger a scan of the latest image
  Future<List<FoodItem>> scanLatestImage() async {
    return checkAndAnalyzeNewImages();
  }
}
