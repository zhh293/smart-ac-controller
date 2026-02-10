import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ac_device.dart';
import '../../services/device_service.dart';

final deviceServiceProvider = Provider<DeviceService>((ref) {
  return DeviceService();
});

final devicesProvider = FutureProvider<List<ACDevice>>((ref) async {
  final service = ref.watch(deviceServiceProvider);
  return await service.getAllDevices();
});

final deviceByIdProvider = FutureProvider.family<ACDevice?, String>((
  ref,
  id,
) async {
  final service = ref.watch(deviceServiceProvider);
  return await service.getDeviceById(id);
});

final onlineDevicesProvider = Provider<List<ACDevice>>((ref) {
  final devicesAsync = ref.watch(devicesProvider);
  return devicesAsync.value?.where((d) => d.isOnline).toList() ?? [];
});

final deviceNotifierProvider =
    StateNotifierProvider<DeviceNotifier, AsyncValue<List<ACDevice>>>((ref) {
      final service = ref.watch(deviceServiceProvider);
      return DeviceNotifier(service);
    });

class DeviceNotifier extends StateNotifier<AsyncValue<List<ACDevice>>> {
  final DeviceService _service;

  DeviceNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    state = const AsyncValue.loading();
    try {
      final devices = await _service.getAllDevices();
      state = AsyncValue.data(devices);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> addDevice(ACDevice device) async {
    try {
      await _service.addDevice(device);
      await _loadDevices();
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> updateDevice(ACDevice device) async {
    try {
      await _service.updateDevice(device);
      await _loadDevices();
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> deleteDevice(String deviceId) async {
    try {
      await _service.deleteDevice(deviceId);
      await _loadDevices();
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> togglePower(String deviceId) async {
    final currentDevices = state.value;
    if (currentDevices == null) return;

    final device = currentDevices.firstWhere((d) => d.id == deviceId);
    final updated = device.copyWith(
      isPoweredOn: !device.isPoweredOn,
      lastUsedAt: DateTime.now(),
    );

    await updateDevice(updated);
  }

  Future<void> setTemperature(String deviceId, int temperature) async {
    final currentDevices = state.value;
    if (currentDevices == null) return;

    final device = currentDevices.firstWhere((d) => d.id == deviceId);
    final updated = device.copyWith(
      temperature: temperature,
      targetTemperature: temperature,
      lastUsedAt: DateTime.now(),
    );

    await updateDevice(updated);
  }

  Future<void> setMode(String deviceId, String mode) async {
    final currentDevices = state.value;
    if (currentDevices == null) return;

    final device = currentDevices.firstWhere((d) => d.id == deviceId);
    final updated = device.copyWith(mode: mode, lastUsedAt: DateTime.now());

    await updateDevice(updated);
  }

  Future<void> setFanSpeed(String deviceId, String speed) async {
    final currentDevices = state.value;
    if (currentDevices == null) return;

    final device = currentDevices.firstWhere((d) => d.id == deviceId);
    final updated = device.copyWith(
      fanSpeed: speed,
      lastUsedAt: DateTime.now(),
    );

    await updateDevice(updated);
  }

  Future<void> setTimer(String deviceId, int? minutes, String? type) async {
    final currentDevices = state.value;
    if (currentDevices == null) return;

    final device = currentDevices.firstWhere((d) => d.id == deviceId);
    final updated = device.copyWith(
      timerMinutes: minutes,
      timerType: type,
      lastUsedAt: DateTime.now(),
    );

    await updateDevice(updated);
  }

  Future<void> setSwingDirection(String deviceId, String direction) async {
    final currentDevices = state.value;
    if (currentDevices == null) return;

    final device = currentDevices.firstWhere((d) => d.id == deviceId);
    final updated = device.copyWith(
      swingDirection: direction,
      lastUsedAt: DateTime.now(),
    );

    await updateDevice(updated);
  }

  Future<void> refresh() async {
    await _loadDevices();
  }
}
