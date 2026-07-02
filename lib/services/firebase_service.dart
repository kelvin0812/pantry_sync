import 'dart:async';

import '../models/food_item.dart';
import '../models/fridge_status.dart';

/// Service for Firebase Realtime Database communication.
/// Handles real-time sync of fridge inventory and status.
///
/// Note: Firebase must be configured with `flutterfire configure` before use.
/// For development/demo, this uses mock data streams.
class FirebaseService {
  // Singleton
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Stream controllers for real-time data
  final _inventoryController =
      StreamController<List<FoodItem>>.broadcast();
  final _fridgeStatusController =
      StreamController<FridgeStatus>.broadcast();

  // Cache latest values so late subscribers get data immediately
  List<FoodItem>? _lastInventory;
  FridgeStatus? _lastFridgeStatus;

  Stream<List<FoodItem>> get inventoryStream async* {
    // Emit cached value immediately for late subscribers
    if (_lastInventory != null) {
      yield _lastInventory!;
    }
    yield* _inventoryController.stream;
  }

  Stream<FridgeStatus> get fridgeStatusStream async* {
    // Emit cached value immediately for late subscribers
    if (_lastFridgeStatus != null) {
      yield _lastFridgeStatus!;
    }
    yield* _fridgeStatusController.stream;
  }

  bool _initialized = false;

  /// Initialize Firebase connection and start listening
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // For demo: emit mock data
    // In production, replace with Firebase Realtime Database listeners
    _emitMockInventory();
    _emitMockFridgeStatus();
  }

  void _emitMockInventory() {
    final mockItems = [
      FoodItem(
        id: '1',
        name: 'Eggs',
        category: 'Protein',
        quantity: 360, // ~6 eggs
        protein: 13.0,
        carbs: 1.1,
        fat: 11.0,
        calories: 155,
        detectedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      FoodItem(
        id: '2',
        name: 'Leftover Rice',
        category: 'Carbs',
        quantity: 400,
        protein: 2.7,
        carbs: 28.0,
        fat: 0.3,
        calories: 130,
        detectedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      FoodItem(
        id: '3',
        name: 'Scallions',
        category: 'Vegetables',
        quantity: 50,
        protein: 1.8,
        carbs: 7.3,
        fat: 0.2,
        calories: 32,
        detectedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      FoodItem(
        id: '4',
        name: 'Chicken Breast',
        category: 'Protein',
        quantity: 500,
        protein: 31.0,
        carbs: 0.0,
        fat: 3.6,
        calories: 165,
        detectedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      FoodItem(
        id: '5',
        name: 'Milk',
        category: 'Dairy',
        quantity: 800,
        protein: 3.4,
        carbs: 5.0,
        fat: 1.0,
        calories: 42,
        detectedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      FoodItem(
        id: '6',
        name: 'Bell Pepper',
        category: 'Vegetables',
        quantity: 150,
        protein: 1.0,
        carbs: 6.0,
        fat: 0.3,
        calories: 31,
        detectedAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      FoodItem(
        id: '7',
        name: 'Soy Sauce',
        category: 'Condiments',
        quantity: 200,
        protein: 5.6,
        carbs: 5.6,
        fat: 0.1,
        calories: 53,
        detectedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      FoodItem(
        id: '8',
        name: 'Butter',
        category: 'Dairy',
        quantity: 150,
        protein: 0.9,
        carbs: 0.1,
        fat: 81.0,
        calories: 717,
        detectedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

    _lastInventory = mockItems;
    _inventoryController.add(mockItems);
  }

  void _emitMockFridgeStatus() {
    _lastFridgeStatus = FridgeStatus.initial();
    _fridgeStatusController.add(_lastFridgeStatus!);
  }

  /// Update fridge settings (temperature, energy save mode, etc.)
  Future<void> updateFridgeSettings({
    double? fridgeTemperature,
    double? freezerTemperature,
    bool? energySaveMode,
    int? compressorSpeed,
  }) async {
    // In production: write to Firebase Realtime Database
    // For demo: emit updated status
    final current = FridgeStatus.initial();
    final updated = current.copyWith(
      fridgeTemperature: fridgeTemperature,
      freezerTemperature: freezerTemperature,
      energySaveMode: energySaveMode,
      compressorSpeed: compressorSpeed,
      lastUpdated: DateTime.now(),
    );
    _fridgeStatusController.add(updated);
  }

  void dispose() {
    _inventoryController.close();
    _fridgeStatusController.close();
  }
}
