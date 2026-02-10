// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usage_statistics.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

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
      modeUsage: (fields[4] as Map?)?.cast<String, int>(),
      temperatureReadings: (fields[5] as List?)?.cast<TemperatureReading>(),
      peakUsageHours: (fields[6] as List?)?.cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, UsageStatistics obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.deviceId)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.usageMinutes)
      ..writeByte(3)
      ..write(obj.energyConsumption)
      ..writeByte(4)
      ..write(obj.modeUsage)
      ..writeByte(5)
      ..write(obj.temperatureReadings)
      ..writeByte(6)
      ..write(obj.peakUsageHours);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsageStatisticsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
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
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.temperature);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemperatureReadingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsageStatistics _$UsageStatisticsFromJson(Map<String, dynamic> json) =>
    UsageStatistics(
      deviceId: json['deviceId'] as String,
      date: DateTime.parse(json['date'] as String),
      usageMinutes: (json['usageMinutes'] as num?)?.toInt() ?? 0,
      energyConsumption: (json['energyConsumption'] as num?)?.toDouble() ?? 0,
      modeUsage: (json['modeUsage'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      temperatureReadings: (json['temperatureReadings'] as List<dynamic>?)
          ?.map((e) => TemperatureReading.fromJson(e as Map<String, dynamic>))
          .toList(),
      peakUsageHours: (json['peakUsageHours'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$UsageStatisticsToJson(UsageStatistics instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'date': instance.date.toIso8601String(),
      'usageMinutes': instance.usageMinutes,
      'energyConsumption': instance.energyConsumption,
      'modeUsage': instance.modeUsage,
      'temperatureReadings': instance.temperatureReadings,
      'peakUsageHours': instance.peakUsageHours,
    };

TemperatureReading _$TemperatureReadingFromJson(Map<String, dynamic> json) =>
    TemperatureReading(
      timestamp: DateTime.parse(json['timestamp'] as String),
      temperature: (json['temperature'] as num).toInt(),
    );

Map<String, dynamic> _$TemperatureReadingToJson(TemperatureReading instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'temperature': instance.temperature,
    };
