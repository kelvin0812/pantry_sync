class Recipe {
  final String title;
  final String description;
  final List<String> ingredients;
  final List<String> steps;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final NutritionInfo nutrition;
  final String difficulty;

  Recipe({
    required this.title,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.nutrition,
    required this.difficulty,
  });

  int get totalTimeMinutes => prepTimeMinutes + cookTimeMinutes;
}

class NutritionInfo {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  NutritionInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}
