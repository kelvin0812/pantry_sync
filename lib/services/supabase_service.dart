import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/food_item.dart';
import '../models/fridge_status.dart';

/// Supabase service for real-time database communication.
/// Handles IoT data sync: fridge inventory, status, and sensor readings.
///
/// Setup:
/// 1. Create a Supabase project at https://supabase.com
/// 2. Run the SQL migration (see supabase/migrations/)
/// 3. Add your URL and anon key to lib/config/supabase_config.dart
class SupabaseService {
  // Singleton
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient? _client;
  bool _initialized = false;

  // Stream controllers for real-time data
  final _inventoryController =
      StreamController<List<FoodItem>>.broadcast();
  final _fridgeStatusController =
      StreamController<FridgeStatus>.broadcast();

  // Cache latest values for late subscribers
  List<FoodItem>? _lastInventory;
  FridgeStatus? _lastFridgeStatus;

  Stream<List<FoodItem>> get inventoryStream async* {
    if (_lastInventory != null) {
      yield _lastInventory!;
    }
    yield* _inventoryController.stream;
  }

  Stream<FridgeStatus> get fridgeStatusStream async* {
    if (_lastFridgeStatus != null) {
      yield _lastFridgeStatus!;
    }
    yield* _fridgeStatusController.stream;
  }

  bool get isInitialized => _initialized;

  /// Initialize Supabase connection.
  /// Call this in main() before runApp().
  Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    if (_initialized) return;

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    _client = Supabase.instance.client;
    _initialized = true;

    // Start listening to real-time changes
    _subscribeToInventory();
    _subscribeToFridgeStatus();

