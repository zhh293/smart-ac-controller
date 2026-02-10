// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 6;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettings(
      themeMode: fields[0] as String,
      soundEnabled: fields[1] as bool,
      vibrationEnabled: fields[2] as bool,
      language: fields[3] as String,
      quickActions: (fields[4] as List?)?.cast<QuickAction>(),
      weatherEnabled: fields[5] as bool,
      weatherLocation: fields[6] as String?,
      weatherAutoMode: fields[7] as bool,
      voiceControlEnabled: fields[8] as bool,
      notificationsEnabled: fields[9] as bool,
      maintenanceReminderEnabled: fields[10] as bool,
      maintenanceReminderDays: fields[11] as int,
      appPasswordEnabled: fields[12] as bool,
      appPassword: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.themeMode)
      ..writeByte(1)
      ..write(obj.soundEnabled)
      ..writeByte(2)
      ..write(obj.vibrationEnabled)
      ..writeByte(3)
      ..write(obj.language)
      ..writeByte(4)
      ..write(obj.quickActions)
      ..writeByte(5)
      ..write(obj.weatherEnabled)
      ..writeByte(6)
      ..write(obj.weatherLocation)
      ..writeByte(7)
      ..write(obj.weatherAutoMode)
      ..writeByte(8)
      ..write(obj.voiceControlEnabled)
      ..writeByte(9)
      ..write(obj.notificationsEnabled)
      ..writeByte(10)
      ..write(obj.maintenanceReminderEnabled)
      ..writeByte(11)
      ..write(obj.maintenanceReminderDays)
      ..writeByte(12)
      ..write(obj.appPasswordEnabled)
      ..writeByte(13)
      ..write(obj.appPassword);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuickActionAdapter extends TypeAdapter<QuickAction> {
  @override
  final int typeId = 7;

  @override
  QuickAction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuickAction(
      id: fields[0] as String,
      name: fields[1] as String,
      icon: fields[2] as String,
      action: fields[3] as String,
      params: (fields[4] as Map).cast<String, dynamic>(),
      sortOrder: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, QuickAction obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.action)
      ..writeByte(4)
      ..write(obj.params)
      ..writeByte(5)
      ..write(obj.sortOrder);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuickActionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) => UserSettings(
      themeMode: json['themeMode'] as String? ?? 'dark',
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      language: json['language'] as String? ?? 'zh',
      quickActions: (json['quickActions'] as List<dynamic>?)
          ?.map((e) => QuickAction.fromJson(e as Map<String, dynamic>))
          .toList(),
      weatherEnabled: json['weatherEnabled'] as bool? ?? true,
      weatherLocation: json['weatherLocation'] as String?,
      weatherAutoMode: json['weatherAutoMode'] as bool? ?? false,
      voiceControlEnabled: json['voiceControlEnabled'] as bool? ?? false,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      maintenanceReminderEnabled:
          json['maintenanceReminderEnabled'] as bool? ?? true,
      maintenanceReminderDays:
          (json['maintenanceReminderDays'] as num?)?.toInt() ?? 90,
      appPasswordEnabled: json['appPasswordEnabled'] as bool? ?? false,
      appPassword: json['appPassword'] as String?,
    );

Map<String, dynamic> _$UserSettingsToJson(UserSettings instance) =>
    <String, dynamic>{
      'themeMode': instance.themeMode,
      'soundEnabled': instance.soundEnabled,
      'vibrationEnabled': instance.vibrationEnabled,
      'language': instance.language,
      'quickActions': instance.quickActions,
      'weatherEnabled': instance.weatherEnabled,
      'weatherLocation': instance.weatherLocation,
      'weatherAutoMode': instance.weatherAutoMode,
      'voiceControlEnabled': instance.voiceControlEnabled,
      'notificationsEnabled': instance.notificationsEnabled,
      'maintenanceReminderEnabled': instance.maintenanceReminderEnabled,
      'maintenanceReminderDays': instance.maintenanceReminderDays,
      'appPasswordEnabled': instance.appPasswordEnabled,
      'appPassword': instance.appPassword,
    };

QuickAction _$QuickActionFromJson(Map<String, dynamic> json) => QuickAction(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      action: json['action'] as String,
      params: json['params'] as Map<String, dynamic>,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$QuickActionToJson(QuickAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'action': instance.action,
      'params': instance.params,
      'sortOrder': instance.sortOrder,
    };
