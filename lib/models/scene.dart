import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'scene.g.dart';

@JsonSerializable()
@HiveType(typeId: 1)
class Scene extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'id')
  final String id;

  @HiveField(1)
  @JsonKey(name: 'name')
  String name;

  @HiveField(2)
  @JsonKey(name: 'icon')
  String icon;

  @HiveField(3)
  @JsonKey(name: 'color')
  String color;

  @HiveField(4)
  @JsonKey(name: 'deviceSettings')
  final List<DeviceSetting> deviceSettings;

  @HiveField(5)
  @JsonKey(name: 'triggerType')
  String triggerType;

  @HiveField(6)
  @JsonKey(name: 'triggerTime')
  String? triggerTime;

  @HiveField(7)
  @JsonKey(name: 'weatherCondition')
  String? weatherCondition;

  @HiveField(8)
  @JsonKey(name: 'isEnabled')
  bool isEnabled;

  @HiveField(9)
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;

  @HiveField(10)
  @JsonKey(name: 'lastTriggeredAt')
  DateTime? lastTriggeredAt;

  Scene({
    required this.id,
    required this.name,
    this.icon = 'auto_awesome',
    this.color = '#00F0FF',
    required this.deviceSettings,
    this.triggerType = 'manual',
    this.triggerTime,
    this.weatherCondition,
    this.isEnabled = true,
    DateTime? createdAt,
    this.lastTriggeredAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Scene.fromJson(Map<String, dynamic> json) => _$SceneFromJson(json);

  Map<String, dynamic> toJson() => _$SceneToJson(this);

  Scene copyWith({
    String? name,
    String? icon,
    String? color,
    List<DeviceSetting>? deviceSettings,
    String? triggerType,
    String? triggerTime,
    String? weatherCondition,
    bool? isEnabled,
    DateTime? lastTriggeredAt,
  }) {
    return Scene(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      deviceSettings: deviceSettings ?? this.deviceSettings,
      triggerType: triggerType ?? this.triggerType,
      triggerTime: triggerTime ?? this.triggerTime,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt,
      lastTriggeredAt: lastTriggeredAt ?? this.lastTriggeredAt,
    );
  }
}

@JsonSerializable()
@HiveType(typeId: 2)
class DeviceSetting extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'deviceId')
  final String deviceId;

  @HiveField(1)
  @JsonKey(name: 'isPoweredOn')
  bool isPoweredOn;

  @HiveField(2)
  @JsonKey(name: 'temperature')
  int? temperature;

  @HiveField(3)
  @JsonKey(name: 'mode')
  String? mode;

  @HiveField(4)
  @JsonKey(name: 'fanSpeed')
  String? fanSpeed;

  @HiveField(5)
  @JsonKey(name: 'swingDirection')
  String? swingDirection;

  @HiveField(6)
  @JsonKey(name: 'timerMinutes')
  int? timerMinutes;

  @HiveField(7)
  @JsonKey(name: 'timerType')
  String? timerType;

  DeviceSetting({
    required this.deviceId,
    this.isPoweredOn = true,
    this.temperature,
    this.mode,
    this.fanSpeed,
    this.swingDirection,
    this.timerMinutes,
    this.timerType,
  });

  factory DeviceSetting.fromJson(Map<String, dynamic> json) =>
      _$DeviceSettingFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceSettingToJson(this);
}
