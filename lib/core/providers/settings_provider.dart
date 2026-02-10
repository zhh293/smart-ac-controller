import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_settings.dart';
import '../../services/settings_service.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

final settingsProvider = FutureProvider<UserSettings>((ref) async {
  final service = ref.watch(settingsServiceProvider);
  return await service.getSettings();
});

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, AsyncValue<UserSettings>>((ref) {
      final service = ref.watch(settingsServiceProvider);
      return SettingsNotifier(service);
    });

class SettingsNotifier extends StateNotifier<AsyncValue<UserSettings>> {
  final SettingsService _service;

  SettingsNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    state = const AsyncValue.loading();
    try {
      final settings = await _service.getSettings();
      state = AsyncValue.data(settings);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> updateThemeMode(String themeMode) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    final updated = UserSettings(
      themeMode: themeMode,
      soundEnabled: currentSettings.soundEnabled,
      vibrationEnabled: currentSettings.vibrationEnabled,
      language: currentSettings.language,
      quickActions: currentSettings.quickActions,
      weatherEnabled: currentSettings.weatherEnabled,
      weatherLocation: currentSettings.weatherLocation,
      weatherAutoMode: currentSettings.weatherAutoMode,
      voiceControlEnabled: currentSettings.voiceControlEnabled,
      notificationsEnabled: currentSettings.notificationsEnabled,
      maintenanceReminderEnabled: currentSettings.maintenanceReminderEnabled,
      maintenanceReminderDays: currentSettings.maintenanceReminderDays,
      appPasswordEnabled: currentSettings.appPasswordEnabled,
      appPassword: currentSettings.appPassword,
    );

    await _service.saveSettings(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> updateSoundEnabled(bool enabled) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    final updated = UserSettings(
      themeMode: currentSettings.themeMode,
      soundEnabled: enabled,
      vibrationEnabled: currentSettings.vibrationEnabled,
      language: currentSettings.language,
      quickActions: currentSettings.quickActions,
      weatherEnabled: currentSettings.weatherEnabled,
      weatherLocation: currentSettings.weatherLocation,
      weatherAutoMode: currentSettings.weatherAutoMode,
      voiceControlEnabled: currentSettings.voiceControlEnabled,
      notificationsEnabled: currentSettings.notificationsEnabled,
      maintenanceReminderEnabled: currentSettings.maintenanceReminderEnabled,
      maintenanceReminderDays: currentSettings.maintenanceReminderDays,
      appPasswordEnabled: currentSettings.appPasswordEnabled,
      appPassword: currentSettings.appPassword,
    );

    await _service.saveSettings(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> updateQuickActions(List<QuickAction> actions) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    final updated = UserSettings(
      themeMode: currentSettings.themeMode,
      soundEnabled: currentSettings.soundEnabled,
      vibrationEnabled: currentSettings.vibrationEnabled,
      language: currentSettings.language,
      quickActions: actions,
      weatherEnabled: currentSettings.weatherEnabled,
      weatherLocation: currentSettings.weatherLocation,
      weatherAutoMode: currentSettings.weatherAutoMode,
      voiceControlEnabled: currentSettings.voiceControlEnabled,
      notificationsEnabled: currentSettings.notificationsEnabled,
      maintenanceReminderEnabled: currentSettings.maintenanceReminderEnabled,
      maintenanceReminderDays: currentSettings.maintenanceReminderDays,
      appPasswordEnabled: currentSettings.appPasswordEnabled,
      appPassword: currentSettings.appPassword,
    );

    await _service.saveSettings(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> refresh() async {
    await _loadSettings();
  }
}
