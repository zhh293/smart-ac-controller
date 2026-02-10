import 'package:hive_flutter/hive_flutter.dart';
import '../models/ac_device.dart';
import '../../core/constants/app_constants.dart';

class DeviceService {
  late Box<ACDevice> _devicesBox;

  Future<void> init() async {
    if (!Hive.isBoxOpen(AppConstants.devicesBoxName)) {
      _devicesBox = await Hive.openBox(AppConstants.devicesBoxName);
    } else {
      _devicesBox = Hive.box(AppConstants.devicesBoxName);
    }
  }

  Future<List<ACDevice>> getAllDevices() async {
    await init();
    return _devicesBox.values.toList();
  }

  Future<ACDevice?> getDeviceById(String id) async {
    await init();
    return _devicesBox.get(id);
  }

  Future<void> addDevice(ACDevice device) async {
    await init();
    await _devicesBox.put(device.id, device);
  }

  Future<void> updateDevice(ACDevice device) async {
    await init();
    await _devicesBox.put(device.id, device);
  }

  Future<void> deleteDevice(String deviceId) async {
    await init();
    await _devicesBox.delete(deviceId);
  }

  Future<List<ACDevice>> getDevicesByGroup(String groupId) async {
    await init();
    return _devicesBox.values
        .where((device) => device.groupId == groupId)
        .toList();
  }

  Future<List<ACDevice>> getOnlineDevices() async {
    await init();
    return _devicesBox.values.where((device) => device.isOnline).toList();
  }

  Future<void> clearAllDevices() async {
    await init();
    await _devicesBox.clear();
  }
}
