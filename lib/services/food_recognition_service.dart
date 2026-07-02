import 'dart:convert';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/food_item.dart';
import 'nutrition_database.dart';

/// Food recognition service using Google Gemini Vision API.
/// Analyzes fridge camera images to identify food items and estimate quantities.
///
/// Flow:
/// 1. Camera captures image on door close
/// 2. Image sent to Gemini Vision for food identification
/// 3. Identified items matched against nutrition database (USDA/local)
/// 4. Returns list of FoodItem with full nutrition data
class FoodRecognitionService {
  // Singleton
  static final FoodRecognitionService _instance =
      FoodRecognitionService._internal();
  factory FoodRecognitionService() => _instance;
  FoodRecognitionService._internal();

  GenerativeModel? _model;
  final NutritionDatabase _nutritionDb = NutritionDatabase();

  /// Initialize with your Gemini API key
  /// Get your key from: https://aistudio.google.com/app/apikey
  void initialize(String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.2, // Low temperature for factual responses
        responseMimeType: 'application/json',
      ),
    );
  }

  bool get isInitialized => _model != null;

  /// Analyze a fridge image and return detected food items
  ///
  /// [imageBytes] - The image data from camera
  /// [mimeType] - Image format (e.g., 'image/jpeg', 'image/png')
  Future<List<FoodItem>> scanFridgeImage(
    Uint8List imageBytes, {
    String mimeType = 'image/jpeg',
  }) async {
    if (_model == null) {
      // Fallback to local dataset if Gemini not configured
      return _nutritionDb.getMockScanResults();
    }

    try {
      final prompt = '''
Analyze this fridge image and identify all visible food items.

For each food item, provide:
- "name": the common name of the food (in English)
- "category": one of [Protein, Carbs, Vegetables, Fruits, Dairy, Condiments, Beverages, Snacks, Other]
- "estimated_quantity_grams": estimated weight in grams based on visual size

Return a JSON array. Example:
[
  {"name": "Eggs", "category": "Protein", "estimated_quantity_grams": 360},
  {"name": "Milk", "category": "Dairy", "estimated_quantity_grams": 1000}
]

Only include items you can clearly identify. Be conservative with quantity estimates.
Return ONLY the JSON array, no other text.
''';

      final content = Content.multi([
        TextPart(prompt),
        DataPart(mimeType, imageBytes),
      ]);

      final response = await _model!.generateContent([content]);
      final responseText = response.text;

      if (responseText == null || responseText.isEmpty) {
        return _nutritionDb.getMockScanResults();
      }

      // Parse Gemini's response
      final List<dynamic> detectedItems = jsonDecode(responseText);
      final List<FoodItem> foodItems = [];

      for (int i = 0; i < detectedItems.length; i++) {
        final item = detectedItems[i] as Map<String, dynamic>;
        final name = item['name'] as String? ?? 'Unknown';
        final category = item['category'] as String? ?? 'Other';
        final quantity =
            (item['estimated_quantity_grams'] as num?)?.toDouble() ?? 100.0;

        // Look up nutrition data from our database
        final nutrition = _nutritionDb.getNutrition(name);

        foodItems.add(FoodItem(
          id: '${DateTime.now().millisecondsSinceEpoch}_$i',
          name: name,
          category: category,
          quantity: quantity,
          protein: nutrition.proteinPer100g,
          carbs: nutrition.carbsPer100g,
          fat: nutrition.fatPer100g,
          calories: nutrition.caloriesPer100g,
          detectedAt: DateTime.now(),
        ));
      }

      return foodItems;
    } catch (e) {
      // On error, fall back to local database
      return _nutritionDb.getMockScanResults();
    }
  }

  /// Identify a single food item from an image (for manual add)
  Future<FoodItem?> identifySingleItem(
    Uint8List imageBytes, {
    String mimeType = 'image/jpeg',
  }) async {
    if (_model == null) return null;

    try {
      final prompt = '''
Identify the main food item in this image.

Return a JSON object with:
- "name": the common name of the food
- "category": one of [Protein, Carbs, Vegetables, Fruits, Dairy, Condiments, Beverages, Snacks, Other]
- "estimated_quantity_grams": estimated weight in grams

Return ONLY the JSON object.
''';

      final content = Content.multi([
        TextPart(prompt),
        DataPart(mimeType, imageBytes),
      ]);

      final response = await _model!.generateContent([content]);
      final responseText = response.text;

      if (responseText == null || responseText.isEmpty) return null;

      final item = jsonDecode(responseText) as Map<String, dynamic>;
      final name = item['name'] as String? ?? 'Unknown';
      final category = item['category'] as String? ?? 'Other';
      final quantity =
          (item['estimated_quantity_grams'] as num?)?.toDouble() ?? 100.0;

      final nutrition = _nutritionDb.getNutrition(name);

      return FoodItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        category: category,
        quantity: quantity,
        protein: nutrition.proteinPer100g,
        carbs: nutrition.carbsPer100g,
        fat: nutrition.fatPer100g,
        calories: nutrition.caloriesPer100g,
        detectedAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }
}
