# 智能云空调控制APP - API配置指南

本文档详细记录了需要用户手动配置的API密钥和个性化设置。

## 一、天气API配置

### 1.1 配置位置
- **文件路径**: `lib/features/home/widgets/home_page.dart`
- **方法**: `_WeatherApiDialog` 类
- **行号**: 约 580-620 行

### 1.2 配置方法
1. 打开APP
2. 进入"设置"页面
3. 点击"天气API"选项
4. 在弹出的对话框中输入您的天气API密钥
5. 点击"保存"按钮

### 1.3 获取API密钥
本APP支持多种天气API，推荐使用以下服务：

#### OpenWeatherMap（推荐）
- **官网**: https://openweathermap.org/api
- **注册步骤**:
  1. 访问官网并注册账号
  2. 进入API keys页面
  3. 创建新的API密钥
  4. 复制API密钥到APP中

#### 和风天气
- **官网**: https://dev.qweather.com/
- **注册步骤**:
  1. 访问官网并注册开发者账号
  2. 创建应用获取Key
  3. 复制API密钥到APP中

### 1.4 代码中的存储位置
```dart
// lib/services/settings_service.dart
Future<String?> getWeatherApiKey() async {
  await init();
  return _prefs?.getString(AppConstants.keyWeatherApiKey);
}

Future<void> setWeatherApiKey(String apiKey) async {
  await init();
  await _prefs?.setString(AppConstants.keyWeatherApiKey, apiKey);
}
```

## 二、MQTT配置

### 2.1 配置位置
- **文件路径**: `lib/features/home/widgets/home_page.dart`
- **方法**: `_MqttConfigDialog` 类
- **行号**: 约 625-710 行

### 2.2 配置方法
1. 打开APP
2. 进入"设置"页面
3. 点击"MQTT配置"选项
4. 在弹出的对话框中填写以下信息：
   - **Broker URL**: MQTT服务器地址（如：mqtt://broker.example.com）
   - **用户名**: MQTT连接用户名（可选）
   - **密码**: MQTT连接密码（可选）
   - **Client ID**: 客户端标识（可选，不填会自动生成）
5. 点击"保存"按钮

### 2.3 获取MQTT服务
您可以使用以下公共或自建MQTT服务：

#### 公共MQTT Broker（测试用）
- **EMQX公共服务器**: `mqtt://broker.emqx.io:1883`
- **Mosquitto公共服务器**: `mqtt://test.mosquitto.org:1883`

#### 自建MQTT服务
- **EMQX**: https://www.emqx.io/
- **Mosquitto**: https://mosquitto.org/
- **HiveMQ**: https://www.hivemq.com/

### 2.4 代码中的存储位置
```dart
// lib/services/settings_service.dart
Future<String?> getMqttBrokerUrl() async {
  await init();
  return _prefs?.getString(AppConstants.keyMqttBrokerUrl);
}

Future<String?> getMqttUsername() async {
  await init();
  return _prefs?.getString(AppConstants.keyMqttUsername);
}

Future<String?> getMqttPassword() async {
  await init();
  return _prefs?.getString(AppConstants.keyMqttPassword);
}

Future<String?> getMqttClientId() async {
  await init();
  return _prefs?.getString(AppConstants.keyMqttClientId);
}
```

## 三、设备连接配置

### 3.1 WiFi设备配置
添加WiFi设备时需要配置：
- **设备名称**: 自定义设备名称
- **品牌**: 空调品牌（如：格力、美的、海尔等）
- **型号**: 空调型号（如：KFR-35GW）
- **IP地址**: 设备在局域网中的IP地址
- **MAC地址**: 设备的MAC地址（可选）

### 3.2 蓝牙设备配置
添加蓝牙设备时需要配置：
- **设备名称**: 自定义设备名称
- **品牌**: 空调品牌
- **型号**: 空调型号
- **蓝牙地址**: 设备的蓝牙MAC地址

### 3.3 局域网设备配置
添加局域网设备时需要配置：
- **设备名称**: 自定义设备名称
- **品牌**: 空调品牌
- **型号**: 空调型号
- **IP地址**: 设备IP地址
- **端口**: 设备通信端口（默认：1883）

## 四、权限配置

### 4.1 Android权限
在 `android/app/src/main/AndroidManifest.xml` 中添加以下权限：

```xml
<!-- 网络权限 -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />

<!-- 蓝牙权限 -->
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />

<!-- 位置权限（蓝牙扫描需要） -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- 存储权限 -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

<!-- 语音权限 -->
<uses-permission android:name="android.permission.RECORD_AUDIO" />

<!-- 相机权限（扫码添加设备） -->
<uses-permission android:name="android.permission.CAMERA" />
```

