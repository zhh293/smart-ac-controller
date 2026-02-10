import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/network_discovery_service.dart';

final networkDiscoveryServiceProvider = Provider<NetworkDiscoveryService>((
  ref,
) {
  final service = NetworkDiscoveryService();
  ref.onDispose(() => service.dispose());
  return service;
});

final discoveredDevicesProvider =
    StateNotifierProvider<DiscoveredDevicesNotifier, List<DiscoveredDevice>>((
      ref,
    ) {
      final service = ref.watch(networkDiscoveryServiceProvider);
      return DiscoveredDevicesNotifier(service);
    });

class DiscoveredDevicesNotifier extends StateNotifier<List<DiscoveredDevice>> {
  final NetworkDiscoveryService _service;
  StreamSubscription? _subscription;

  DiscoveredDevicesNotifier(this._service) : super([]) {
    _subscription = _service.eventStream.listen((event) {
      _handleDiscoveryEvent(event);
    });
  }

  void _handleDiscoveryEvent(DiscoveryEvent event) {
    switch (event.type) {
      case DiscoveryEventType.deviceFound:
        if (event.device != null &&
            !state.any((d) => d.ipAddress == event.device!.ipAddress)) {
          state = [...state, event.device!];
        }
        break;
      case DiscoveryEventType.deviceVerified:
        if (event.device != null) {
          final index = state.indexWhere(
            (d) => d.ipAddress == event.device!.ipAddress,
          );
          if (index != -1) {
            final updatedList = List<DiscoveredDevice>.from(state);
            updatedList[index] = event.device!;
            state = updatedList;
          }
        }
        break;
      case DiscoveryEventType.completed:
        if (event.devices != null) {
          state = event.devices!;
        }
        break;
      case DiscoveryEventType.cleared:
        state = [];
        break;
      default:
        break;
    }
  }

  Future<void> startScan() async {
    await _service.startScan();
  }

  Future<void> stopScan() {
    _service.stopScan();
    return Future.value();
  }

  Future<void> verifyAllDevices() async {
    await _service.verifyAllDevices();
  }

  void clearDevices() {
    _service.clearDevices();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

class DeviceDiscoveryPage extends ConsumerStatefulWidget {
  const DeviceDiscoveryPage({super.key});

  @override
  ConsumerState<DeviceDiscoveryPage> createState() =>
      _DeviceDiscoveryPageState();
}

class _DeviceDiscoveryPageState extends ConsumerState<DeviceDiscoveryPage> {
  String? _localIp;
  String? _wifiSSID;
  String _scanStatus = '准备就绪';
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _initializeNetworkInfo();
  }

  Future<void> _initializeNetworkInfo() async {
    final service = ref.read(networkDiscoveryServiceProvider);
    _localIp = await service.getLocalIpAddress();
    _wifiSSID = await service.getWifiSSID();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(networkDiscoveryServiceProvider);
    final devices = ref.watch(discoveredDevicesProvider);
    final isScanning = service.isScanning;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('发现设备'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildNetworkInfoCard(),
          const SizedBox(height: 16),
          _buildScanControlCard(isScanning, devices.length),
          const SizedBox(height: 16),
          Expanded(child: _buildDevicesList(devices, isScanning)),
        ],
      ),
    );
  }

  Widget _buildNetworkInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.wifi, color: AppColors.accent, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '网络信息',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (_wifiSSID != null)
                      Text(
                        _wifiSSID!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoItem('本地IP', _localIp ?? '未知'),
              const SizedBox(width: 16),
              _buildInfoItem('状态', _localIp != null ? '已连接' : '未连接'),
            ],
          ),
          if (_wifiSSID?.contains('模拟') == true) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.warning, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '当前运行在Web平台，使用模拟数据。请在移动端或桌面端应用中使用真实网络扫描功能。',
                      style: TextStyle(fontSize: 12, color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanControlCard(bool isScanning, int deviceCount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '扫描状态',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _scanStatus,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isScanning
                          ? AppColors.accent
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (isScanning)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: isScanning ? Icons.stop : Icons.search,
                  label: isScanning ? '停止扫描' : '开始扫描',
                  color: isScanning ? AppColors.error : AppColors.accent,
                  onPressed: isScanning ? _stopScan : _startScan,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.refresh,
                  label: '验证连接',
                  color: AppColors.secondaryAccent,
                  onPressed: deviceCount > 0 && !isScanning
                      ? _verifyDevices
                      : null,
                ),
              ),
            ],
          ),
          if (deviceCount > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.devices, color: AppColors.success, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '发现 $deviceCount 个设备',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(icon, size: 20), const SizedBox(width: 8), Text(label)],
      ),
    );
  }

  Widget _buildDevicesList(List<DiscoveredDevice> devices, bool isScanning) {
    if (devices.isEmpty && !isScanning) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '未发现设备',
              style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              '点击"开始扫描"搜索局域网内的设备',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (!isScanning) {
          await _startScan();
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          return _buildDeviceCard(device, index);
        },
      ),
    );
  }

  Widget _buildDeviceCard(DiscoveredDevice device, int index) {
    return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: device.isReachable ? AppTheme.cardGradient : null,
            color: device.isReachable ? null : AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: device.isReachable
                  ? AppColors.success.withOpacity(0.5)
                  : AppColors.divider,
              width: device.isReachable ? 2 : 1,
            ),
          ),
          child: InkWell(
            onTap: () => _showDeviceDetails(device),
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: device.isReachable
                        ? AppColors.success.withOpacity(0.2)
                        : AppColors.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    device.isReachable ? Icons.check_circle : Icons.devices,
                    color: device.isReachable
                        ? AppColors.success
                        : AppColors.accent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.ipAddress,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.router,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '端口: ${device.port}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.schedule,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDiscoveryTime(device.discoveredAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => _showDeviceDetails(device),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (index * 50).ms)
        .slideX(begin: -0.2, delay: (index * 50).ms);
  }

  String _formatDiscoveryTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}秒前';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '${difference.inHours}小时前';
    }
  }

  Future<void> _startScan() async {
    setState(() {
      _scanStatus = '正在扫描...';
    });

    await ref.read(discoveredDevicesProvider.notifier).startScan();

    setState(() {
      _scanStatus = '扫描完成';
    });
  }

  Future<void> _stopScan() async {
    await ref.read(discoveredDevicesProvider.notifier).stopScan();

    setState(() {
      _scanStatus = '已停止';
    });
  }

  Future<void> _verifyDevices() async {
    setState(() {
      _isVerifying = true;
      _scanStatus = '正在验证...';
    });

    await ref.read(discoveredDevicesProvider.notifier).verifyAllDevices();

    setState(() {
      _isVerifying = false;
      _scanStatus = '验证完成';
    });
  }

  void _showDeviceDetails(DiscoveredDevice device) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _DeviceDetailsSheet(device: device),
    );
  }
}

class _DeviceDetailsSheet extends StatelessWidget {
  final DiscoveredDevice device;

  const _DeviceDetailsSheet({required this.device});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: AppColors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '设备详情',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDetailRow('IP地址', device.ipAddress),
          const SizedBox(height: 12),
          _buildDetailRow('端口', device.port.toString()),
          const SizedBox(height: 12),
          _buildDetailRow('MAC地址', device.macAddress ?? '未知'),
          const SizedBox(height: 12),
          _buildDetailRow('设备名称', device.deviceName ?? '未知'),
          const SizedBox(height: 12),
          _buildDetailRow('制造商', device.manufacturer ?? '未知'),
          const SizedBox(height: 12),
          _buildDetailRow('连接状态', device.isReachable ? '可连接' : '未知'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, device);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '选择此设备',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
