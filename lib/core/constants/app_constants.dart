class AppConstants {
  static const String appName = 'Smart AC Controller';
  static const String appVersion = '1.0.0';

  static const int minTemperature = 16;
  static const int maxTemperature = 30;
  static const int defaultTemperature = 24;

  static const int minTimerMinutes = 10;
  static const int maxTimerHours = 24;

  static const int maxDevices = 20;
  static const int maxGroups = 10;
  static const int maxDevicesPerGroup = 20;
  static const int maxScenes = 20;
  static const int maxQuickActions = 8;

  static const int operationTimeout = 500;
  static const int syncTimeout = 1000;
  static const int storageTimeout = 300;

  static const int weatherUpdateInterval = 30;

  static const double cardBorderRadius = 20.0;
  static const double buttonBorderRadius = 16.0;
  static const double inputBorderRadius = 16.0;

  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);

  static const String hiveBoxName = 'smart_ac_box';
  static const String devicesBoxName = 'devices_box';
  static const String scenesBoxName = 'scenes_box';
  static const String statisticsBoxName = 'statistics_box';
  static const String settingsBoxName = 'settings_box';

  static const String keyThemeMode = 'theme_mode';
  static const String keyFirstLaunch = 'first_launch';
  static const String keySoundEnabled = 'sound_enabled';
  static const String keyVibrationEnabled = 'vibration_enabled';
  static const String keyWeatherApiKey = 'weather_api_key';
  static const String keyMqttBrokerUrl = 'mqtt_broker_url';
  static const String keyMqttUsername = 'mqtt_username';
  static const String keyMqttPassword = 'mqtt_password';
  static const String keyMqttClientId = 'mqtt_client_id';
}

class ACMode {
  static const String cool = 'cool';
  static const String heat = 'heat';
  static const String fan = 'fan';
  static const String dry = 'dry';
  static const String auto = 'auto';
}

class FanSpeed {
  static const String low = 'low';
  static const String medium = 'medium';
  static const String high = 'high';
  static const String auto = 'auto';
}

class SwingDirection {
  static const String up = 'up';
  static const String down = 'down';
  static const String left = 'left';
  static const String right = 'right';
  static const String fixed = 'fixed';
}

class ConnectionType {
  static const String wifi = 'wifi';
  static const String bluetooth = 'bluetooth';
  static const String lan = 'lan';
}

class UserRole {
  static const String admin = 'admin';
  static const String user = 'user';
}

class NotificationType {
  static const String statusChange = 'status_change';
  static const String timerTriggered = 'timer_triggered';
  static const String faultWarning = 'fault_warning';
  static const String maintenanceReminder = 'maintenance_reminder';
}