    // Load initial data
    await _fetchInventory();
    await _fetchFridgeStatus();
  }

  /// Initialize with mock data (for demo without Supabase credentials)
  Future<void> initializeMock() async {
    if (_initialized) return;
    _initialized = true;
    _emitMockData();
  }

  // ─── INVENTORY ──────────────────────────────────────────────

  /// Fetch current inventory from Supabase
  Future<void> _fetchInventory() async {
    try {
      final response = await _client!
          .from('inventory')
          .select()
          .order('detected_at', ascending: false);

      final items = (response as List)
          .map((row) => FoodItem.fromJson(_mapRowToFoodJson(row)))
          .toList();

      _lastInventory = items;
      _inventoryController.add(items);
    } catch (e) {
      // On error, use mock data
      _emitMockData();
    }
  }

  /// Subscribe to real-time inventory changes (IoT inserts/updates)
  void _subscribeToInventory() {
    _client!
        .from('inventory')
        .stream(primaryKey: ['id'])
        .listen((rows) {
      final items = rows
          .map((row) => FoodItem.fromJson(_mapRowToFoodJson(row)))
          .toList();
      _lastInventory = items;
      _inventoryController.add(items);
    });
  }

  /// Add a scanned food item to inventory
  Future<void> addFoodItem(FoodItem item) async {
    if (_client == null) return;
    await _client!.from('inventory').insert({
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

  /// Remove a food item from inventory
  Future<void> removeFoodItem(String id) async {
    if (_client == null) return;
    await _client!.from('inventory').delete().eq('id', id);
  }

  /// Update food item quantity (e.g., after partial use)
  Future<void> updateFoodQuantity(String id, double newQuantity) async {
    if (_client == null) return;
    await _client!
        .from('inventory')
        .update({'quantity': newQuantity})
        .eq('id', id);
  }

  // ─── FRIDGE STATUS (IoT sensor data) ───────────────────────

  /// Fetch current fridge status
  Future<void> _fetchFridgeStatus() async {
    try {
      final response = await _client!
          .from('fridge_status')
          .select()
          .order('last_updated', ascending: false)
          .limit(1)
          .single();

      final status = _mapRowToFridgeStatus(response);
      _lastFridgeStatus = status;
      _fridgeStatusController.add(status);
    } catch (e) {
      _lastFridgeStatus = FridgeStatus.initial();
      _fridgeStatusController.add(_lastFridgeStatus!);
    }
  }

  /// Subscribe to real-time fridge status updates from IoT sensors
  void _subscribeToFridgeStatus() {
    _client!
        .from('fridge_status')
        .stream(primaryKey: ['id'])
        .listen((rows) {
      if (rows.isNotEmpty) {
        final status = _mapRowToFridgeStatus(rows.first);
        _lastFridgeStatus = status;
        _fridgeStatusController.add(status);
      }
    });
  }

  /// Update fridge settings (sent from app to IoT device)
  Future<void> updateFridgeSettings({
    double? fridgeTemperature,
    double? freezerTemperature,
    bool? energySaveMode,
    int? compressorSpeed,
  }) async {
    if (_client == null) {
      // Mock mode: just update local state
      final current = _lastFridgeStatus ?? FridgeStatus.initial();
      final updated = current.copyWith(
        fridgeTemperature: fridgeTemperature,
        freezerTemperature: freezerTemperature,
        energySaveMode: energySaveMode,
        compressorSpeed: compressorSpeed,
        lastUpdated: DateTime.now(),
      );
      _lastFridgeStatus = updated;
      _fridgeStatusController.add(updated);
      return;
    }

    final updates = <String, dynamic>{
      'last_updated': DateTime.now().toIso8601String(),
    };
    if (fridgeTemperature != null) {
      updates['fridge_temperature'] = fridgeTemperature;
    }
    if (freezerTemperature != null) {
      updates['freezer_temperature'] = freezerTemperature;
    }
    if (energySaveMode != null) {
      updates['energy_save_mode'] = energySaveMode;
    }
    if (compressorSpeed != null) {
      updates['compressor_speed'] = compressorSpeed;
    }

    await _client!.from('fridge_status').update(updates).eq('id', 1);
  }

  // ─── DATA MAPPING HELPERS ──────────────────────────────────

  Map<String, dynamic> _mapRowToFoodJson(Map<String, dynamic> row) {
    return {
      'id': row['id'].toString(),
      'name': row['name'] ?? 'Unknown',
      'category': row['category'] ?? 'Other',
      'quantity': row['quantity'] ?? 100.0,
      'protein': row['protein'] ?? 0.0,
      'carbs': row['carbs'] ?? 0.0,
      'fat': row['fat'] ?? 0.0,
      'calories': row['calories'] ?? 0.0,
      'detectedAt': row['detected_at'] ?? DateTime.now().toIso8601String(),
      'imageUrl': row['image_url'],
    };
  }

  FridgeStatus _mapRowToFridgeStatus(Map<String, dynamic> row) {
    return FridgeStatus(
      temperature: (row['fridge_temperature'] as num?)?.toDouble() ?? 4.0,
      humidity: (row['humidity'] as num?)?.toDouble() ?? 45.0,
      energyUsageWatts:
          (row['energy_usage_watts'] as num?)?.toDouble() ?? 65.0,
      dailyEnergyKwh:
          (row['daily_energy_kwh'] as num?)?.toDouble() ?? 1.2,
      doorOpen: row['door_open'] as bool? ?? false,
      energySaveMode: row['energy_save_mode'] as bool? ?? false,
      compressorSpeed: (row['compressor_speed'] as num?)?.toInt() ?? 50,
      freezerTemperature:
          (row['freezer_temperature'] as num?)?.toDouble() ?? -18.0,
      fridgeTemperature:
          (row['fridge_temperature'] as num?)?.toDouble() ?? 4.0,
      lastUpdated: row['last_updated'] != null
          ? DateTime.parse(row['last_updated'] as String)
          : DateTime.now(),
    );
  }

  // ─── MOCK DATA (for demo without Supabase) ─────────────────

  void _emitMockData() {
    final mockItems = [
      FoodItem(id: '1', name: 'Eggs', category: 'Protein', quantity: 360, protein: 13.0, carbs: 1.1, fat: 11.0, calories: 155, detectedAt: DateTime.now().subtract(const Duration(hours: 2))),
      FoodItem(id: '2', name: 'Leftover Rice', category: 'Carbs', quantity: 400, protein: 2.7, carbs: 28.0, fat: 0.3, calories: 130, detectedAt: DateTime.now().subtract(const Duration(hours: 5))),
      FoodItem(id: '3', name: 'Scallions', category: 'Vegetables', quantity: 50, protein: 1.8, carbs: 7.3, fat: 0.2, calories: 32, detectedAt: DateTime.now().subtract(const Duration(hours: 2))),
      FoodItem(id: '4', name: 'Chicken Breast', category: 'Protein', quantity: 500, protein: 31.0, carbs: 0.0, fat: 3.6, calories: 165, detectedAt: DateTime.now().subtract(const Duration(days: 1))),
      FoodItem(id: '5', name: 'Milk', category: 'Dairy', quantity: 800, protein: 3.4, carbs: 5.0, fat: 1.0, calories: 42, detectedAt: DateTime.now().subtract(const Duration(days: 2))),
      FoodItem(id: '6', name: 'Bell Pepper', category: 'Vegetables', quantity: 150, protein: 1.0, carbs: 6.0, fat: 0.3, calories: 31, detectedAt: DateTime.now().subtract(const Duration(hours: 8))),
      FoodItem(id: '7', name: 'Soy Sauce', category: 'Condiments', quantity: 200, protein: 5.6, carbs: 5.6, fat: 0.1, calories: 53, detectedAt: DateTime.now().subtract(const Duration(days: 7))),
      FoodItem(id: '8', name: 'Butter', category: 'Dairy', quantity: 150, protein: 0.9, carbs: 0.1, fat: 81.0, calories: 717, detectedAt: DateTime.now().subtract(const Duration(days: 3))),
    ];
    _lastInventory = mockItems;
    _inventoryController.add(mockItems);

    _lastFridgeStatus = FridgeStatus.initial();
    _fridgeStatusController.add(_lastFridgeStatus!);
  }

  void dispose() {
    _inventoryController.close();
    _fridgeStatusController.close();
  }
}
