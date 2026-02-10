import 'package:hive_flutter/hive_flutter.dart';
import 'device_group.dart';

class DeviceGroupAdapter extends TypeAdapter<DeviceGroup> {
  @override
  final int typeId = 3;

  @override
  DeviceGroup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return DeviceGroup(
      id: fields[0] as String,
      name: fields[1] as String,
      icon: fields[2] as String,
      color: fields[3] as String,
      deviceIds: fields[4] as List<String>,
      sortOrder: fields[5] as int,
      createdAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DeviceGroup obj) {
    writer.writeByte(7);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.name);
    writer.writeByte(2);
    writer.write(obj.icon);
    writer.writeByte(3);
    writer.write(obj.color);
    writer.writeByte(4);
    writer.write(obj.deviceIds);
    writer.writeByte(5);
    writer.write(obj.sortOrder);
    writer.writeByte(6);
    writer.write(obj.createdAt);
  }
}