### 4.2 iOS权限
在 `ios/Runner/Info.plist` 中添加以下权限：

```xml
<!-- 网络权限 -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>

<!-- 蓝牙权限 -->
<key>NSBluetoothAlwaysUsageDescription</key>
<string>需要使用蓝牙连接空调设备</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>需要使用蓝牙连接空调设备</string>

<!-- 位置权限（蓝牙扫描需要） -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>需要使用位置信息扫描附近的设备</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>需要使用位置信息扫描附近的设备</string>

<!-- 相机权限（扫码添加设备） -->
<key>NSCameraUsageDescription</key>
<string>需要使用相机扫描设备二维码</string>

<!-- 语音权限 -->
<key>NSMicrophoneUsageDescription</key>
<string>需要使用麦克风进行语音控制</string>
```

## 五、其他配置

### 5.1 主题配置
在 `lib/core/theme/app_theme.dart` 中可以自定义主题颜色：

```dart
class AppTheme {
  static const Color primaryColor = Color(0xFF0A0E27);      // 主色调
  static const Color accentColor = Color(0xFF00F0FF);      // 强调色
  static const Color secondaryAccent = Color(0xFF7B61FF);   // 次强调色
  static const Color successColor = Color(0xFF00FFA3);      // 成功色
  static const Color warningColor = Color(0xFFFFB800);      // 警告色
  static const Color errorColor = Color(0xFFFF4757);       // 错误色
  // ... 其他颜色配置
}
```

### 5.2 常量配置
在 `lib/core/constants/app_constants.dart` 中可以修改应用常量：

```dart
class AppConstants {
  static const String appName = 'Smart AC Controller';  // 应用名称
  static const String appVersion = '1.0.0';             // 应用版本
  
  static const int minTemperature = 16;   // 最低温度
  static const int maxTemperature = 30;   // 最高温度
  static const int defaultTemperature = 24; // 默认温度
  
  static const int maxDevices = 20;         // 最大设备数
  static const int maxScenes = 20;         // 最大场景数
  // ... 其他常量配置
}
```

## 六、调试配置

### 6.1 启用调试日志
在 `lib/main.dart` 中添加：

```dart
void main() async {
  // ... 现有代码
  
  // 启用调试日志
  if (kDebugMode) {
    print('Debug mode enabled');
  }
  
  runApp(const ProviderScope(child: SmartACApp()));
}
```

### 6.2 模拟设备数据
在开发阶段，可以添加模拟设备数据：

```dart
// 在 lib/services/device_service.dart 中添加
Future<void> addMockDevices() async {
  await init();
  
  final mockDevice = ACDevice(
    id: 'mock_device_1',
    name: '客厅空调',
    brand: '格力',
    model: 'KFR-35GW',
    connectionType: ConnectionType.wifi,
    isOnline: true,
    isPoweredOn: false,
    temperature: 24,
    targetTemperature: 24,
    mode: ACMode.cool,
    fanSpeed: FanSpeed.auto,
    swingDirection: SwingDirection.fixed,
    powerRating: 1.5,
  );
  
  await _devicesBox.put(mockDevice.id, mockDevice);
}
```

## 七、生产环境配置

### 7.1 签名配置（Android）
1. 创建签名密钥：
```bash
keytool -genkey -v -keystore release.keystore -alias release -keyalg RSA -keysize 2048 -validity 10000
```

2. 在 `android/key.properties` 中配置：
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=release
storeFile=../release.keystore
```

3. 在 `android/app/build.gradle` 中配置签名：
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### 7.2 iOS签名配置
在Xcode中配置：
1. 选择项目 → Signing & Capabilities
2. 选择开发团队
3. 配置Bundle Identifier
4. 启用自动签名

## 八、常见问题

### Q1: 天气API配置后不生效？
**A**: 检查API密钥是否正确，确保网络连接正常，查看控制台日志。

### Q2: MQTT连接失败？
**A**: 检查Broker URL格式是否正确（如：mqtt://broker.example.com:1883），确认服务器可访问。

### Q3: 蓝牙设备扫描不到？
**A**: 确保已授予位置权限和蓝牙权限，手机蓝牙已开启，设备处于可被发现状态。

### Q4: 设备添加后显示离线？
**A**: 检查设备与手机是否在同一网络，确认设备IP地址正确，检查网络防火墙设置。

## 九、技术支持

如遇到配置问题，请检查：
1. 控制台错误日志
2. 网络连接状态
3. 权限是否已授予
4. API密钥是否有效

---

**注意**: 本文档中的配置信息仅供开发测试使用，生产环境请使用安全的配置管理方案。
