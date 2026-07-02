class FoodItem {
  final String id;
  final String name;
  final String category;
  final double quantity; // in grams
  final double protein; // per 100g
  final double carbs; // per 100g
  final double fat; // per 100g
  final double calories; // per 100g
  final DateTime detectedAt;
  final String? imageUrl;

  FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.calories,
    required this.detectedAt,
    this.imageUrl,
  });

  double get totalProtein => (protein * quantity) / 100;
  double get totalCarbs => (carbs * quantity) / 100;
  double get totalFat => (fat * quantity) / 100;
  double get totalCalories => (calories * quantity) / 100;

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String? ?? 'Other',
      quantity: (json['quantity'] as num).toDouble(),
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0,
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      detectedAt: json['detectedAt'] != null
          ? DateTime.parse(json['detectedAt'] as String)
          : DateTime.now(),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'calories': calories,
      'detectedAt': detectedAt.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }

  FoodItem copyWith({
    String? id,
    String? name,
    String? category,
    double? quantity,
    double? protein,
    double? carbs,
    double? fat,
    double? calories,
    DateTime? detectedAt,
    String? imageUrl,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      calories: calories ?? this.calories,
      detectedAt: detectedAt ?? this.detectedAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
