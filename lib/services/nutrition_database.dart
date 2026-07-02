import '../models/food_item.dart';

/// Nutrition data per 100g for common food items.
/// Values sourced from USDA FoodData Central (https://fdc.nal.usda.gov/)
class NutritionInfo {
  final String name;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double caloriesPer100g;
  final String category;

  const NutritionInfo({
    required this.name,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    required this.caloriesPer100g,
    required this.category,
  });
}

/// Local nutrition database with 80+ common fridge items.
/// Acts as offline fallback and fast lookup for Gemini-detected items.
class NutritionDatabase {
  // Singleton
  static final NutritionDatabase _instance = NutritionDatabase._internal();
  factory NutritionDatabase() => _instance;
  NutritionDatabase._internal();

  /// Comprehensive food nutrition dataset (per 100g)
  /// Source: USDA FoodData Central
  static const List<NutritionInfo> _database = [
    // ─── PROTEIN ──────────────────────────────────────────
    NutritionInfo(name: 'Eggs', proteinPer100g: 13.0, carbsPer100g: 1.1, fatPer100g: 11.0, caloriesPer100g: 155, category: 'Protein'),
    NutritionInfo(name: 'Chicken Breast', proteinPer100g: 31.0, carbsPer100g: 0.0, fatPer100g: 3.6, caloriesPer100g: 165, category: 'Protein'),
    NutritionInfo(name: 'Chicken Thigh', proteinPer100g: 26.0, carbsPer100g: 0.0, fatPer100g: 10.9, caloriesPer100g: 209, category: 'Protein'),
    NutritionInfo(name: 'Chicken Wing', proteinPer100g: 30.5, carbsPer100g: 0.0, fatPer100g: 8.1, caloriesPer100g: 203, category: 'Protein'),
    NutritionInfo(name: 'Beef', proteinPer100g: 26.0, carbsPer100g: 0.0, fatPer100g: 15.0, caloriesPer100g: 250, category: 'Protein'),
    NutritionInfo(name: 'Ground Beef', proteinPer100g: 17.2, carbsPer100g: 0.0, fatPer100g: 20.0, caloriesPer100g: 254, category: 'Protein'),
    NutritionInfo(name: 'Steak', proteinPer100g: 25.0, carbsPer100g: 0.0, fatPer100g: 19.0, caloriesPer100g: 271, category: 'Protein'),
    NutritionInfo(name: 'Pork', proteinPer100g: 27.3, carbsPer100g: 0.0, fatPer100g: 14.0, caloriesPer100g: 242, category: 'Protein'),
    NutritionInfo(name: 'Bacon', proteinPer100g: 37.0, carbsPer100g: 1.4, fatPer100g: 42.0, caloriesPer100g: 541, category: 'Protein'),
    NutritionInfo(name: 'Salmon', proteinPer100g: 20.0, carbsPer100g: 0.0, fatPer100g: 13.0, caloriesPer100g: 208, category: 'Protein'),
    NutritionInfo(name: 'Tuna', proteinPer100g: 29.0, carbsPer100g: 0.0, fatPer100g: 1.0, caloriesPer100g: 130, category: 'Protein'),
    NutritionInfo(name: 'Shrimp', proteinPer100g: 24.0, carbsPer100g: 0.2, fatPer100g: 0.3, caloriesPer100g: 99, category: 'Protein'),
    NutritionInfo(name: 'Fish', proteinPer100g: 22.0, carbsPer100g: 0.0, fatPer100g: 5.0, caloriesPer100g: 136, category: 'Protein'),
    NutritionInfo(name: 'Tofu', proteinPer100g: 8.0, carbsPer100g: 1.9, fatPer100g: 4.8, caloriesPer100g: 76, category: 'Protein'),
    NutritionInfo(name: 'Tempeh', proteinPer100g: 19.0, carbsPer100g: 9.4, fatPer100g: 11.0, caloriesPer100g: 192, category: 'Protein'),
    NutritionInfo(name: 'Lamb', proteinPer100g: 25.0, carbsPer100g: 0.0, fatPer100g: 21.0, caloriesPer100g: 294, category: 'Protein'),

    // ─── DAIRY ────────────────────────────────────────────
    NutritionInfo(name: 'Milk', proteinPer100g: 3.4, carbsPer100g: 5.0, fatPer100g: 1.0, caloriesPer100g: 42, category: 'Dairy'),
    NutritionInfo(name: 'Whole Milk', proteinPer100g: 3.3, carbsPer100g: 4.8, fatPer100g: 3.3, caloriesPer100g: 61, category: 'Dairy'),
    NutritionInfo(name: 'Cheese', proteinPer100g: 25.0, carbsPer100g: 1.3, fatPer100g: 33.0, caloriesPer100g: 402, category: 'Dairy'),
    NutritionInfo(name: 'Cheddar Cheese', proteinPer100g: 25.0, carbsPer100g: 1.3, fatPer100g: 33.1, caloriesPer100g: 403, category: 'Dairy'),
    NutritionInfo(name: 'Mozzarella', proteinPer100g: 22.2, carbsPer100g: 2.2, fatPer100g: 22.4, caloriesPer100g: 300, category: 'Dairy'),
    NutritionInfo(name: 'Yogurt', proteinPer100g: 10.0, carbsPer100g: 3.6, fatPer100g: 0.7, caloriesPer100g: 59, category: 'Dairy'),
    NutritionInfo(name: 'Greek Yogurt', proteinPer100g: 10.0, carbsPer100g: 3.6, fatPer100g: 0.7, caloriesPer100g: 59, category: 'Dairy'),
    NutritionInfo(name: 'Butter', proteinPer100g: 0.9, carbsPer100g: 0.1, fatPer100g: 81.0, caloriesPer100g: 717, category: 'Dairy'),
    NutritionInfo(name: 'Cream', proteinPer100g: 2.1, carbsPer100g: 2.8, fatPer100g: 36.0, caloriesPer100g: 340, category: 'Dairy'),
    NutritionInfo(name: 'Cream Cheese', proteinPer100g: 5.9, carbsPer100g: 4.1, fatPer100g: 34.2, caloriesPer100g: 342, category: 'Dairy'),

    // ─── VEGETABLES ───────────────────────────────────────
    NutritionInfo(name: 'Broccoli', proteinPer100g: 2.8, carbsPer100g: 7.0, fatPer100g: 0.4, caloriesPer100g: 34, category: 'Vegetables'),
    NutritionInfo(name: 'Spinach', proteinPer100g: 2.9, carbsPer100g: 3.6, fatPer100g: 0.4, caloriesPer100g: 23, category: 'Vegetables'),
    NutritionInfo(name: 'Carrot', proteinPer100g: 0.9, carbsPer100g: 9.6, fatPer100g: 0.2, caloriesPer100g: 41, category: 'Vegetables'),
    NutritionInfo(name: 'Tomato', proteinPer100g: 0.9, carbsPer100g: 3.9, fatPer100g: 0.2, caloriesPer100g: 18, category: 'Vegetables'),
    NutritionInfo(name: 'Bell Pepper', proteinPer100g: 1.0, carbsPer100g: 6.0, fatPer100g: 0.3, caloriesPer100g: 31, category: 'Vegetables'),
    NutritionInfo(name: 'Onion', proteinPer100g: 1.1, carbsPer100g: 9.3, fatPer100g: 0.1, caloriesPer100g: 40, category: 'Vegetables'),
    NutritionInfo(name: 'Scallions', proteinPer100g: 1.8, carbsPer100g: 7.3, fatPer100g: 0.2, caloriesPer100g: 32, category: 'Vegetables'),
    NutritionInfo(name: 'Garlic', proteinPer100g: 6.4, carbsPer100g: 33.1, fatPer100g: 0.5, caloriesPer100g: 149, category: 'Vegetables'),
    NutritionInfo(name: 'Lettuce', proteinPer100g: 1.4, carbsPer100g: 2.9, fatPer100g: 0.2, caloriesPer100g: 15, category: 'Vegetables'),
    NutritionInfo(name: 'Cucumber', proteinPer100g: 0.7, carbsPer100g: 3.6, fatPer100g: 0.1, caloriesPer100g: 16, category: 'Vegetables'),
    NutritionInfo(name: 'Cabbage', proteinPer100g: 1.3, carbsPer100g: 5.8, fatPer100g: 0.1, caloriesPer100g: 25, category: 'Vegetables'),
    NutritionInfo(name: 'Mushroom', proteinPer100g: 3.1, carbsPer100g: 3.3, fatPer100g: 0.3, caloriesPer100g: 22, category: 'Vegetables'),
    NutritionInfo(name: 'Celery', proteinPer100g: 0.7, carbsPer100g: 3.0, fatPer100g: 0.2, caloriesPer100g: 14, category: 'Vegetables'),
    NutritionInfo(name: 'Corn', proteinPer100g: 3.3, carbsPer100g: 19.0, fatPer100g: 1.5, caloriesPer100g: 86, category: 'Vegetables'),
    NutritionInfo(name: 'Potato', proteinPer100g: 2.0, carbsPer100g: 17.5, fatPer100g: 0.1, caloriesPer100g: 77, category: 'Vegetables'),

    // ─── FRUITS ───────────────────────────────────────────
    NutritionInfo(name: 'Apple', proteinPer100g: 0.3, carbsPer100g: 13.8, fatPer100g: 0.2, caloriesPer100g: 52, category: 'Fruits'),
    NutritionInfo(name: 'Banana', proteinPer100g: 1.1, carbsPer100g: 22.8, fatPer100g: 0.3, caloriesPer100g: 89, category: 'Fruits'),
    NutritionInfo(name: 'Orange', proteinPer100g: 0.9, carbsPer100g: 11.8, fatPer100g: 0.1, caloriesPer100g: 47, category: 'Fruits'),
    NutritionInfo(name: 'Grapes', proteinPer100g: 0.7, carbsPer100g: 18.1, fatPer100g: 0.2, caloriesPer100g: 69, category: 'Fruits'),
    NutritionInfo(name: 'Strawberry', proteinPer100g: 0.7, carbsPer100g: 7.7, fatPer100g: 0.3, caloriesPer100g: 32, category: 'Fruits'),
    NutritionInfo(name: 'Blueberry', proteinPer100g: 0.7, carbsPer100g: 14.5, fatPer100g: 0.3, caloriesPer100g: 57, category: 'Fruits'),
    NutritionInfo(name: 'Watermelon', proteinPer100g: 0.6, carbsPer100g: 7.6, fatPer100g: 0.2, caloriesPer100g: 30, category: 'Fruits'),
    NutritionInfo(name: 'Mango', proteinPer100g: 0.8, carbsPer100g: 15.0, fatPer100g: 0.4, caloriesPer100g: 60, category: 'Fruits'),
    NutritionInfo(name: 'Lemon', proteinPer100g: 1.1, carbsPer100g: 9.3, fatPer100g: 0.3, caloriesPer100g: 29, category: 'Fruits'),
    NutritionInfo(name: 'Avocado', proteinPer100g: 2.0, carbsPer100g: 8.5, fatPer100g: 14.7, caloriesPer100g: 160, category: 'Fruits'),

    // ─── CARBS ────────────────────────────────────────────
    NutritionInfo(name: 'Rice', proteinPer100g: 2.7, carbsPer100g: 28.0, fatPer100g: 0.3, caloriesPer100g: 130, category: 'Carbs'),
    NutritionInfo(name: 'Leftover Rice', proteinPer100g: 2.7, carbsPer100g: 28.0, fatPer100g: 0.3, caloriesPer100g: 130, category: 'Carbs'),
    NutritionInfo(name: 'Brown Rice', proteinPer100g: 2.6, carbsPer100g: 23.0, fatPer100g: 0.9, caloriesPer100g: 111, category: 'Carbs'),
    NutritionInfo(name: 'Bread', proteinPer100g: 9.0, carbsPer100g: 49.0, fatPer100g: 3.2, caloriesPer100g: 265, category: 'Carbs'),
    NutritionInfo(name: 'White Bread', proteinPer100g: 9.0, carbsPer100g: 49.0, fatPer100g: 3.2, caloriesPer100g: 265, category: 'Carbs'),
    NutritionInfo(name: 'Noodles', proteinPer100g: 5.0, carbsPer100g: 25.0, fatPer100g: 0.9, caloriesPer100g: 138, category: 'Carbs'),
    NutritionInfo(name: 'Pasta', proteinPer100g: 5.8, carbsPer100g: 25.0, fatPer100g: 0.9, caloriesPer100g: 131, category: 'Carbs'),
    NutritionInfo(name: 'Tortilla', proteinPer100g: 8.0, carbsPer100g: 44.6, fatPer100g: 7.4, caloriesPer100g: 312, category: 'Carbs'),
    NutritionInfo(name: 'Oats', proteinPer100g: 16.9, carbsPer100g: 66.3, fatPer100g: 6.9, caloriesPer100g: 389, category: 'Carbs'),

    // ─── CONDIMENTS & SAUCES ──────────────────────────────
    NutritionInfo(name: 'Soy Sauce', proteinPer100g: 5.6, carbsPer100g: 5.6, fatPer100g: 0.1, caloriesPer100g: 53, category: 'Condiments'),
    NutritionInfo(name: 'Ketchup', proteinPer100g: 1.7, carbsPer100g: 27.4, fatPer100g: 0.1, caloriesPer100g: 112, category: 'Condiments'),
    NutritionInfo(name: 'Mayonnaise', proteinPer100g: 1.0, carbsPer100g: 0.6, fatPer100g: 75.0, caloriesPer100g: 680, category: 'Condiments'),
    NutritionInfo(name: 'Mustard', proteinPer100g: 4.4, carbsPer100g: 5.3, fatPer100g: 4.0, caloriesPer100g: 60, category: 'Condiments'),
    NutritionInfo(name: 'Chili Sauce', proteinPer100g: 0.9, carbsPer100g: 20.0, fatPer100g: 0.4, caloriesPer100g: 86, category: 'Condiments'),
    NutritionInfo(name: 'Oyster Sauce', proteinPer100g: 1.4, carbsPer100g: 10.9, fatPer100g: 0.3, caloriesPer100g: 51, category: 'Condiments'),
    NutritionInfo(name: 'Vinegar', proteinPer100g: 0.0, carbsPer100g: 0.9, fatPer100g: 0.0, caloriesPer100g: 18, category: 'Condiments'),
    NutritionInfo(name: 'Jam', proteinPer100g: 0.4, carbsPer100g: 69.0, fatPer100g: 0.1, caloriesPer100g: 278, category: 'Condiments'),
    NutritionInfo(name: 'Peanut Butter', proteinPer100g: 25.0, carbsPer100g: 20.0, fatPer100g: 50.0, caloriesPer100g: 588, category: 'Condiments'),

    // ─── BEVERAGES ────────────────────────────────────────
    NutritionInfo(name: 'Orange Juice', proteinPer100g: 0.7, carbsPer100g: 10.4, fatPer100g: 0.2, caloriesPer100g: 45, category: 'Beverages'),
    NutritionInfo(name: 'Apple Juice', proteinPer100g: 0.1, carbsPer100g: 11.3, fatPer100g: 0.1, caloriesPer100g: 46, category: 'Beverages'),
    NutritionInfo(name: 'Coconut Water', proteinPer100g: 0.7, carbsPer100g: 3.7, fatPer100g: 0.2, caloriesPer100g: 19, category: 'Beverages'),
  ];


