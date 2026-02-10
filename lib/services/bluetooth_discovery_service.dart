import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:permission_handler/permission_handler.dart';

class BluetoothDevice {
  final String deviceId;
  final String name;
  final String? localName;
  final int? rssi;
  final String type;
  final bool isConnected;
  final DateTime discoveredAt;

  BluetoothDevice({
    required this.deviceId,
    required this.name,
    this.localName,
    this.rssi,
    this.type = 'unknown',
    this.isConnected = false,
    DateTime? discoveredAt,
  }) : discoveredAt = discoveredAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'name': name,
      'localName': localName,
      'rssi': rssi,
      'type': type,
      'isConnected': isConnected,
      'discoveredAt': discoveredAt.toIso8601String(),
    };
  }

  factory BluetoothDevice.fromJson(Map<String, dynamic> json) {
    return BluetoothDevice(
      deviceId: json['deviceId'] as String,
      name: json['name'] as String,
      localName: json['localName'] as String?,
      rssi: json['rssi'] as int?,
      type: json['type'] as String? ?? 'unknown',
      isConnected: json['isConnected'] as bool? ?? false,
      discoveredAt: json['discoveredAt'] != null
          ? DateTime.parse(json['discoveredAt'] as String)
          : DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'BluetoothDevice(id: $deviceId, name: $name, rssi: $rssi)';
  }
}

enum ScanState { idle, scanning, stopped, error }

class ScanEvent {
  final ScanState state;
  final String? message;
  final BluetoothDevice? device;

  ScanEvent({required this.state, this.message, this.device});

  factory ScanEvent.scanning() => ScanEvent(state: ScanState.scanning);

  factory ScanEvent.stopped() => ScanEvent(state: ScanState.stopped);

  factory ScanEvent.error(String message) =>
      ScanEvent(state: ScanState.error, message: message);

  factory ScanEvent.deviceFound(BluetoothDevice device) =>
      ScanEvent(state: ScanState.scanning, device: device);

  factory ScanEvent.info(String message) =>
      ScanEvent(state: ScanState.idle, message: message);
}

class BluetoothDiscoveryService {
  static final BluetoothDiscoveryService _instance =
      BluetoothDiscoveryService._internal();
  factory BluetoothDiscoveryService() => _instance;
  BluetoothDiscoveryService._internal();

  final StreamController<ScanEvent> _eventController =
      StreamController<ScanEvent>.broadcast();
  final Map<String, BluetoothDevice> _discoveredDevices = {};
  bool _isScanning = false;
  StreamSubscription<List<fbp.ScanResult>>? _scanSubscription;
  StreamSubscription<fbp.BluetoothAdapterState>? _stateSubscription;

  Stream<ScanEvent> get eventStream => _eventController.stream;

  List<BluetoothDevice> get discoveredDevices =>
      _discoveredDevices.values.toList();

  bool get isScanning => _isScanning;

  Future<bool> isBluetoothAvailable() async {
    if (kIsWeb) {
      return false;
    }

    try {
      final isSupported = await fbp.FlutterBluePlus.isSupported;
      if (!isSupported) {
        _eventController.add(ScanEvent.error('设备不支持蓝牙'));
        return false;
      }

      return true;
    } catch (e) {
      _eventController.add(ScanEvent.error('检查蓝牙状态失败: $e'));
      return false;
    }
  }

  Future<bool> isBluetoothEnabled() async {
    if (kIsWeb) {
      return false;
    }

    try {
      final isEnabled = await fbp.FlutterBluePlus.isOn;
      return isEnabled;
    } catch (e) {
      return false;
    }
  }

