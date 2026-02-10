import 'package:hive_flutter/hive_flutter.dart';
import 'scene.dart';

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
      deviceSettings: fields[4] as List<DeviceSetting>,
      triggerType: fields[5] as String,
      triggerTime: fields[6] as String?,
      weatherCondition: fields[7] as String?,
      isEnabled: fields[8] as bool,
      createdAt: fields[9] as DateTime,
      lastTriggeredAt: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Scene obj) {
    writer.writeByte(11);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.name);
    writer.writeByte(2);
    writer.write(obj.icon);
    writer.writeByte(3);
    writer.write(obj.color);
    writer.writeByte(4);
    writer.write(obj.deviceSettings);
    writer.writeByte(5);
    writer.write(obj.triggerType);
    writer.writeByte(6);
    writer.write(obj.triggerTime);
    writer.writeByte(7);
    writer.write(obj.weatherCondition);
    writer.writeByte(8);
    writer.write(obj.isEnabled);
    writer.writeByte(9);
    writer.write(obj.createdAt);
    writer.writeByte(10);
    writer.write(obj.lastTriggeredAt);
  }
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
    writer.writeByte(8);
    writer.writeByte(0);
    writer.write(obj.deviceId);
    writer.writeByte(1);
    writer.write(obj.isPoweredOn);
    writer.writeByte(2);
    writer.write(obj.temperature);
    writer.writeByte(3);
    writer.write(obj.mode);
    writer.writeByte(4);
    writer.write(obj.fanSpeed);
    writer.writeByte(5);
    writer.write(obj.swingDirection);
    writer.writeByte(6);
    writer.write(obj.timerMinutes);
    writer.writeByte(7);
    writer.write(obj.timerType);
  }
}
