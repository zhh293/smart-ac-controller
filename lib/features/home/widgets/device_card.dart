import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/ac_device.dart';
import '../../../core/constants/app_constants.dart';

class DeviceCard extends StatelessWidget {
  final ACDevice device;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const DeviceCard({
    super.key,
    required this.device,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child:
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: device.isPoweredOn
                    ? AppColors.accent.withOpacity(0.3)
                    : AppColors.divider,
                width: device.isPoweredOn ? 2 : 1,
              ),
              boxShadow: device.isPoweredOn
                  ? [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getModeColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getModeIcon(),
                        color: _getModeColor(),
                        size: 24,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: device.isOnline
                            ? AppColors.success.withOpacity(0.2)
                            : AppColors.error.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: device.isOnline
                                  ? AppColors.success
                                  : AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            device.isOnline ? '在线' : '离线',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: device.isOnline
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  device.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '${device.brand} ${device.model}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.thermostat,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${device.temperature}°C',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.air, color: AppColors.textSecondary, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      device.fanSpeedDisplayName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn().slideY(
            begin: 0.1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          ),
    );
  }

  Color _getModeColor() {
    switch (device.mode) {
      case ACMode.cool:
        return AppColors.modeCool;
      case ACMode.heat:
        return AppColors.modeHeat;
      case ACMode.fan:
        return AppColors.modeFan;
      case ACMode.dry:
        return AppColors.modeDry;
      default:
        return AppColors.accent;
    }
  }

  IconData _getModeIcon() {
    switch (device.mode) {
      case ACMode.cool:
        return Icons.ac_unit;
      case ACMode.heat:
        return Icons.whatshot;
      case ACMode.fan:
        return Icons.air;
      case ACMode.dry:
        return Icons.water_drop;
      default:
        return Icons.auto_awesome;
    }
  }
}
