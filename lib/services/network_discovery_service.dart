import 'dart:async';
import 'dart:io' show Platform, Socket, InternetAddressType, NetworkInterface;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:network_discovery/network_discovery.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class DiscoveredDevice {
  final String ipAddress;
  final String? macAddress;
  final String? deviceName;
  final String? manufacturer;
  final int port;
  final DateTime discoveredAt;
  bool isReachable;

  DiscoveredDevice({
    required this.ipAddress,
    this.macAddress,
    this.deviceName,
    this.manufacturer,
    this.port = 80,
    DateTime? discoveredAt,
    this.isReachable = false,
  }) : discoveredAt = discoveredAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'ipAddress': ipAddress,
      'macAddress': macAddress,
      'deviceName': deviceName,
      'manufacturer': manufacturer,
      'port': port,
      'discoveredAt': discoveredAt.toIso8601String(),
      'isReachable': isReachable,
    };
  }

  factory DiscoveredDevice.fromJson(Map<String, dynamic> json) {
    return DiscoveredDevice(
      ipAddress: json['ipAddress'] as String,
      macAddress: json['macAddress'] as String?,
      deviceName: json['deviceName'] as String?,
      manufacturer: json['manufacturer'] as String?,
      port: json['port'] as int? ?? 80,
      discoveredAt: json['discoveredAt'] != null
          ? DateTime.parse(json['discoveredAt'] as String)
          : null,
      isReachable: json['isReachable'] as bool? ?? false,
    );
  }
}

class NetworkDiscoveryService {
  static final NetworkDiscoveryService _instance =
      NetworkDiscoveryService._internal();
  factory NetworkDiscoveryService() => _instance;
  NetworkDiscoveryService._internal();

  final List<DiscoveredDevice> _discoveredDevices = [];
  final StreamController<DiscoveryEvent> _eventController =
      StreamController<DiscoveryEvent>.broadcast();
  bool _isScanning = false;
  Timer? _scanTimer;

  Stream<DiscoveryEvent> get eventStream => _eventController.stream;
  List<DiscoveredDevice> get discoveredDevices =>
      List.unmodifiable(_discoveredDevices);
  bool get isScanning => _isScanning;
  bool get isWebPlatform => kIsWeb;

