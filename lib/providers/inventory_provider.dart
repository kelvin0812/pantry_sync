import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/food_item.dart';
import '../services/supabase_service.dart';

class InventoryProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<FoodItem> _items = [];
  bool _isLoading = true;
  StreamSubscription<List<FoodItem>>? _subscription;

  List<FoodItem> get items => _items;
  bool get isLoading => _isLoading;

  // Aggregated macros
  double get totalProtein =>
      _items.fold(0.0, (sum, item) => sum + item.totalProtein);
  double get totalCarbs =>
      _items.fold(0.0, (sum, item) => sum + item.totalCarbs);
  double get totalFat => _items.fold(0.0, (sum, item) => sum + item.totalFat);
  double get totalCalories =>
      _items.fold(0.0, (sum, item) => sum + item.totalCalories);

  // Category breakdown
  Map<String, List<FoodItem>> get itemsByCategory {
    final map = <String, List<FoodItem>>{};
    for (final item in _items) {
      map.putIfAbsent(item.category, () => []).add(item);
    }
    return map;
  }

  int get itemCount => _items.length;

  void initialize() {
    _subscription = _supabaseService.inventoryStream.listen((items) {
      _items = items;
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Add a food item (from scan or manual)
  Future<void> addItem(FoodItem item) async {
    await _supabaseService.addFoodItem(item);
  }

  /// Remove a food item
  Future<void> removeItem(String id) async {
    await _supabaseService.removeFoodItem(id);
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
