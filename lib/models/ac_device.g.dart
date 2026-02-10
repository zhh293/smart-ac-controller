// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ac_device.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ACDeviceAdapter extends TypeAdapter<ACDevice> {
  @override
  final int typeId = 0;

  @override
  ACDevice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ACDevice(
      id: fields[0] as String,
      name: fields[1] as String,
      brand: fields[2] as String,
      model: fields[3] as String,
      connectionType: fields[4] as String,
      isOnline: fields[5] as bool,
      isPoweredOn: fields[6] as bool,
      temperature: fields[7] as int,
      targetTemperature: fields[8] as int,
      mode: fields[9] as String,
      fanSpeed: fields[10] as String,
      swingDirection: fields[11] as String,
      timerMinutes: fields[12] as int?,
      timerType: fields[13] as String?,
      groupId: fields[14] as String?,
      ipAddress: fields[15] as String?,
      bluetoothAddress: fields[16] as String?,
      macAddress: fields[17] as String?,
      lastUsedAt: fields[18] as DateTime?,
      totalUsageHours: fields[19] as double,
      powerRating: fields[20] as double,
      createdAt: fields[21] as DateTime?,
      notes: fields[22] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ACDevice obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.brand)
      ..writeByte(3)
      ..write(obj.model)
      ..writeByte(4)
      ..write(obj.connectionType)
      ..writeByte(5)
      ..write(obj.isOnline)
      ..writeByte(6)
      ..write(obj.isPoweredOn)
      ..writeByte(7)
      ..write(obj.temperature)
      ..writeByte(8)
      ..write(obj.targetTemperature)
      ..writeByte(9)
      ..write(obj.mode)
      ..writeByte(10)
      ..write(obj.fanSpeed)
      ..writeByte(11)
      ..write(obj.swingDirection)
      ..writeByte(12)
      ..write(obj.timerMinutes)
      ..writeByte(13)
      ..write(obj.timerType)
      ..writeByte(14)
      ..write(obj.groupId)
      ..writeByte(15)
      ..write(obj.ipAddress)
      ..writeByte(16)
      ..write(obj.bluetoothAddress)
      ..writeByte(17)
      ..write(obj.macAddress)
      ..writeByte(18)
      ..write(obj.lastUsedAt)
      ..writeByte(19)
      ..write(obj.totalUsageHours)
      ..writeByte(20)
      ..write(obj.powerRating)
      ..writeByte(21)
      ..write(obj.createdAt)
      ..writeByte(22)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ACDeviceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ACDevice _$ACDeviceFromJson(Map<String, dynamic> json) => ACDevice(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      connectionType: json['connectionType'] as String,
      isOnline: json['isOnline'] as bool? ?? false,
      isPoweredOn: json['isPoweredOn'] as bool? ?? false,
      temperature: (json['temperature'] as num?)?.toInt() ?? 24,
      targetTemperature: (json['targetTemperature'] as num?)?.toInt() ?? 24,
      mode: json['mode'] as String? ?? 'cool',
      fanSpeed: json['fanSpeed'] as String? ?? 'auto',
      swingDirection: json['swingDirection'] as String? ?? 'fixed',
      timerMinutes: (json['timerMinutes'] as num?)?.toInt(),
      timerType: json['timerType'] as String?,
      groupId: json['groupId'] as String?,
      ipAddress: json['ipAddress'] as String?,
      bluetoothAddress: json['bluetoothAddress'] as String?,
      macAddress: json['macAddress'] as String?,
      lastUsedAt: json['lastUsedAt'] == null
          ? null
          : DateTime.parse(json['lastUsedAt'] as String),
      totalUsageHours: (json['totalUsageHours'] as num?)?.toDouble() ?? 0,
      powerRating: (json['powerRating'] as num).toDouble(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$ACDeviceToJson(ACDevice instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'brand': instance.brand,
      'model': instance.model,
      'connectionType': instance.connectionType,
      'isOnline': instance.isOnline,
      'isPoweredOn': instance.isPoweredOn,
      'temperature': instance.temperature,
      'targetTemperature': instance.targetTemperature,
      'mode': instance.mode,
      'fanSpeed': instance.fanSpeed,
      'swingDirection': instance.swingDirection,
      'timerMinutes': instance.timerMinutes,
      'timerType': instance.timerType,
      'groupId': instance.groupId,
      'ipAddress': instance.ipAddress,
      'bluetoothAddress': instance.bluetoothAddress,
      'macAddress': instance.macAddress,
      'lastUsedAt': instance.lastUsedAt?.toIso8601String(),
      'totalUsageHours': instance.totalUsageHours,
      'powerRating': instance.powerRating,
      'createdAt': instance.createdAt.toIso8601String(),
      'notes': instance.notes,
    };
