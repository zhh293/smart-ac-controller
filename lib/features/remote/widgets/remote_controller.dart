import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/ac_device.dart';
import '../../../core/providers/device_provider.dart';

class RemoteController extends ConsumerStatefulWidget {
  final String deviceId;

  const RemoteController({super.key, required this.deviceId});

  @override
  ConsumerState<RemoteController> createState() => _RemoteControllerState();
}

class _RemoteControllerState extends ConsumerState<RemoteController>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceAsync = ref.watch(deviceByIdProvider(widget.deviceId));

    return deviceAsync.when(
      data: (device) {
        if (device == null) {
          return const _DeviceNotFound();
        }
        return _RemotePanel(device: device);
      },
      loading: () => const _LoadingIndicator(),
      error: (error, stack) => _ErrorView(error: error),
    );
  }
}

class _RemotePanel extends ConsumerWidget {
  final ACDevice device;

  const _RemotePanel({required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildPowerButton(context, ref, device),
                        const SizedBox(height: 32),
                        _buildTemperatureDisplay(context, ref, device),
                        const SizedBox(height: 40),
                        _buildModeSelector(context, ref, device),
                        const SizedBox(height: 32),
                        _buildFanSpeedControl(context, ref, device),
                        const SizedBox(height: 32),
                        _buildSwingControl(context, ref, device),
                        const SizedBox(height: 32),
                        _buildTimerControl(context, ref, device),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimary,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  device.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: device.isOnline
                            ? AppColors.success
                            : AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      device.isOnline ? '在线' : '离线',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            onPressed: () => _showDeviceOptions(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerButton(
    BuildContext context,
    WidgetRef ref,
    ACDevice device,
  ) {
    return Center(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          ref.read(deviceNotifierProvider.notifier).togglePower(device.id);
        },
        child:
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: device.isPoweredOn
                    ? AppTheme.accentGradient
                    : LinearGradient(
                        colors: [
                          AppColors.card,
                          AppColors.card.withOpacity(0.5),
                        ],
                      ),
                boxShadow: device.isPoweredOn
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Icon(
                  device.isPoweredOn ? Icons.power : Icons.power_off,
                  size: 50,
                  color: device.isPoweredOn
                      ? AppTheme.primaryColor
                      : AppColors.textTertiary,
                ),
              ),
            ).animate().scale(
              duration: AppConstants.animationDuration,
              curve: Curves.elasticOut,
            ),
      ),
    );
  }

  Widget _buildTemperatureDisplay(
    BuildContext context,
    WidgetRef ref,
    ACDevice device,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: AppTheme.glassDecoration,
      child: Column(
        children: [
          Text('当前温度', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTempButton(context, ref, device, Icons.remove, () {
                if (device.temperature > AppConstants.minTemperature) {
                  HapticFeedback.lightImpact();
                  ref
                      .read(deviceNotifierProvider.notifier)
                      .setTemperature(device.id, device.temperature - 1);
                }
              }),
              const SizedBox(width: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accent, width: 2),
                ),
                child: Text(
                  '${device.temperature}°C',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.accent,
                    fontSize: 48,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              _buildTempButton(context, ref, device, Icons.add, () {
                if (device.temperature < AppConstants.maxTemperature) {
                  HapticFeedback.lightImpact();
                  ref
                      .read(deviceNotifierProvider.notifier)
                      .setTemperature(device.id, device.temperature + 1);
                }
              }),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '目标: ${device.targetTemperature}°C',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildTempButton(
    BuildContext context,
    WidgetRef ref,
    ACDevice device,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider, width: 1),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 28),
      ),
    );
  }

  Widget _buildModeSelector(
    BuildContext context,
    WidgetRef ref,
    ACDevice device,
  ) {
    final modes = [
      {
        'id': ACMode.cool,
        'icon': Icons.ac_unit,
        'label': '制冷',
        'color': AppColors.modeCool,
      },
      {
        'id': ACMode.heat,
        'icon': Icons.whatshot,
        'label': '制热',
        'color': AppColors.modeHeat,
      },
      {
        'id': ACMode.fan,
        'icon': Icons.air,
        'label': '送风',
        'color': AppColors.modeFan,
      },
      {
        'id': ACMode.dry,
        'icon': Icons.water_drop,
        'label': '除湿',
        'color': AppColors.modeDry,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('运行模式', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: modes.map((mode) {
            final isSelected = device.mode == mode['id'];
            return _ModeButton(
              icon: mode['icon'] as IconData,
              label: mode['label'] as String,
              color: mode['color'] as Color,
              isSelected: isSelected,
              onTap: () {
                HapticFeedback.lightImpact();
                ref
                    .read(deviceNotifierProvider.notifier)
                    .setMode(device.id, mode['id'] as String);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFanSpeedControl(
    BuildContext context,
    WidgetRef ref,
    ACDevice device,
  ) {
    final speeds = [
      {'id': FanSpeed.low, 'label': '低风', 'bars': 1},
      {'id': FanSpeed.medium, 'label': '中风', 'bars': 2},
      {'id': FanSpeed.high, 'label': '高风', 'bars': 3},
      {'id': FanSpeed.auto, 'label': '自动', 'bars': 4},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('风速调节', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: speeds.map((speed) {
            final isSelected = device.fanSpeed == speed['id'];
            return _FanSpeedButton(
              label: speed['label'] as String,
              bars: speed['bars'] as int,
              isSelected: isSelected,
              onTap: () {
                HapticFeedback.lightImpact();
                ref
                    .read(deviceNotifierProvider.notifier)
                    .setFanSpeed(device.id, speed['id'] as String);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSwingControl(
    BuildContext context,
    WidgetRef ref,
    ACDevice device,
  ) {
    final directions = [
      {'id': SwingDirection.up, 'icon': Icons.arrow_upward, 'label': '向上'},
      {'id': SwingDirection.down, 'icon': Icons.arrow_downward, 'label': '向下'},
      {'id': SwingDirection.left, 'icon': Icons.arrow_back, 'label': '向左'},
      {'id': SwingDirection.right, 'icon': Icons.arrow_forward, 'label': '向右'},
      {'id': SwingDirection.fixed, 'icon': Icons.crop_square, 'label': '固定'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('风向控制', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: directions.map((dir) {
            final isSelected = device.swingDirection == dir['id'];
            return _SwingButton(
              icon: dir['icon'] as IconData,
              label: dir['label'] as String,
              isSelected: isSelected,
              onTap: () {
                HapticFeedback.lightImpact();
                ref
                    .read(deviceNotifierProvider.notifier)
                    .setSwingDirection(device.id, dir['id'] as String);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimerControl(
    BuildContext context,
    WidgetRef ref,
    ACDevice device,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('定时设置', style: Theme.of(context).textTheme.titleLarge),
              if (device.timerMinutes != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${device.timerMinutes}分钟',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.accent),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _TimerButton(
                label: '1小时',
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref
                      .read(deviceNotifierProvider.notifier)
                      .setTimer(device.id, 60, 'off');
                },
              ),
              _TimerButton(
                label: '2小时',
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref
                      .read(deviceNotifierProvider.notifier)
                      .setTimer(device.id, 120, 'off');
                },
              ),
              _TimerButton(
                label: '4小时',
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref
                      .read(deviceNotifierProvider.notifier)
                      .setTimer(device.id, 240, 'off');
                },
              ),
              _TimerButton(
                label: '取消',
                isDestructive: true,
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref
                      .read(deviceNotifierProvider.notifier)
                      .setTimer(device.id, null, null);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeviceOptions(BuildContext context) {
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
            _buildOptionTile(
              context,
              Icons.delete_outline,
              '删除设备',
              () {},
              isDestructive: true,
            ),
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
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FanSpeedButton extends StatelessWidget {
  final String label;
  final int bars;
  final bool isSelected;
  final VoidCallback onTap;

  const _FanSpeedButton({
    required this.label,
    required this.bars,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withOpacity(0.2)
              : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(4, (index) {
                return Container(
                  width: 4,
                  height: 8 + (index * 4),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isSelected && index < bars
                        ? AppColors.accent
                        : AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwingButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SwingButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withOpacity(0.2)
              : AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.accent : AppColors.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerButton extends StatelessWidget {
  final String label;
  final bool isDestructive;
  final VoidCallback onTap;

  const _TimerButton({
    required this.label,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDestructive
            ? AppColors.error.withOpacity(0.2)
            : AppColors.card,
        foregroundColor: isDestructive
            ? AppColors.error
            : AppColors.textPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDestructive ? AppColors.error : AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Text(label),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Object error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 64),
            const SizedBox(height: 16),
            Text('加载失败', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceNotFound extends StatelessWidget {
  const _DeviceNotFound();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.devices_other, color: AppColors.textTertiary, size: 64),
            const SizedBox(height: 16),
            Text('设备未找到', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}
