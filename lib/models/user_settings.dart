import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_settings.g.dart';

@JsonSerializable()
@HiveType(typeId: 6)
class UserSettings extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'themeMode')
  String themeMode;

  @HiveField(1)
  @JsonKey(name: 'soundEnabled')
  bool soundEnabled;

  @HiveField(2)
  @JsonKey(name: 'vibrationEnabled')
  bool vibrationEnabled;

  @HiveField(3)
  @JsonKey(name: 'language')
  String language;

  @HiveField(4)
  @JsonKey(name: 'quickActions')
  final List<QuickAction> quickActions;

  @HiveField(5)
  @JsonKey(name: 'weatherEnabled')
  bool weatherEnabled;

  @HiveField(6)
  @JsonKey(name: 'weatherLocation')
  String? weatherLocation;

  @HiveField(7)
  @JsonKey(name: 'weatherAutoMode')
  bool weatherAutoMode;

  @HiveField(8)
  @JsonKey(name: 'voiceControlEnabled')
  bool voiceControlEnabled;

  @HiveField(9)
  @JsonKey(name: 'notificationsEnabled')
  bool notificationsEnabled;

  @HiveField(10)
  @JsonKey(name: 'maintenanceReminderEnabled')
  bool maintenanceReminderEnabled;

  @HiveField(11)
  @JsonKey(name: 'maintenanceReminderDays')
  int maintenanceReminderDays;

  @HiveField(12)
  @JsonKey(name: 'appPasswordEnabled')
  bool appPasswordEnabled;

  @HiveField(13)
  @JsonKey(name: 'appPassword')
  String? appPassword;

  UserSettings({
    this.themeMode = 'dark',
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.language = 'zh',
    List<QuickAction>? quickActions,
    this.weatherEnabled = true,
    this.weatherLocation,
    this.weatherAutoMode = false,
    this.voiceControlEnabled = false,
    this.notificationsEnabled = true,
    this.maintenanceReminderEnabled = true,
    this.maintenanceReminderDays = 90,
    this.appPasswordEnabled = false,
    this.appPassword,
  }) : quickActions = quickActions ?? _defaultQuickActions();

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$UserSettingsToJson(this);

  static List<QuickAction> _defaultQuickActions() {
    return [
      QuickAction(
        id: 'qa_1',
        name: '快速制冷',
        icon: 'ac_unit',
        action: 'set_temperature',
        params: {'temperature': 24, 'mode': 'cool'},
        sortOrder: 0,
      ),
      QuickAction(
        id: 'qa_2',
        name: '睡眠模式',
        icon: 'bedtime',
        action: 'set_scene',
        params: {'sceneId': 'sleep'},
        sortOrder: 1,
      ),
      QuickAction(
        id: 'qa_3',
        name: '快速制热',
        icon: 'whatshot',
        action: 'set_temperature',
        params: {'temperature': 26, 'mode': 'heat'},
        sortOrder: 2,
      ),
    ];
  }
}

@JsonSerializable()
@HiveType(typeId: 7)
class QuickAction extends HiveObject {
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
  @JsonKey(name: 'action')
  final String action;

  @HiveField(4)
  @JsonKey(name: 'params')
  final Map<String, dynamic> params;

  @HiveField(5)
  @JsonKey(name: 'sortOrder')
  int sortOrder;

  QuickAction({
    required this.id,
    required this.name,
    required this.icon,
    required this.action,
    required this.params,
    this.sortOrder = 0,
  });

  factory QuickAction.fromJson(Map<String, dynamic> json) =>
      _$QuickActionFromJson(json);

  Map<String, dynamic> toJson() => _$QuickActionToJson(this);
}