  /// Look up nutrition info for a food item by name.
  /// Uses fuzzy matching — finds best match from database.
  NutritionInfo getNutrition(String foodName) {
    final lower = foodName.toLowerCase().trim();

    // Exact match first
    for (final item in _database) {
      if (item.name.toLowerCase() == lower) return item;
    }

    // Partial match (food name contains database entry or vice versa)
    for (final item in _database) {
      if (lower.contains(item.name.toLowerCase()) ||
          item.name.toLowerCase().contains(lower)) {
        return item;
      }
    }

    // Word-level match
    final words = lower.split(' ');
    for (final item in _database) {
      final itemWords = item.name.toLowerCase().split(' ');
      for (final word in words) {
        if (word.length > 3 && itemWords.any((w) => w.contains(word))) {
          return item;
        }
      }
    }

    // Default fallback — generic food values
    return NutritionInfo(
      name: foodName,
      proteinPer100g: 5.0,
      carbsPer100g: 10.0,
      fatPer100g: 3.0,
      caloriesPer100g: 80,
      category: 'Other',
    );
  }

  /// Get all items in the database
  List<NutritionInfo> get allItems => _database;

  /// Search the database by name
  List<NutritionInfo> search(String query) {
    final lower = query.toLowerCase();
    return _database
        .where((item) => item.name.toLowerCase().contains(lower))
        .toList();
  }

