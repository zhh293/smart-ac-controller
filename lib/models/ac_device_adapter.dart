import 'package:hive_flutter/hive_flutter.dart';
import 'ac_device.dart';

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
      createdAt: fields[21] as DateTime,
      notes: fields[22] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ACDevice obj) {
    writer.writeByte(23);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.name);
    writer.writeByte(2);
    writer.write(obj.brand);
    writer.writeByte(3);
    writer.write(obj.model);
    writer.writeByte(4);
    writer.write(obj.connectionType);
    writer.writeByte(5);
    writer.write(obj.isOnline);
    writer.writeByte(6);
    writer.write(obj.isPoweredOn);
    writer.writeByte(7);
    writer.write(obj.temperature);
    writer.writeByte(8);
    writer.write(obj.targetTemperature);
    writer.writeByte(9);
    writer.write(obj.mode);
    writer.writeByte(10);
    writer.write(obj.fanSpeed);
    writer.writeByte(11);
    writer.write(obj.swingDirection);
    writer.writeByte(12);
    writer.write(obj.timerMinutes);
    writer.writeByte(13);
    writer.write(obj.timerType);
    writer.writeByte(14);
    writer.write(obj.groupId);
    writer.writeByte(15);
    writer.write(obj.ipAddress);
    writer.writeByte(16);
    writer.write(obj.bluetoothAddress);
    writer.writeByte(17);
    writer.write(obj.macAddress);
    writer.writeByte(18);
    writer.write(obj.lastUsedAt);
    writer.writeByte(19);
    writer.write(obj.totalUsageHours);
    writer.writeByte(20);
    writer.write(obj.powerRating);
    writer.writeByte(21);
    writer.write(obj.createdAt);
    writer.writeByte(22);
    writer.write(obj.notes);
  }
}
