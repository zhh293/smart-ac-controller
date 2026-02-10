import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/device_provider.dart';
import '../../../core/providers/scene_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../models/ac_device.dart';
import '../../../models/scene.dart';
import '../../../models/user_settings.dart';
import 'device_card.dart';
import 'scene_card.dart';
import 'quick_action_button.dart';
import '../../remote/widgets/remote_controller.dart';
import '../../device_discovery/widgets/device_discovery_page.dart';
import '../../device_pairing/widgets/device_pairing_page.dart';
import '../../bluetooth_discovery/widgets/bluetooth_discovery_page.dart';
import '../../../services/network_discovery_service.dart';
import '../../../services/bluetooth_discovery_service.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: IndexedStack(
            index: _currentIndex,
            children: [
              _buildDevicesPage(context),
              _buildScenesPage(context),
              _buildStatisticsPage(context),
              _buildSettingsPage(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _currentIndex == 0
          ? _buildAddDeviceButton(context)
          : null,
    );
  }

  Widget _buildDevicesPage(BuildContext context) {
    final devicesAsync = ref.watch(devicesProvider);
    final settingsAsync = ref.watch(settingsProvider);

    return Column(
      children: [
        _buildHeader(context, '我的设备'),
        Expanded(
          child: devicesAsync.when(
            data: (devices) {
              if (devices.isEmpty) {
                return _buildEmptyState(context);
              }
              return _buildDeviceList(context, devices, settingsAsync);
            },
            loading: () => const _LoadingIndicator(),
            error: (error, stack) => _ErrorView(error: error),
          ),
        ),
      ],
    );
  }

  Widget _buildScenesPage(BuildContext context) {
    final scenesAsync = ref.watch(scenesProvider);

    return Column(
      children: [
        _buildHeader(context, '智能场景'),
        Expanded(
          child: scenesAsync.when(
            data: (scenes) {
              if (scenes.isEmpty) {
                return _buildEmptyScenesState(context);
              }
              return _buildScenesList(context, scenes);
            },
            loading: () => const _LoadingIndicator(),
            error: (error, stack) => _ErrorView(error: error),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsPage(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context, '数据统计'),
        Expanded(child: _buildStatisticsContent(context)),
      ],
    );
  }

  Widget _buildSettingsPage(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context, '设置'),
        Expanded(child: _buildSettingsContent(context)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.displaySmall),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: () {
              _refreshController.forward(from: 0);
              ref.read(deviceNotifierProvider.notifier).refresh();
              ref.read(sceneNotifierProvider.notifier).refresh();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList(
    BuildContext context,
    List<ACDevice> devices,
    AsyncValue<UserSettings> settingsAsync,
  ) {
    return settingsAsync.when(
      data: (settings) {
        final quickActions = settings.quickActions;

        return RefreshIndicator(
          onRefresh: () async {
            await ref.read(deviceNotifierProvider.notifier).refresh();
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              if (quickActions.isNotEmpty) ...[
                _buildQuickActions(context, quickActions),
                const SizedBox(height: 24),
              ],
              ...devices.map((device) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DeviceCard(
                    device: device,
                    onTap: () => _navigateToRemote(device.id),
                    onLongPress: () => _showDeviceOptions(context, device),
                  ),
                );
              }),
            ],
          ),
        );
      },
      loading: () => const _LoadingIndicator(),
      error: (error, stack) => _ErrorView(error: error),
    );
  }

  Widget _buildQuickActions(BuildContext context, List<QuickAction> actions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('快捷操作', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: actions.map((action) {
            return QuickActionButton(
              action: action,
              onTap: () => _executeQuickAction(action),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildScenesList(BuildContext context, List<Scene> scenes) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(sceneNotifierProvider.notifier).refresh();
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: scenes.length,
        itemBuilder: (context, index) {
          final scene = scenes[index];
          return SceneCard(scene: scene, onTap: () => _triggerScene(scene.id));
        },
      ),
    );
  }

  Widget _buildStatisticsContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, color: AppColors.textTertiary, size: 64),
          const SizedBox(height: 16),
          Text('数据统计功能开发中', style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSettingsSection(context, '通用设置', [
          _buildSettingsTile(
            context,
            Icons.dark_mode,
            '深色模式',
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeColor: AppColors.accent,
            ),
          ),
          _buildSettingsTile(
            context,
            Icons.volume_up,
            '音效',
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeColor: AppColors.accent,
            ),
          ),
          _buildSettingsTile(
            context,
            Icons.vibration,
            '震动反馈',
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeColor: AppColors.accent,
            ),
          ),
        ]),
        const SizedBox(height: 24),
        _buildSettingsSection(context, '连接设置', [
          _buildSettingsTile(
            context,
            Icons.cloud,
            '天气API',
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
            ),
            onTap: () => _showWeatherApiDialog(context),
          ),
          _buildSettingsTile(
            context,
            Icons.router,
            'MQTT配置',
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
            ),
            onTap: () => _showMqttConfigDialog(context),
          ),
        ]),
        const SizedBox(height: 24),
        _buildSettingsSection(context, '关于', [
          _buildSettingsTile(
            context,
            Icons.info_outline,
            '版本',
            trailing: Text(
              AppConstants.appVersion,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ]),
      ],
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: children
                .map(
                  (child) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: child,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    IconData icon,
    String title, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.devices_other, color: AppColors.textTertiary, size: 80),
          const SizedBox(height: 24),
          Text('还没有添加设备', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('点击右下角按钮添加设备', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildEmptyScenesState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, color: AppColors.textTertiary, size: 80),
          const SizedBox(height: 24),
          Text('还没有创建场景', style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, '设备', 0),
              _buildNavItem(Icons.auto_awesome, '场景', 1),
              _buildNavItem(Icons.bar_chart, '统计', 2),
              _buildNavItem(Icons.settings, '设置', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.accent : AppColors.textTertiary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? AppColors.accent : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddDeviceButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 80, right: 16),
      child: FloatingActionButton.extended(
        onPressed: () => _showAddDeviceDialog(context),
        backgroundColor: AppColors.accent,
        foregroundColor: AppTheme.primaryColor,
        elevation: 8,
        icon: const Icon(Icons.add),
        label: const Text('添加设备'),
      ),
    );
  }

  void _navigateToRemote(String deviceId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RemoteController(deviceId: deviceId),
      ),
    );
  }

  void _showDeviceOptions(BuildContext context, ACDevice device) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            _buildOptionTile(context, Icons.edit, '编辑设备', () {}),
            _buildOptionTile(context, Icons.share, '分享设备', () {}),
            _buildOptionTile(context, Icons.bar_chart, '查看统计', () {}),
            _buildOptionTile(context, Icons.delete_outline, '删除设备', () {
              ref.read(deviceNotifierProvider.notifier).deleteDevice(device.id);
              Navigator.pop(context);
            }, isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
    );
  }

  void _triggerScene(String sceneId) {
    ref.read(sceneNotifierProvider.notifier).triggerScene(sceneId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('场景已触发'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _executeQuickAction(QuickAction action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('执行: ${action.name}'),
        backgroundColor: AppColors.accent,
      ),
    );
  }

  void _showAddDeviceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AddDeviceDialog(),
    );
  }

  void _showWeatherApiDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => _WeatherApiDialog());
  }

  void _showMqttConfigDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => _MqttConfigDialog());
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Object error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 64),
          const SizedBox(height: 16),
          Text('加载失败', style: Theme.of(context).textTheme.headlineMedium),
        ],
      ),
    );
  }
}

