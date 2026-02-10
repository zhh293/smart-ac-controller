import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/bluetooth_discovery_service.dart';
import '../../device_pairing/widgets/device_pairing_page.dart';

class BluetoothDiscoveryPage extends StatefulWidget {
  const BluetoothDiscoveryPage({super.key});

  @override
  State<BluetoothDiscoveryPage> createState() => _BluetoothDiscoveryPageState();
}

class _BluetoothDiscoveryPageState extends State<BluetoothDiscoveryPage> {
  final BluetoothDiscoveryService _bluetoothService = BluetoothDiscoveryService();
  final List<BluetoothDevice> _devices = [];
  bool _isScanning = false;
  bool _isBluetoothEnabled = false;
  String? _errorMessage;
  StreamSubscription<ScanEvent>? _eventSubscription;
  Timer? _statusCheckTimer;

  @override
  void initState() {
    super.initState();
    _checkBluetoothStatus();
    _listenToEvents();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _statusCheckTimer?.cancel();
    _bluetoothService.dispose();
    super.dispose();
  }

  Future<void> _checkBluetoothStatus() async {
    final isEnabled = await _bluetoothService.isBluetoothEnabled();
    setState(() {
      _isBluetoothEnabled = isEnabled;
    });
  }

  void _listenToEvents() {
    _eventSubscription = _bluetoothService.eventStream.listen((event) {
      if (!mounted) return;

      setState(() {
        _errorMessage = null;

        switch (event.state) {
          case ScanState.scanning:
            _isScanning = true;
            if (event.device != null) {
              if (!_devices.any((d) => d.deviceId == event.device!.deviceId)) {
                _devices.add(event.device!);
              }
            }
            break;

          case ScanState.stopped:
            _isScanning = false;
            break;

          case ScanState.error:
            _isScanning = false;
            _errorMessage = event.message;
            break;

          case ScanState.idle:
            break;
        }
      });
    });
  }

  Future<void> _startScan() async {
    if (kIsWeb) {
      setState(() {
        _errorMessage = 'Web平台使用模拟数据';
      });
    } else {
      final isAvailable = await _bluetoothService.isBluetoothAvailable();
      if (!isAvailable) {
        setState(() {
          _errorMessage = '蓝牙不可用，请检查设备支持';
        });
        return;
      }

      final isEnabled = await _bluetoothService.isBluetoothEnabled();
      if (!isEnabled) {
        setState(() {
          _errorMessage = '蓝牙未开启，请在设置中开启';
        });
        return;
      }
    }

    setState(() {
      _devices.clear();
      _errorMessage = null;
    });

    await _bluetoothService.startScan();
  }

  Future<void> _stopScan() async {
    await _bluetoothService.stopScan();
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      await _bluetoothService.connectToDevice(device.deviceId);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DevicePairingPage(
              bluetoothDevice: device,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('连接失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '蓝牙设备扫描',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (_isScanning)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '扫描中',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_errorMessage != null && _errorMessage!.contains('Web平台')) {
      return _buildWebNotice();
    }

    if (_errorMessage != null) {
      return _buildErrorView();
    }

    if (_devices.isEmpty && !_isScanning) {
      return _buildEmptyState();
    }

    return _buildDeviceList();
  }

  Widget _buildWebNotice() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
              ),
              child: Icon(
                Icons.bluetooth,
                color: AppColors.accent,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Web平台蓝牙模拟',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '当前运行在Web浏览器中，使用模拟蓝牙设备数据。\n请在移动端应用中使用真实蓝牙扫描功能。',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            _buildScanButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Icon(
                Icons.bluetooth_disabled,
                color: AppColors.error,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '蓝牙错误',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? '未知错误',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            _buildScanButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
              ),
              child: Icon(
                Icons.bluetooth_searching,
                color: AppColors.accent,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '扫描蓝牙设备',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '点击下方按钮开始扫描附近的蓝牙设备',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            _buildScanButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceList() {
    return Column(
      children: [
        if (_devices.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Text(
                  '发现 ${_devices.length} 个设备',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                if (_isScanning)
                  TextButton.icon(
                    onPressed: _stopScan,
                    icon: const Icon(Icons.stop, color: AppColors.error),
                    label: Text(
                      '停止扫描',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: _devices.length,
            itemBuilder: (context, index) {
              final device = _devices[index];
              return _buildDeviceCard(device, index);
            },
          ),
        ),
        if (_isScanning)
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildScanButton(),
          ),
      ],
    );
  }

  Widget _buildDeviceCard(BluetoothDevice device, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getDeviceTypeColor(device.type).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getDeviceTypeIcon(device.type),
            color: _getDeviceTypeColor(device.type),
            size: 28,
          ),
        ),
        title: Text(
          device.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (device.localName != null)
              Text(
                device.localName!,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.signal_cellular_alt,
                  size: 14,
                  color: _getSignalColor(device.rssi),
                ),
                const SizedBox(width: 4),
                Text(
                  _getSignalText(device.rssi),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getSignalColor(device.rssi),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  device.deviceId,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: ElevatedButton.icon(
          onPressed: () => _connectToDevice(device),
          icon: const Icon(Icons.link, size: 18),
          label: const Text('连接'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 100)).slideY();
  }

  Widget _buildScanButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isScanning ? null : _startScan,
        icon: Icon(_isScanning ? Icons.scanner : Icons.bluetooth_searching),
        label: Text(_isScanning ? '扫描中...' : '开始扫描'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          disabledBackgroundColor: AppColors.textTertiary,
        ),
      ),
    );
  }

  IconData _getDeviceTypeIcon(String type) {
    switch (type) {
      case 'air_conditioner':
        return Icons.ac_unit;
      case 'sensor':
        return Icons.sensors;
      case 'thermostat':
        return Icons.thermostat;
      case 'smart_device':
        return Icons.devices;
      default:
        return Icons.bluetooth;
    }
  }

  Color _getDeviceTypeColor(String type) {
    switch (type) {
      case 'air_conditioner':
        return AppColors.accent;
      case 'sensor':
        return AppColors.success;
      case 'thermostat':
        return AppColors.warning;
      case 'smart_device':
        return AppColors.secondaryAccent;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getSignalColor(int? rssi) {
    if (rssi == null) return AppColors.textTertiary;
    if (rssi >= -50) return AppColors.success;
    if (rssi >= -70) return AppColors.warning;
    return AppColors.error;
  }

  String _getSignalText(int? rssi) {
    if (rssi == null) return '未知';
    if (rssi >= -50) return '信号强';
    if (rssi >= -70) return '信号中';
    return '信号弱';
  }
}
