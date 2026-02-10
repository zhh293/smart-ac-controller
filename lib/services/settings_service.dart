import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_settings.dart';
import '../../core/constants/app_constants.dart';

class SettingsService {
  late Box<UserSettings> _settingsBox;
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();

    if (!Hive.isBoxOpen(AppConstants.settingsBoxName)) {
      _settingsBox = await Hive.openBox(AppConstants.settingsBoxName);
    } else {
      _settingsBox = Hive.box(AppConstants.settingsBoxName);
    }
  }

  Future<UserSettings> getSettings() async {
    await init();

    final settings = _settingsBox.get('user_settings');
    if (settings != null) {
      return settings;
    }

    final defaultSettings = UserSettings();
    await _settingsBox.put('user_settings', defaultSettings);
    return defaultSettings;
  }

  Future<void> saveSettings(UserSettings settings) async {
    await init();
    await _settingsBox.put('user_settings', settings);
  }

  Future<bool> isFirstLaunch() async {
    await init();
    return _prefs?.getBool(AppConstants.keyFirstLaunch) ?? true;
  }

  Future<void> setFirstLaunch(bool isFirst) async {
    await init();
    await _prefs?.setBool(AppConstants.keyFirstLaunch, isFirst);
  }

  Future<String?> getWeatherApiKey() async {
    await init();
    return _prefs?.getString(AppConstants.keyWeatherApiKey);
  }

  Future<void> setWeatherApiKey(String apiKey) async {
    await init();
    await _prefs?.setString(AppConstants.keyWeatherApiKey, apiKey);
  }

  Future<String?> getMqttBrokerUrl() async {
    await init();
    return _prefs?.getString(AppConstants.keyMqttBrokerUrl);
  }

  Future<void> setMqttBrokerUrl(String url) async {
    await init();
    await _prefs?.setString(AppConstants.keyMqttBrokerUrl, url);
  }

  Future<String?> getMqttUsername() async {
    await init();
    return _prefs?.getString(AppConstants.keyMqttUsername);
  }

  Future<void> setMqttUsername(String username) async {
    await init();
    await _prefs?.setString(AppConstants.keyMqttUsername, username);
  }

  Future<String?> getMqttPassword() async {
    await init();
    return _prefs?.getString(AppConstants.keyMqttPassword);
  }

  Future<void> setMqttPassword(String password) async {
    await init();
    await _prefs?.setString(AppConstants.keyMqttPassword, password);
  }

  Future<String?> getMqttClientId() async {
    await init();
    return _prefs?.getString(AppConstants.keyMqttClientId);
  }

  Future<void> setMqttClientId(String clientId) async {
    await init();
    await _prefs?.setString(AppConstants.keyMqttClientId, clientId);
  }
}