  /// Returns mock scan results for demo/testing
  /// Simulates what a real fridge camera scan would detect
  List<FoodItem> getMockScanResults() {
    final now = DateTime.now();
    return [
      FoodItem(
        id: '${now.millisecondsSinceEpoch}_1',
        name: 'Eggs',
        category: 'Protein',
        quantity: 360,
        protein: 13.0,
        carbs: 1.1,
        fat: 11.0,
        calories: 155,
        detectedAt: now,
      ),
      FoodItem(
        id: '${now.millisecondsSinceEpoch}_2',
        name: 'Leftover Rice',
        category: 'Carbs',
        quantity: 400,
        protein: 2.7,
        carbs: 28.0,
        fat: 0.3,
        calories: 130,
        detectedAt: now,
      ),
      FoodItem(
        id: '${now.millisecondsSinceEpoch}_3',
        name: 'Chicken Breast',
        category: 'Protein',
        quantity: 500,
        protein: 31.0,
        carbs: 0.0,
        fat: 3.6,
        calories: 165,
        detectedAt: now,
      ),
      FoodItem(
        id: '${now.millisecondsSinceEpoch}_4',
        name: 'Milk',
        category: 'Dairy',
        quantity: 800,
        protein: 3.4,
        carbs: 5.0,
        fat: 1.0,
        calories: 42,
        detectedAt: now,
      ),
      FoodItem(
        id: '${now.millisecondsSinceEpoch}_5',
        name: 'Bell Pepper',
        category: 'Vegetables',
        quantity: 150,
        protein: 1.0,
        carbs: 6.0,
        fat: 0.3,
        calories: 31,
        detectedAt: now,
      ),
      FoodItem(
        id: '${now.millisecondsSinceEpoch}_6',
        name: 'Scallions',
        category: 'Vegetables',
        quantity: 50,
        protein: 1.8,
        carbs: 7.3,
        fat: 0.2,
        calories: 32,
        detectedAt: now,
      ),
      FoodItem(
        id: '${now.millisecondsSinceEpoch}_7',
        name: 'Butter',
        category: 'Dairy',
        quantity: 150,
        protein: 0.9,
        carbs: 0.1,
        fat: 81.0,
        calories: 717,
        detectedAt: now,
      ),
      FoodItem(
        id: '${now.millisecondsSinceEpoch}_8',
        name: 'Soy Sauce',
        category: 'Condiments',
        quantity: 200,
        protein: 5.6,
        carbs: 5.6,
        fat: 0.1,
        calories: 53,
        detectedAt: now,
      ),
    ];
  }
}
