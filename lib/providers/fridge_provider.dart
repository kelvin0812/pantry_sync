import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/fridge_status.dart';
import '../services/supabase_service.dart';

class FridgeProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  FridgeStatus _status = FridgeStatus.initial();
  bool _isLoading = true;
  StreamSubscription<FridgeStatus>? _subscription;

  // Energy history for chart (mock: last 7 days)
  final List<double> _energyHistory = [1.1, 1.3, 1.2, 0.9, 1.0, 1.2, 1.2];

  FridgeStatus get status => _status;
  bool get isLoading => _isLoading;
  List<double> get energyHistory => _energyHistory;

  double get weeklyEnergy =>
      _energyHistory.fold(0.0, (sum, val) => sum + val);
  double get averageDailyEnergy => weeklyEnergy / _energyHistory.length;

  void initialize() {
    _subscription = _supabaseService.fridgeStatusStream.listen((status) {
      _status = status;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> setFridgeTemperature(double temp) async {
    await _supabaseService.updateFridgeSettings(fridgeTemperature: temp);
    _status = _status.copyWith(fridgeTemperature: temp);
    notifyListeners();
  }

  Future<void> setFreezerTemperature(double temp) async {
    await _supabaseService.updateFridgeSettings(freezerTemperature: temp);
    _status = _status.copyWith(freezerTemperature: temp);
    notifyListeners();
  }

  Future<void> toggleEnergySaveMode() async {
    final newMode = !_status.energySaveMode;
    await _supabaseService.updateFridgeSettings(energySaveMode: newMode);
    _status = _status.copyWith(
      energySaveMode: newMode,
      compressorSpeed: newMode ? 30 : 50,
    );
    notifyListeners();
  }

  Future<void> setCompressorSpeed(int speed) async {
    await _supabaseService.updateFridgeSettings(compressorSpeed: speed);
    _status = _status.copyWith(compressorSpeed: speed);
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
