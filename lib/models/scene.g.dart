// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scene.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SceneAdapter extends TypeAdapter<Scene> {
  @override
  final int typeId = 1;

  @override
  Scene read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Scene(
      id: fields[0] as String,
      name: fields[1] as String,
      icon: fields[2] as String,
      color: fields[3] as String,
      deviceSettings: (fields[4] as List).cast<DeviceSetting>(),
      triggerType: fields[5] as String,
      triggerTime: fields[6] as String?,
      weatherCondition: fields[7] as String?,
      isEnabled: fields[8] as bool,
      createdAt: fields[9] as DateTime?,
      lastTriggeredAt: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Scene obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.color)
      ..writeByte(4)
      ..write(obj.deviceSettings)
      ..writeByte(5)
      ..write(obj.triggerType)
      ..writeByte(6)
      ..write(obj.triggerTime)
      ..writeByte(7)
      ..write(obj.weatherCondition)
      ..writeByte(8)
      ..write(obj.isEnabled)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.lastTriggeredAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SceneAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DeviceSettingAdapter extends TypeAdapter<DeviceSetting> {
  @override
  final int typeId = 2;

  @override
  DeviceSetting read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeviceSetting(
      deviceId: fields[0] as String,
      isPoweredOn: fields[1] as bool,
      temperature: fields[2] as int?,
      mode: fields[3] as String?,
      fanSpeed: fields[4] as String?,
      swingDirection: fields[5] as String?,
      timerMinutes: fields[6] as int?,
      timerType: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DeviceSetting obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.deviceId)
      ..writeByte(1)
      ..write(obj.isPoweredOn)
      ..writeByte(2)
      ..write(obj.temperature)
      ..writeByte(3)
      ..write(obj.mode)
      ..writeByte(4)
      ..write(obj.fanSpeed)
      ..writeByte(5)
      ..write(obj.swingDirection)
      ..writeByte(6)
      ..write(obj.timerMinutes)
      ..writeByte(7)
      ..write(obj.timerType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceSettingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Scene _$SceneFromJson(Map<String, dynamic> json) => Scene(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String? ?? 'auto_awesome',
      color: json['color'] as String? ?? '#00F0FF',
      deviceSettings: (json['deviceSettings'] as List<dynamic>)
          .map((e) => DeviceSetting.fromJson(e as Map<String, dynamic>))
          .toList(),
      triggerType: json['triggerType'] as String? ?? 'manual',
      triggerTime: json['triggerTime'] as String?,
      weatherCondition: json['weatherCondition'] as String?,
      isEnabled: json['isEnabled'] as bool? ?? true,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      lastTriggeredAt: json['lastTriggeredAt'] == null
          ? null
          : DateTime.parse(json['lastTriggeredAt'] as String),
    );

Map<String, dynamic> _$SceneToJson(Scene instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'color': instance.color,
      'deviceSettings': instance.deviceSettings,
      'triggerType': instance.triggerType,
      'triggerTime': instance.triggerTime,
      'weatherCondition': instance.weatherCondition,
      'isEnabled': instance.isEnabled,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastTriggeredAt': instance.lastTriggeredAt?.toIso8601String(),
    };

DeviceSetting _$DeviceSettingFromJson(Map<String, dynamic> json) =>
    DeviceSetting(
      deviceId: json['deviceId'] as String,
      isPoweredOn: json['isPoweredOn'] as bool? ?? true,
      temperature: (json['temperature'] as num?)?.toInt(),
      mode: json['mode'] as String?,
      fanSpeed: json['fanSpeed'] as String?,
      swingDirection: json['swingDirection'] as String?,
      timerMinutes: (json['timerMinutes'] as num?)?.toInt(),
      timerType: json['timerType'] as String?,
    );

Map<String, dynamic> _$DeviceSettingToJson(DeviceSetting instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'isPoweredOn': instance.isPoweredOn,
      'temperature': instance.temperature,
      'mode': instance.mode,
      'fanSpeed': instance.fanSpeed,
      'swingDirection': instance.swingDirection,
      'timerMinutes': instance.timerMinutes,
      'timerType': instance.timerType,
    };
