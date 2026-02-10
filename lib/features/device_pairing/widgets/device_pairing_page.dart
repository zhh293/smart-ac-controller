import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/device_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/network_discovery_service.dart';
import '../../../models/ac_device.dart';

class DevicePairingPage extends ConsumerStatefulWidget {
  final DiscoveredDevice discoveredDevice;

  const DevicePairingPage({
    super.key,
    required this.discoveredDevice,
  });

  @override
  ConsumerState<DevicePairingPage> createState() => _DevicePairingPageState();
}

class _DevicePairingPageState extends ConsumerState<DevicePairingPage> {
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedMode = ACMode.cool;
  String _selectedFanSpeed = FanSpeed.auto;
  int _targetTemperature = 24;
  
  bool _isPairing = false;
  bool _isTestingConnection = false;
  bool _connectionTestResult = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = '智能空调 ${widget.discoveredDevice.ipAddress.split('.').last}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('设备配对'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDeviceInfoCard(),
            const SizedBox(height: 24),
            _buildDeviceConfigCard(),
            const SizedBox(height: 24),
            _buildInitialSettingsCard(),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
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
                  Icons.router,
                  color: AppColors.accent,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '发现的设备',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.discoveredDevice.ipAddress,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow('端口', widget.discoveredDevice.port.toString()),
          const SizedBox(height: 12),
          _buildInfoRow('MAC地址', widget.discoveredDevice.macAddress ?? '未知'),
          const SizedBox(height: 12),
          _buildInfoRow('设备名称', widget.discoveredDevice.deviceName ?? '未知'),
          const SizedBox(height: 12),
          _buildInfoRow('制造商', widget.discoveredDevice.manufacturer ?? '未知'),
          if (_connectionTestResult) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '连接测试成功',
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
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

  Widget _buildDeviceConfigCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.divider,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings,
                color: AppColors.accent,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '设备配置',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _nameController,
            label: '设备名称',
            hint: '例如：客厅空调',
            icon: Icons.label,
            required: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _brandController,
            label: '品牌',
            hint: '例如：格力、美的',
            icon: Icons.business,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _modelController,
            label: '型号',
            hint: '例如：KFR-35GW',
            icon: Icons.confirmation_number,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _notesController,
            label: '备注',
            hint: '例如：主卧空调',
            icon: Icons.note,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.accent),
        suffixText: required ? ' *' : null,
        suffixStyle: TextStyle(
          color: AppColors.error,
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: AppColors.background.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.accent, width: 2),
        ),
        labelStyle: TextStyle(color: AppColors.textSecondary),
        hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.6)),
      ),
      style: TextStyle(color: AppColors.textPrimary),
    );
  }

  Widget _buildInitialSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.divider,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tune,
                color: AppColors.accent,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '初始设置',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildModeSelector(),
          const SizedBox(height: 16),
          _buildFanSpeedSelector(),
          const SizedBox(height: 16),
          _buildTemperatureSelector(),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '运行模式',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildModeChip('制冷', ACMode.cool, Icons.ac_unit),
            _buildModeChip('制热', ACMode.heat, Icons.whatshot),
            _buildModeChip('除湿', ACMode.dry, Icons.water_drop),
            _buildModeChip('送风', ACMode.fan, Icons.air),
            _buildModeChip('自动', ACMode.auto, Icons.autorenew),
          ],
        ),
      ],
    );
  }

  Widget _buildModeChip(String label, String mode, IconData icon) {
    final isSelected = _selectedMode == mode;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedMode = mode;
        });
      },
      selectedColor: AppColors.accent.withOpacity(0.3),
      checkmarkColor: AppColors.accent,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.accent : AppColors.textSecondary,
      ),
      avatar: isSelected
          ? Icon(
              icon,
              size: 16,
              color: AppColors.accent,
            )
          : null,
    );
  }

  Widget _buildFanSpeedSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '风速',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildFanSpeedChip('自动', FanSpeed.auto),
            _buildFanSpeedChip('低', FanSpeed.low),
            _buildFanSpeedChip('中', FanSpeed.medium),
            _buildFanSpeedChip('高', FanSpeed.high),
          ],
        ),
      ],
    );
  }

  Widget _buildFanSpeedChip(String label, String speed) {
    final isSelected = _selectedFanSpeed == speed;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFanSpeed = speed;
        });
      },
      selectedColor: AppColors.secondaryAccent.withOpacity(0.3),
      checkmarkColor: AppColors.secondaryAccent,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.secondaryAccent : AppColors.textSecondary,
      ),
    );
  }

  Widget _buildTemperatureSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '目标温度',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: _targetTemperature > 16
                    ? () => setState(() => _targetTemperature--)
                    : null,
                color: AppColors.accent,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_targetTemperature°C',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: _targetTemperature < 30
                    ? () => setState(() => _targetTemperature++)
                    : null,
                color: AppColors.accent,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isTestingConnection ? null : _testConnection,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryAccent.withOpacity(0.2),
              foregroundColor: AppColors.secondaryAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isTestingConnection
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_tethering),
                      SizedBox(width: 8),
                      Text('测试连接'),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isPairing ? null : _pairDevice,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isPairing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.link),
                      SizedBox(width: 8),
                      Text('配对并添加设备'),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTestingConnection = true;
      _connectionTestResult = false;
    });

    try {
      final service = NetworkDiscoveryService();
      final result = await service.testDeviceConnection(
        widget.discoveredDevice.ipAddress,
        port: widget.discoveredDevice.port,
      );

      setState(() {
        _connectionTestResult = result;
      });

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('连接测试成功'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('连接测试失败，设备可能不可达'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('连接测试出错: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isTestingConnection = false;
      });
    }
  }

  Future<void> _pairDevice() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请输入设备名称'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isPairing = true;
    });

    try {
      final device = ACDevice(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        brand: _brandController.text.isEmpty ? '未知' : _brandController.text,
        model: _modelController.text.isEmpty ? '未知' : _modelController.text,
        connectionType: ConnectionType.wifi,
        ipAddress: widget.discoveredDevice.ipAddress,
        macAddress: widget.discoveredDevice.macAddress,
        isOnline: _connectionTestResult,
        isPoweredOn: false,
        temperature: _targetTemperature,
        targetTemperature: _targetTemperature,
        mode: _selectedMode,
        fanSpeed: _selectedFanSpeed,
        powerRating: 1.5,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      await ref.read(deviceNotifierProvider.notifier).addDevice(device);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('设备配对成功'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        await Future.delayed(const Duration(seconds: 1));
        
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('设备配对失败: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPairing = false;
        });
      }
    }
  }
}
