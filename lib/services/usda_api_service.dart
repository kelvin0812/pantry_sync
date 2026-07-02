import 'dart:convert';
import 'package:http/http.dart' as http;

import 'nutrition_database.dart';

/// USDA FoodData Central API service.
/// Provides real-time nutrition lookup for food items.
///
/// API docs: https://fdc.nal.usda.gov/api-guide.html
/// Free API key: https://fdc.nal.usda.gov/api-key-signup.html
class UsdaApiService {
  // Singleton
  static final UsdaApiService _instance = UsdaApiService._internal();
  factory UsdaApiService() => _instance;
  UsdaApiService._internal();

  static const String _apiKey = 'DEMO_KEY';
  static const String _baseUrl = 'https://api.nal.usda.gov/fdc/v1';

  final NutritionDatabase _localDb = NutritionDatabase();

  /// Search USDA database for a food item and get nutrition per 100g.
  /// Falls back to local database if API fails.
  Future<NutritionInfo> lookupNutrition(String foodName) async {
    try {
      final uri = Uri.parse('$_baseUrl/foods/search'
          '?api_key=$_apiKey'
          '&query=${Uri.encodeComponent(foodName)}'
          '&pageSize=1'
          '&dataType=Foundation,SR%20Legacy');

      final response = await http.get(uri).timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final foods = data['foods'] as List?;

        if (foods != null && foods.isNotEmpty) {
          final food = foods.first;
          final nutrients = food['foodNutrients'] as List? ?? [];

          double protein = 0, carbs = 0, fat = 0, calories = 0;

          for (final n in nutrients) {
            final id = n['nutrientId'] as int?;
            final value = (n['value'] as num?)?.toDouble() ?? 0;
            switch (id) {
              case 1003: protein = value; break; // Protein
              case 1005: carbs = value; break;   // Carbs
              case 1004: fat = value; break;     // Fat
              case 1008: calories = value; break; // Energy (kcal)
            }
          }

          return NutritionInfo(
            name: foodName,
            proteinPer100g: protein,
            carbsPer100g: carbs,
            fatPer100g: fat,
            caloriesPer100g: calories,
            category: food['foodCategory'] as String? ?? 'Other',
          );
        }
      }
    } catch (_) {
      // Network error — fall back to local
    }

    // Fallback to local database
    return _localDb.getNutrition(foodName);
  }
}