class _AddDeviceDialog extends ConsumerStatefulWidget {
  _AddDeviceDialog({super.key});

  @override
  ConsumerState<_AddDeviceDialog> createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends ConsumerState<_AddDeviceDialog> {
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  String _connectionType = ConnectionType.wifi;

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('添加设备', style: Theme.of(context).textTheme.headlineMedium),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '设备名称',
                      hintText: '例如：客厅空调',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _brandController,
                    decoration: const InputDecoration(
                      labelText: '品牌',
                      hintText: '例如：格力',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _modelController,
                    decoration: const InputDecoration(
                      labelText: '型号',
                      hintText: '例如：KFR-35GW',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('连接方式', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children: [
                      _buildConnectionTypeChip('WiFi', ConnectionType.wifi),
                      _buildConnectionTypeChip('蓝牙', ConnectionType.bluetooth),
                      _buildConnectionTypeChip('局域网', ConnectionType.lan),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_connectionType == ConnectionType.wifi) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _scanForDevices,
                        icon: const Icon(Icons.wifi),
                        label: const Text('扫描WiFi设备'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accent,
                          side: BorderSide(color: AppColors.accent),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '提示：点击扫描可自动发现局域网内的智能空调设备',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ] else if (_connectionType == ConnectionType.bluetooth) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _scanBluetoothDevices,
                        icon: const Icon(Icons.bluetooth),
                        label: const Text('扫描蓝牙设备'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accent,
                          side: BorderSide(color: AppColors.accent),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '提示：点击扫描可自动发现附近的蓝牙智能空调设备',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addDevice,
              child: const Text('添加'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionTypeChip(String label, String type) {
    final isSelected = _connectionType == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _connectionType = type;
        });
      },
      selectedColor: AppColors.accent.withOpacity(0.3),
      checkmarkColor: AppColors.accent,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.accent : AppColors.textSecondary,
      ),
    );
  }

  Future<void> _scanForDevices() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DeviceDiscoveryPage()),
    );

    if (result != null && result is DiscoveredDevice) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DevicePairingPage(discoveredDevice: result),
        ),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _scanBluetoothDevices() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BluetoothDiscoveryPage()),
    );

    if (result != null && result is BluetoothDevice) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DevicePairingPage(bluetoothDevice: result),
        ),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _addDevice() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入设备名称'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final device = ACDevice(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      brand: _brandController.text.isEmpty ? '未知' : _brandController.text,
      model: _modelController.text.isEmpty ? '未知' : _modelController.text,
      connectionType: _connectionType,
      powerRating: 1.5,
    );

    ref.read(deviceNotifierProvider.notifier).addDevice(device);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('设备添加成功'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

class _WeatherApiDialog extends ConsumerStatefulWidget {
  _WeatherApiDialog({super.key});

  @override
  ConsumerState<_WeatherApiDialog> createState() => _WeatherApiDialogState();
}

class _WeatherApiDialogState extends ConsumerState<_WeatherApiDialog> {
  final _apiKeyController = TextEditingController();

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: Text('天气API配置', style: Theme.of(context).textTheme.titleLarge),
      content: TextField(
        controller: _apiKeyController,
        decoration: const InputDecoration(
          labelText: 'API Key',
          hintText: '请输入天气API密钥',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            ref
                .read(settingsServiceProvider)
                .setWeatherApiKey(_apiKeyController.text);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('API Key已保存'),
                backgroundColor: AppColors.success,
              ),
            );
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}

class _MqttConfigDialog extends ConsumerStatefulWidget {
  _MqttConfigDialog({super.key});

  @override
  ConsumerState<_MqttConfigDialog> createState() => _MqttConfigDialogState();
}

class _MqttConfigDialogState extends ConsumerState<_MqttConfigDialog> {
  final _brokerUrlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _clientIdController = TextEditingController();

  @override
  void dispose() {
    _brokerUrlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _clientIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: Text('MQTT配置', style: Theme.of(context).textTheme.titleLarge),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _brokerUrlController,
              decoration: const InputDecoration(
                labelText: 'Broker URL',
                hintText: '例如：mqtt://broker.example.com',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: '用户名'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '密码'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _clientIdController,
              decoration: const InputDecoration(labelText: 'Client ID'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            final service = ref.read(settingsServiceProvider);
            service.setMqttBrokerUrl(_brokerUrlController.text);
            service.setMqttUsername(_usernameController.text);
            service.setMqttPassword(_passwordController.text);
            service.setMqttClientId(_clientIdController.text);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('MQTT配置已保存'),
                backgroundColor: AppColors.success,
              ),
            );
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