  Future<void> requestPermissions() async {
    if (kIsWeb) {
      return;
    }

    try {
      if (Platform.isAndroid) {
        final bluetoothStatus = await Permission.bluetooth.request();
        if (!bluetoothStatus.isGranted) {
          _eventController.add(ScanEvent.error('蓝牙权限被拒绝'));
          return;
        }

        final locationStatus = await Permission.location.request();
        if (!locationStatus.isGranted) {
          _eventController.add(ScanEvent.error('位置权限被拒绝（扫描需要位置权限）'));
          return;
        }
      } else if (Platform.isIOS) {
        final bluetoothStatus = await Permission.bluetooth.request();
        if (!bluetoothStatus.isGranted) {
          _eventController.add(ScanEvent.error('蓝牙权限被拒绝'));
          return;
        }
      }
    } catch (e) {
      _eventController.add(ScanEvent.error('请求权限失败: $e'));
    }
  }

  Future<void> startScan({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (_isScanning) {
      _eventController.add(ScanEvent.info('已经在扫描中'));
      return;
    }

    if (kIsWeb) {
      _simulateWebScan();
      return;
    }

    final isAvailable = await isBluetoothAvailable();
    if (!isAvailable) {
      return;
    }

    final isEnabled = await isBluetoothEnabled();
    if (!isEnabled) {
      _eventController.add(ScanEvent.error('蓝牙未开启，请在设置中开启'));
      return;
    }

    await requestPermissions();

    try {
      _isScanning = true;
      _discoveredDevices.clear();
      _eventController.add(ScanEvent.scanning());

      await fbp.FlutterBluePlus.startScan(timeout: timeout);

      _scanSubscription = fbp.FlutterBluePlus.scanResults.listen((results) {
        for (fbp.ScanResult result in results) {
          _processScanResult(result);
        }
      });

      _stateSubscription = fbp.FlutterBluePlus.adapterState.listen((state) {
        if (state != fbp.BluetoothAdapterState.on) {
          _eventController.add(ScanEvent.error('蓝牙已关闭'));
          stopScan();
        }
      });

      Timer(timeout, () {
        if (_isScanning) {
          _eventController.add(ScanEvent.info('扫描超时'));
          stopScan();
        }
      });
    } catch (e) {
      _isScanning = false;
      _eventController.add(ScanEvent.error('扫描失败: $e'));
    }
  }

  void _processScanResult(fbp.ScanResult result) {
    final device = result.device;
    final deviceId = device.remoteId.toString();
    final rssi = result.rssi;

    if (_discoveredDevices.containsKey(deviceId)) {
      final existing = _discoveredDevices[deviceId]!;
      _discoveredDevices[deviceId] = BluetoothDevice(
        deviceId: existing.deviceId,
        name: existing.name,
        localName: existing.localName,
        rssi: rssi,
        type: existing.type,
        isConnected: existing.isConnected,
        discoveredAt: existing.discoveredAt,
      );
    } else {
      final deviceType = _identifyDeviceType(
        device.platformName,
        device.localName,
      );
      final bluetoothDevice = BluetoothDevice(
        deviceId: deviceId,
        name: device.platformName.isNotEmpty ? device.platformName : '未知设备',
        localName: device.localName,
        rssi: rssi,
        type: deviceType,
        isConnected: device.isConnected,
      );
      _discoveredDevices[deviceId] = bluetoothDevice;
      _eventController.add(ScanEvent.deviceFound(bluetoothDevice));
    }
  }

  String _identifyDeviceType(String name, String? localName) {
    final combined = (name + ' ' + (localName ?? '')).toLowerCase();

    if (combined.contains('air') ||
        combined.contains('ac') ||
        combined.contains('空调')) {
      return 'air_conditioner';
    } else if (combined.contains('smart') || combined.contains('智能')) {
      return 'smart_device';
    } else if (combined.contains('sensor') || combined.contains('传感器')) {
      return 'sensor';
    } else if (combined.contains('thermostat') || combined.contains('温控')) {
      return 'thermostat';
    }

    return 'unknown';
  }

  Future<void> stopScan() async {
    if (!_isScanning) {
      return;
    }

    _isScanning = false;

    try {
      await _scanSubscription?.cancel();
      await _stateSubscription?.cancel();
      await fbp.FlutterBluePlus.stopScan();
    } catch (e) {
      _eventController.add(ScanEvent.error('停止扫描失败: $e'));
    }

    _eventController.add(ScanEvent.stopped());
    _eventController.add(
      ScanEvent.info('扫描完成，发现 ${_discoveredDevices.length} 个设备'),
    );
  }

  Future<void> connectToDevice(String deviceId) async {
    if (kIsWeb) {
      _eventController.add(ScanEvent.error('Web平台不支持蓝牙连接'));
      return;
    }

    try {
      final device = fbp.BluetoothDevice.fromId(deviceId);
      await device.connect();

      _eventController.add(ScanEvent.info('已连接到 ${device.platformName}'));

      if (_discoveredDevices.containsKey(deviceId)) {
        _discoveredDevices[deviceId] = BluetoothDevice(
          deviceId: _discoveredDevices[deviceId]!.deviceId,
          name: _discoveredDevices[deviceId]!.name,
          localName: _discoveredDevices[deviceId]!.localName,
          rssi: _discoveredDevices[deviceId]!.rssi,
          type: _discoveredDevices[deviceId]!.type,
          isConnected: true,
          discoveredAt: _discoveredDevices[deviceId]!.discoveredAt,
        );
      }
    } catch (e) {
      _eventController.add(ScanEvent.error('连接失败: $e'));
    }
  }

  Future<void> disconnectFromDevice(String deviceId) async {
    if (kIsWeb) {
      return;
    }

    try {
      final device = fbp.BluetoothDevice.fromId(deviceId);
      await device.disconnect();

      _eventController.add(ScanEvent.info('已断开连接'));

      if (_discoveredDevices.containsKey(deviceId)) {
        _discoveredDevices[deviceId] = BluetoothDevice(
          deviceId: _discoveredDevices[deviceId]!.deviceId,
          name: _discoveredDevices[deviceId]!.name,
          localName: _discoveredDevices[deviceId]!.localName,
          rssi: _discoveredDevices[deviceId]!.rssi,
          type: _discoveredDevices[deviceId]!.type,
          isConnected: false,
          discoveredAt: _discoveredDevices[deviceId]!.discoveredAt,
        );
      }
    } catch (e) {
      _eventController.add(ScanEvent.error('断开连接失败: $e'));
    }
  }

  void _simulateWebScan() {
    _isScanning = true;
    _discoveredDevices.clear();
    _eventController.add(ScanEvent.scanning());
    _eventController.add(ScanEvent.info('Web平台模拟蓝牙扫描中...'));

    final mockDevices = [
      BluetoothDevice(
        deviceId: '00:1A:2B:3C:4D:5E',
        name: 'Smart AC Living Room',
        localName: '智能空调-客厅',
        rssi: -45,
        type: 'air_conditioner',
      ),
      BluetoothDevice(
        deviceId: '00:1A:2B:3C:4D:5F',
        name: 'Smart AC Bedroom',
        localName: '智能空调-卧室',
        rssi: -60,
        type: 'air_conditioner',
      ),
      BluetoothDevice(
        deviceId: '00:1A:2B:3C:4D:60',
        name: 'Temperature Sensor',
        localName: '温湿度传感器',
        rssi: -70,
        type: 'sensor',
      ),
      BluetoothDevice(
        deviceId: '00:1A:2B:3C:4D:61',
        name: 'Smart Thermostat',
        localName: '智能温控器',
        rssi: -55,
        type: 'thermostat',
      ),
    ];

    int index = 0;
    Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (index >= mockDevices.length) {
        timer.cancel();
        _isScanning = false;
        _eventController.add(ScanEvent.stopped());
        _eventController.add(
          ScanEvent.info('扫描完成，发现 ${_discoveredDevices.length} 个设备'),
        );
        return;
      }

      final device = mockDevices[index];
      _discoveredDevices[device.deviceId] = device;
      _eventController.add(ScanEvent.deviceFound(device));
      index++;
    });
  }

  void dispose() {
    _scanSubscription?.cancel();
    _stateSubscription?.cancel();
    _eventController.close();
  }
}
