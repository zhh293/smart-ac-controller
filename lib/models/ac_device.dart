import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ac_device.g.dart';

@JsonSerializable()
@HiveType(typeId: 0)
class ACDevice extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'id')
  final String id;

  @HiveField(1)
  @JsonKey(name: 'name')
  String name;

  @HiveField(2)
  @JsonKey(name: 'brand')
  final String brand;

  @HiveField(3)
  @JsonKey(name: 'model')
  final String model;

  @HiveField(4)
  @JsonKey(name: 'connectionType')
  final String connectionType;

  @HiveField(5)
  @JsonKey(name: 'isOnline')
  bool isOnline;

  @HiveField(6)
  @JsonKey(name: 'isPoweredOn')
  bool isPoweredOn;

  @HiveField(7)
  @JsonKey(name: 'temperature')
  int temperature;

  @HiveField(8)
  @JsonKey(name: 'targetTemperature')
  int targetTemperature;

  @HiveField(9)
  @JsonKey(name: 'mode')
  String mode;

  @HiveField(10)
  @JsonKey(name: 'fanSpeed')
  String fanSpeed;

  @HiveField(11)
  @JsonKey(name: 'swingDirection')
  String swingDirection;

  @HiveField(12)
  @JsonKey(name: 'timerMinutes')
  int? timerMinutes;

  @HiveField(13)
  @JsonKey(name: 'timerType')
  String? timerType;

  @HiveField(14)
  @JsonKey(name: 'groupId')
  String? groupId;

  @HiveField(15)
  @JsonKey(name: 'ipAddress')
  String? ipAddress;

  @HiveField(16)
  @JsonKey(name: 'bluetoothAddress')
  String? bluetoothAddress;

  @HiveField(17)
  @JsonKey(name: 'macAddress')
  String? macAddress;

  @HiveField(18)
  @JsonKey(name: 'lastUsedAt')
  DateTime? lastUsedAt;

  @HiveField(19)
  @JsonKey(name: 'totalUsageHours')
  double totalUsageHours;

  @HiveField(20)
  @JsonKey(name: 'powerRating')
  final double powerRating;

  @HiveField(21)
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;

  @HiveField(22)
  @JsonKey(name: 'notes')
  String? notes;

  ACDevice({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.connectionType,
    this.isOnline = false,
    this.isPoweredOn = false,
    this.temperature = 24,
    this.targetTemperature = 24,
    this.mode = 'cool',
    this.fanSpeed = 'auto',
    this.swingDirection = 'fixed',
    this.timerMinutes,
    this.timerType,
    this.groupId,
    this.ipAddress,
    this.bluetoothAddress,
    this.macAddress,
    this.lastUsedAt,
    this.totalUsageHours = 0,
    required this.powerRating,
    DateTime? createdAt,
    this.notes,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ACDevice.fromJson(Map<String, dynamic> json) =>
      _$ACDeviceFromJson(json);

  Map<String, dynamic> toJson() => _$ACDeviceToJson(this);

  ACDevice copyWith({
    String? name,
    bool? isOnline,
    bool? isPoweredOn,
    int? temperature,
    int? targetTemperature,
    String? mode,
    String? fanSpeed,
    String? swingDirection,
    int? timerMinutes,
    String? timerType,
    String? groupId,
    String? ipAddress,
    String? bluetoothAddress,
    String? macAddress,
    DateTime? lastUsedAt,
    double? totalUsageHours,
    String? notes,
  }) {
    return ACDevice(
      id: id,
      name: name ?? this.name,
      brand: brand,
      model: model,
      connectionType: connectionType,
      isOnline: isOnline ?? this.isOnline,
      isPoweredOn: isPoweredOn ?? this.isPoweredOn,
      temperature: temperature ?? this.temperature,
      targetTemperature: targetTemperature ?? this.targetTemperature,
      mode: mode ?? this.mode,
      fanSpeed: fanSpeed ?? this.fanSpeed,
      swingDirection: swingDirection ?? this.swingDirection,
      timerMinutes: timerMinutes ?? this.timerMinutes,
      timerType: timerType ?? this.timerType,
      groupId: groupId ?? this.groupId,
      ipAddress: ipAddress ?? this.ipAddress,
      bluetoothAddress: bluetoothAddress ?? this.bluetoothAddress,
      macAddress: macAddress ?? this.macAddress,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      totalUsageHours: totalUsageHours ?? this.totalUsageHours,
      powerRating: powerRating,
      createdAt: createdAt,
      notes: notes ?? this.notes,
    );
  }

  double get estimatedPowerConsumption {
    if (!isPoweredOn) return 0;
    double basePower = powerRating;

    switch (mode) {
      case 'cool':
        basePower *= 1.0;
        break;
      case 'heat':
        basePower *= 1.2;
        break;
      case 'fan':
        basePower *= 0.3;
        break;
      case 'dry':
        basePower *= 0.6;
        break;
    }

    switch (fanSpeed) {
      case 'low':
        basePower *= 0.7;
        break;
      case 'medium':
        basePower *= 0.85;
        break;
      case 'high':
        basePower *= 1.0;
        break;
      case 'auto':
        basePower *= 0.9;
        break;
    }

    return basePower;
  }

  String get modeDisplayName {
    switch (mode) {
      case 'cool':
        return '制冷';
      case 'heat':
        return '制热';
      case 'fan':
        return '送风';
      case 'dry':
        return '除湿';
      default:
        return '自动';
    }
  }

  String get fanSpeedDisplayName {
    switch (fanSpeed) {
      case 'low':
        return '低风';
      case 'medium':
        return '中风';
      case 'high':
        return '高风';
      default:
        return '自动';
    }
  }
}
