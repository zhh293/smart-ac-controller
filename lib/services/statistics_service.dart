import 'package:hive_flutter/hive_flutter.dart';
import '../models/usage_statistics.dart';
import '../../core/constants/app_constants.dart';

class StatisticsService {
  late Box<UsageStatistics> _statisticsBox;

  Future<void> init() async {
    if (!Hive.isBoxOpen(AppConstants.statisticsBoxName)) {
      _statisticsBox = await Hive.openBox(AppConstants.statisticsBoxName);
    } else {
      _statisticsBox = Hive.box(AppConstants.statisticsBoxName);
    }
  }

  Future<List<UsageStatistics>> getAllStatistics() async {
    await init();
    return _statisticsBox.values.toList();
  }

  Future<List<UsageStatistics>> getStatisticsByDevice(String deviceId) async {
    await init();
    return _statisticsBox.values
        .where((stat) => stat.deviceId == deviceId)
        .toList();
  }

  Future<UsageStatistics?> getStatisticsByDate(
    String deviceId,
    DateTime date,
  ) async {
    await init();
    final key = _generateKey(deviceId, date);
    return _statisticsBox.get(key);
  }

  Future<void> addUsageStatistics(UsageStatistics statistics) async {
    await init();
    final key = _generateKey(statistics.deviceId, statistics.date);
    await _statisticsBox.put(key, statistics);
  }

  Future<void> updateUsageStatistics(UsageStatistics statistics) async {
    await init();
    final key = _generateKey(statistics.deviceId, statistics.date);
    await _statisticsBox.put(key, statistics);
  }

  Future<void> deleteStatistics(String deviceId, DateTime date) async {
    await init();
    final key = _generateKey(deviceId, date);
    await _statisticsBox.delete(key);
  }

  Future<void> recordUsage(
    String deviceId,
    int minutes,
    double energyConsumption,
  ) async {
    await init();
    final today = DateTime.now();
    final normalizedDate = DateTime(today.year, today.month, today.day);

    final key = _generateKey(deviceId, normalizedDate);
    var statistics = _statisticsBox.get(key);

    if (statistics == null) {
      statistics = UsageStatistics(
        deviceId: deviceId,
        date: normalizedDate,
        usageMinutes: minutes,
        energyConsumption: energyConsumption,
      );
    } else {
      statistics.addUsage(minutes, energyConsumption);
    }

    await _statisticsBox.put(key, statistics);
  }

  Future<void> recordModeUsage(String deviceId, String mode) async {
    await init();
    final today = DateTime.now();
    final normalizedDate = DateTime(today.year, today.month, today.day);

    final key = _generateKey(deviceId, normalizedDate);
    var statistics = _statisticsBox.get(key);

    if (statistics == null) {
      statistics = UsageStatistics(deviceId: deviceId, date: normalizedDate);
    }

    statistics.addModeUsage(mode);
    await _statisticsBox.put(key, statistics);
  }

  Future<void> recordTemperatureReading(
    String deviceId,
    int temperature,
  ) async {
    await init();
    final today = DateTime.now();
    final normalizedDate = DateTime(today.year, today.month, today.day);

    final key = _generateKey(deviceId, normalizedDate);
    var statistics = _statisticsBox.get(key);

    if (statistics == null) {
      statistics = UsageStatistics(deviceId: deviceId, date: normalizedDate);
    }

    statistics.addTemperatureReading(temperature);
    await _statisticsBox.put(key, statistics);
  }

  Future<void> clearAllStatistics() async {
    await init();
    await _statisticsBox.clear();
  }

  String _generateKey(String deviceId, DateTime date) {
    return '${deviceId}_${date.year}_${date.month}_${date.day}';
  }
}
