import 'package:hive_flutter/hive_flutter.dart';
import 'usage_statistics.dart';

class UsageStatisticsAdapter extends TypeAdapter<UsageStatistics> {
  @override
  final int typeId = 4;

  @override
  UsageStatistics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return UsageStatistics(
      deviceId: fields[0] as String,
      date: fields[1] as DateTime,
      usageMinutes: fields[2] as int,
      energyConsumption: fields[3] as double,
      modeUsage: fields[4] as Map<String, int>,
      temperatureReadings: fields[5] as List<TemperatureReading>,
      peakUsageHours: fields[6] as List<int>,
    );
  }

  @override
  void write(BinaryWriter writer, UsageStatistics obj) {
    writer.writeByte(7);
    writer.writeByte(0);
    writer.write(obj.deviceId);
    writer.writeByte(1);
    writer.write(obj.date);
    writer.writeByte(2);
    writer.write(obj.usageMinutes);
    writer.writeByte(3);
    writer.write(obj.energyConsumption);
    writer.writeByte(4);
    writer.write(obj.modeUsage);
    writer.writeByte(5);
    writer.write(obj.temperatureReadings);
    writer.writeByte(6);
    writer.write(obj.peakUsageHours);
  }
}

class TemperatureReadingAdapter extends TypeAdapter<TemperatureReading> {
  @override
  final int typeId = 5;

  @override
  TemperatureReading read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return TemperatureReading(
      timestamp: fields[0] as DateTime,
      temperature: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TemperatureReading obj) {
    writer.writeByte(2);
    writer.writeByte(0);
    writer.write(obj.timestamp);
    writer.writeByte(1);
    writer.write(obj.temperature);
  }
}