  Future<bool> checkConnectivity() async {
    if (kIsWeb) {
      return true;
    }
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult == ConnectivityResult.wifi;
    } catch (e) {
      return true;
    }
  }

  Future<String?> getLocalIpAddress() async {
    if (kIsWeb) {
      return '192.168.1.100';
    }
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.any,
      );
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      _eventController.add(DiscoveryEvent.error('获取本地IP失败: $e'));
    }
    return null;
  }

  Future<String?> getWifiSSID() async {
    if (kIsWeb) {
      return 'Web WiFi (模拟)';
    }
    try {
      final connectivity = Connectivity();
      final result = await connectivity.checkConnectivity();
      if (result == ConnectivityResult.wifi) {
        return 'WiFi Connected';
      }
      return null;
    } catch (e) {
      _eventController.add(DiscoveryEvent.error('获取WiFi SSID失败: $e'));
      return null;
    }
  }

  Future<void> startScan({
    Duration timeout = const Duration(seconds: 30),
    String? subnet,
    List<int> ports = const [80, 8080, 8888],
  }) async {
    if (_isScanning) {
      _eventController.add(DiscoveryEvent.error('扫描已在进行中'));
      return;
    }

    _isScanning = true;
    _discoveredDevices.clear();
    _eventController.add(DiscoveryEvent.started());

    if (kIsWeb) {
      await _simulateWebScan();
      return;
    }

    final hasWifi = await checkConnectivity();
    if (!hasWifi) {
      _eventController.add(DiscoveryEvent.error('未连接到WiFi网络'));
      _isScanning = false;
      return;
    }

    try {
      final localIp = await getLocalIpAddress();
      if (localIp == null) {
        throw Exception('无法获取本地IP地址');
      }

      final scanSubnet = subnet ?? _extractSubnet(localIp);
      _eventController.add(DiscoveryEvent.info('开始扫描子网: $scanSubnet'));

      for (final port in ports) {
        final stream = NetworkDiscovery.discover(scanSubnet, port);

        await for (final address in stream) {
          final device = DiscoveredDevice(ipAddress: address.ip, port: port);

          _addDevice(device);
          _eventController.add(DiscoveryEvent.deviceFound(device));

          await Future.delayed(const Duration(milliseconds: 50));
        }
      }

      _eventController.add(DiscoveryEvent.completed(_discoveredDevices));
    } catch (e) {
      _eventController.add(DiscoveryEvent.error('扫描失败: $e'));
    } finally {
      _isScanning = false;
    }
  }

  Future<void> _simulateWebScan() async {
    _eventController.add(DiscoveryEvent.info('Web平台模拟扫描中...'));

    final mockDevices = [
      DiscoveredDevice(
        ipAddress: '192.168.1.10',
        macAddress: '00:1A:2B:3C:4D:5E',
        deviceName: '智能空调-客厅',
        manufacturer: '格力',
        port: 80,
        isReachable: true,
      ),
      DiscoveredDevice(
        ipAddress: '192.168.1.20',
        macAddress: '00:1A:2B:3C:4D:5F',
        deviceName: '智能空调-卧室',
        manufacturer: '美的',
        port: 8080,
        isReachable: true,
      ),
      DiscoveredDevice(
        ipAddress: '192.168.1.30',
        macAddress: '00:1A:2B:3C:4D:60',
        deviceName: '智能空调-书房',
        manufacturer: '海尔',
        port: 8888,
        isReachable: false,
      ),
    ];

    for (int i = 0; i < mockDevices.length; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      _addDevice(mockDevices[i]);
      _eventController.add(DiscoveryEvent.deviceFound(mockDevices[i]));
    }

    await Future.delayed(const Duration(milliseconds: 500));
    _eventController.add(DiscoveryEvent.completed(_discoveredDevices));
    _isScanning = false;
  }

  Future<void> scanSpecificPort(
    int port, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (_isScanning) {
      _eventController.add(DiscoveryEvent.error('扫描已在进行中'));
      return;
    }

    _isScanning = true;
    _eventController.add(DiscoveryEvent.started());

    if (kIsWeb) {
      await _simulateWebScan();
      return;
    }

    try {
      final localIp = await getLocalIpAddress();
      if (localIp == null) {
        throw Exception('无法获取本地IP地址');
      }

      final subnet = _extractSubnet(localIp);
      _eventController.add(DiscoveryEvent.info('扫描端口 $port 在子网: $subnet'));

      final stream = NetworkDiscovery.discover(subnet, port);

      await for (final address in stream) {
        final device = DiscoveredDevice(ipAddress: address.ip, port: port);

        _addDevice(device);
        _eventController.add(DiscoveryEvent.deviceFound(device));

        await Future.delayed(const Duration(milliseconds: 50));
      }

      _eventController.add(DiscoveryEvent.completed(_discoveredDevices));
    } catch (e) {
      _eventController.add(DiscoveryEvent.error('扫描失败: $e'));
    } finally {
      _isScanning = false;
    }
  }

  Future<bool> testDeviceConnection(
    String ipAddress, {
    int port = 80,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (kIsWeb) {
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    }
    try {
      final socket = await Socket.connect(ipAddress, port, timeout: timeout);
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> verifyAllDevices({int port = 80}) async {
    _eventController.add(DiscoveryEvent.info('开始验证设备连接...'));

    for (int i = 0; i < _discoveredDevices.length; i++) {
      final device = _discoveredDevices[i];
      final isReachable = await testDeviceConnection(
        device.ipAddress,
        port: device.port,
      );

      _discoveredDevices[i] = DiscoveredDevice(
        ipAddress: device.ipAddress,
        macAddress: device.macAddress,
        deviceName: device.deviceName,
        manufacturer: device.manufacturer,
        port: device.port,
        discoveredAt: device.discoveredAt,
        isReachable: isReachable,
      );

      _eventController.add(
        DiscoveryEvent.deviceVerified(_discoveredDevices[i]),
      );
    }

    _eventController.add(DiscoveryEvent.completed(_discoveredDevices));
  }

  void stopScan() {
    _isScanning = false;
    _scanTimer?.cancel();
    _scanTimer = null;
    _eventController.add(DiscoveryEvent.stopped());
  }

  void clearDevices() {
    _discoveredDevices.clear();
    _eventController.add(DiscoveryEvent.cleared());
  }

  void _addDevice(DiscoveredDevice device) {
    if (!_discoveredDevices.any((d) => d.ipAddress == device.ipAddress)) {
      _discoveredDevices.add(device);
    }
  }

  String _extractSubnet(String ipAddress) {
    final parts = ipAddress.split('.');
    if (parts.length == 4) {
      return '${parts[0]}.${parts[1]}.${parts[2]}';
    }
    return '192.168.1';
  }

  void dispose() {
    stopScan();
    _eventController.close();
  }
}

class DiscoveryEvent {
  final DiscoveryEventType type;
  final String? message;
  final DiscoveredDevice? device;
  final List<DiscoveredDevice>? devices;

  DiscoveryEvent.started()
    : type = DiscoveryEventType.started,
      message = null,
      device = null,
      devices = null;

  DiscoveryEvent.stopped()
    : type = DiscoveryEventType.stopped,
      message = null,
      device = null,
      devices = null;

  DiscoveryEvent.completed(List<DiscoveredDevice> foundDevices)
    : type = DiscoveryEventType.completed,
      message = null,
      device = null,
      devices = foundDevices;

  DiscoveryEvent.deviceFound(DiscoveredDevice foundDevice)
    : type = DiscoveryEventType.deviceFound,
      message = null,
      device = foundDevice,
      devices = null;

  DiscoveryEvent.deviceVerified(DiscoveredDevice verifiedDevice)
    : type = DiscoveryEventType.deviceVerified,
      message = null,
      device = verifiedDevice,
      devices = null;

  DiscoveryEvent.error(String errorMessage)
    : type = DiscoveryEventType.error,
      message = errorMessage,
      device = null,
      devices = null;

  DiscoveryEvent.info(String infoMessage)
    : type = DiscoveryEventType.info,
      message = infoMessage,
      device = null,
      devices = null;

  DiscoveryEvent.cleared()
    : type = DiscoveryEventType.cleared,
      message = null,
      device = null,
      devices = null;
}

enum DiscoveryEventType {
  started,
  stopped,
  completed,
  deviceFound,
  deviceVerified,
  error,
  info,
  cleared,
}
