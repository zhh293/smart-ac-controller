import 'package:hive_flutter/hive_flutter.dart';
import 'user_settings.dart';

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
      quickActions: fields[4] as List<QuickAction>,
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
    writer.writeByte(14);
    writer.writeByte(0);
    writer.write(obj.themeMode);
    writer.writeByte(1);
    writer.write(obj.soundEnabled);
    writer.writeByte(2);
    writer.write(obj.vibrationEnabled);
    writer.writeByte(3);
    writer.write(obj.language);
    writer.writeByte(4);
    writer.write(obj.quickActions);
    writer.writeByte(5);
    writer.write(obj.weatherEnabled);
    writer.writeByte(6);
    writer.write(obj.weatherLocation);
    writer.writeByte(7);
    writer.write(obj.weatherAutoMode);
    writer.writeByte(8);
    writer.write(obj.voiceControlEnabled);
    writer.writeByte(9);
    writer.write(obj.notificationsEnabled);
    writer.writeByte(10);
    writer.write(obj.maintenanceReminderEnabled);
    writer.writeByte(11);
    writer.write(obj.maintenanceReminderDays);
    writer.writeByte(12);
    writer.write(obj.appPasswordEnabled);
    writer.writeByte(13);
    writer.write(obj.appPassword);
  }
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
      params: fields[4] as Map<String, dynamic>,
      sortOrder: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, QuickAction obj) {
    writer.writeByte(6);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.name);
    writer.writeByte(2);
    writer.write(obj.icon);
    writer.writeByte(3);
    writer.write(obj.action);
    writer.writeByte(4);
    writer.write(obj.params);
    writer.writeByte(5);
    writer.write(obj.sortOrder);
  }
}
