import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'device_group.g.dart';

@JsonSerializable()
@HiveType(typeId: 3)
class DeviceGroup extends HiveObject {
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
  @JsonKey(name: 'deviceIds')
  final List<String> deviceIds;

  @HiveField(5)
  @JsonKey(name: 'sortOrder')
  int sortOrder;

  @HiveField(6)
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;

  DeviceGroup({
    required this.id,
    required this.name,
    this.icon = 'folder',
    this.color = '#7B61FF',
    required this.deviceIds,
    this.sortOrder = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory DeviceGroup.fromJson(Map<String, dynamic> json) =>
      _$DeviceGroupFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceGroupToJson(this);

  DeviceGroup copyWith({
    String? name,
    String? icon,
    String? color,
    List<String>? deviceIds,
    int? sortOrder,
  }) {
    return DeviceGroup(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      deviceIds: deviceIds ?? this.deviceIds,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
    );
  }
}
