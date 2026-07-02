class FridgeStatus {
  final double temperature; // Celsius
  final double humidity; // Percentage
  final double energyUsageWatts;
  final double dailyEnergyKwh;
  final bool doorOpen;
  final bool energySaveMode;
  final int compressorSpeed; // 0-100 percentage
  final double freezerTemperature;
  final double fridgeTemperature;
  final DateTime lastUpdated;

  FridgeStatus({
    required this.temperature,
    required this.humidity,
    required this.energyUsageWatts,
    required this.dailyEnergyKwh,
    required this.doorOpen,
    required this.energySaveMode,
    required this.compressorSpeed,
    required this.freezerTemperature,
    required this.fridgeTemperature,
    required this.lastUpdated,
  });

  factory FridgeStatus.initial() {
    return FridgeStatus(
      temperature: 4.0,
      humidity: 45.0,
      energyUsageWatts: 65.0,
      dailyEnergyKwh: 1.2,
      doorOpen: false,
      energySaveMode: false,
      compressorSpeed: 50,
      freezerTemperature: -18.0,
      fridgeTemperature: 4.0,
      lastUpdated: DateTime.now(),
    );
  }

  factory FridgeStatus.fromJson(Map<String, dynamic> json) {
    return FridgeStatus(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 4.0,
      humidity: (json['humidity'] as num?)?.toDouble() ?? 45.0,
      energyUsageWatts:
          (json['energyUsageWatts'] as num?)?.toDouble() ?? 65.0,
      dailyEnergyKwh: (json['dailyEnergyKwh'] as num?)?.toDouble() ?? 1.2,
      doorOpen: json['doorOpen'] as bool? ?? false,
      energySaveMode: json['energySaveMode'] as bool? ?? false,
      compressorSpeed: json['compressorSpeed'] as int? ?? 50,
      freezerTemperature:
          (json['freezerTemperature'] as num?)?.toDouble() ?? -18.0,
      fridgeTemperature:
          (json['fridgeTemperature'] as num?)?.toDouble() ?? 4.0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'energyUsageWatts': energyUsageWatts,
      'dailyEnergyKwh': dailyEnergyKwh,
      'doorOpen': doorOpen,
      'energySaveMode': energySaveMode,
      'compressorSpeed': compressorSpeed,
      'freezerTemperature': freezerTemperature,
      'fridgeTemperature': fridgeTemperature,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  FridgeStatus copyWith({
    double? temperature,
    double? humidity,
    double? energyUsageWatts,
    double? dailyEnergyKwh,
    bool? doorOpen,
    bool? energySaveMode,
    int? compressorSpeed,
    double? freezerTemperature,
    double? fridgeTemperature,
    DateTime? lastUpdated,
  }) {
    return FridgeStatus(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      energyUsageWatts: energyUsageWatts ?? this.energyUsageWatts,
      dailyEnergyKwh: dailyEnergyKwh ?? this.dailyEnergyKwh,
      doorOpen: doorOpen ?? this.doorOpen,
      energySaveMode: energySaveMode ?? this.energySaveMode,
      compressorSpeed: compressorSpeed ?? this.compressorSpeed,
      freezerTemperature: freezerTemperature ?? this.freezerTemperature,
      fridgeTemperature: fridgeTemperature ?? this.fridgeTemperature,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
