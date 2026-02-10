import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'usage_statistics.g.dart';

@JsonSerializable()
@HiveType(typeId: 4)
class UsageStatistics extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'deviceId')
  final String deviceId;

  @HiveField(1)
  @JsonKey(name: 'date')
  final DateTime date;

  @HiveField(2)
  @JsonKey(name: 'usageMinutes')
  int usageMinutes;

  @HiveField(3)
  @JsonKey(name: 'energyConsumption')
  double energyConsumption;

  @HiveField(4)
  @JsonKey(name: 'modeUsage')
  final Map<String, int> modeUsage;

  @HiveField(5)
  @JsonKey(name: 'temperatureReadings')
  final List<TemperatureReading> temperatureReadings;

  @HiveField(6)
  @JsonKey(name: 'peakUsageHours')
  final List<int> peakUsageHours;

  UsageStatistics({
    required this.deviceId,
    required this.date,
    this.usageMinutes = 0,
    this.energyConsumption = 0,
    Map<String, int>? modeUsage,
    List<TemperatureReading>? temperatureReadings,
    List<int>? peakUsageHours,
  }) : modeUsage = modeUsage ?? {},
       temperatureReadings = temperatureReadings ?? [],
       peakUsageHours = peakUsageHours ?? [];

  factory UsageStatistics.fromJson(Map<String, dynamic> json) =>
      _$UsageStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$UsageStatisticsToJson(this);

  void addUsage(int minutes, double energy) {
    usageMinutes += minutes;
    energyConsumption += energy;
  }

  void addModeUsage(String mode) {
    modeUsage[mode] = (modeUsage[mode] ?? 0) + 1;
  }

  void addTemperatureReading(int temperature) {
    temperatureReadings.add(
      TemperatureReading(timestamp: DateTime.now(), temperature: temperature),
    );
  }

  void addPeakUsageHour(int hour) {
    if (!peakUsageHours.contains(hour)) {
      peakUsageHours.add(hour);
    }
  }

  double get averageTemperature {
    if (temperatureReadings.isEmpty) return 0;
    final total = temperatureReadings.fold<int>(
      0,
      (sum, reading) => sum + reading.temperature,
    );
    return total / temperatureReadings.length;
  }

  String get mostUsedMode {
    if (modeUsage.isEmpty) return 'auto';
    return modeUsage.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}

@JsonSerializable()
@HiveType(typeId: 5)
class TemperatureReading extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'timestamp')
  final DateTime timestamp;

  @HiveField(1)
  @JsonKey(name: 'temperature')
  final int temperature;

  TemperatureReading({required this.timestamp, required this.temperature});

  factory TemperatureReading.fromJson(Map<String, dynamic> json) =>
      _$TemperatureReadingFromJson(json);

  Map<String, dynamic> toJson() => _$TemperatureReadingToJson(this);
}
