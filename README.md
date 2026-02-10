# 智能云空调控制APP（Flutter版）

一款基于Flutter技术栈的跨平台智能空调远程控制与管理APP，实现实体空调的"云化"操控，兼具智能化、个性化、场景化特性。

## 项目特性

### 核心功能
- **基础遥控功能**: 完全模拟实体空调遥控器，支持开关、调温、模式切换、风速/风向控制、定时功能
- **设备管理**: 支持多设备添加、删除、分组管理，状态实时同步
- **智能场景**: 自定义场景、天气联动、语音控制
- **数据统计**: 使用时长统计、能耗估算、温度变化曲线、使用频次分析
- **家庭共享**: 多成员权限管理、设备共享
- **个性化设置**: 遥控器面板自定义、主题切换、快捷入口
- **辅助功能**: 故障预警、维护提醒、空调型号匹配、使用教程

### 技术亮点
- **跨平台**: 支持iOS和Android
- **状态管理**: 使用Riverpod进行高效状态管理
- **本地存储**: Hive + SharedPreferences实现数据持久化
- **网络通信**: 支持WiFi、蓝牙、局域网多种连接方式
- **UI设计**: 独特的深色科技风设计，流畅的动画效果

## 项目结构

```
lib/
├── main.dart                          # 应用入口
├── core/
│   ├── theme/
│   │   ├── app_theme.dart             # 主题配置
│   │   └── app_colors.dart            # 颜色定义
│   ├── constants/
│   │   └── app_constants.dart          # 常量定义
│   ├── providers/
│   │   ├── device_provider.dart        # 设备状态管理
│   │   ├── scene_provider.dart         # 场景状态管理
│   │   └── settings_provider.dart      # 设置状态管理
│   └── services/
│       ├── device_service.dart          # 设备服务
│       ├── scene_service.dart           # 场景服务
│       ├── settings_service.dart        # 设置服务
│       └── statistics_service.dart      # 统计服务
├── models/
│   ├── ac_device.dart                 # 设备模型
│   ├── scene.dart                     # 场景模型
│   ├── device_group.dart               # 设备分组模型
│   ├── usage_statistics.dart           # 使用统计模型
│   └── user_settings.dart             # 用户设置模型
└── features/
    ├── home/
    │   └── widgets/
    │       ├── home_page.dart          # 首页
    │       ├── device_card.dart        # 设备卡片
    │       ├── scene_card.dart         # 场景卡片
    │       └── quick_action_button.dart # 快捷操作按钮
    └── remote/
        └── widgets/
            └── remote_controller.dart   # 遥控器面板
```

## 快速开始

### 环境要求
- Flutter 3.16+
- Dart 3.0+
- iOS 12.0+ / Android 6.0+

### 安装依赖

```bash
flutter pub get
```

### 运行项目

```bash
# 运行Android版本
flutter run

# 运行iOS版本（仅限macOS）
flutter run -d ios

# 运行Web版本
flutter run -d chrome
```

### 生成代码

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 配置说明

### API配置
详细配置说明请参考 [API配置指南.md](./API配置指南.md)

主要需要配置：
1. **天气API**: 在设置中配置天气API密钥
2. **MQTT配置**: 配置MQTT服务器地址、用户名、密码等

### 权限配置

#### Android权限
在 `android/app/src/main/AndroidManifest.xml` 中添加网络、蓝牙、位置、存储、相机等权限。

#### iOS权限
在 `ios/Runner/Info.plist` 中添加蓝牙、位置、相机、麦克风等权限描述。

## 主要依赖

| 依赖库 | 版本 | 用途 |
|--------|------|------|
| flutter_riverpod | ^2.4.9 | 状态管理 |
| dio | ^5.4.0 | 网络请求 |
| hive_flutter | ^1.1.0 | 本地存储 |
| flutter_blue_plus | ^1.32.1 | 蓝牙通信 |
| fl_chart | ^0.66.0 | 图表展示 |
| flutter_tts | ^3.8.5 | 语音合成 |
| speech_to_text | ^6.6.0 | 语音识别 |
| permission_handler | ^11.1.0 | 权限管理 |
| go_router | ^13.0.0 | 路由管理 |
| mobile_scanner | ^4.0.1 | 二维码扫描 |
| weather | ^3.1.1 | 天气API |
|`flutter_animate` | ^4.3.0 | 动画效果 |

## UI设计

### 设计风格
- **主题**: 深色科技风
- **主色调**: 深蓝 (#0A0E27)
- **强调色**: 青色 (#00F0FF)
- **次强调色**: 紫色 (#7B61FF)
- **成功色**: 绿色 (#00FFA3)
- **警告色**: 橙色 (#FFB800)
- **错误色**: 红色 (#FF4757)

### 交互特性
- 流畅的页面过渡动画
- 按钮点击反馈（震动、音效）
- 设备状态实时同步
- 下拉刷新支持

## 功能说明

### 遥控器面板
- 大尺寸电源按钮，带发光效果
- 温度调节（16℃-30℃）
- 模式切换（制冷、制热、送风、除湿)
- 风速控制（低、中、高、自动）
- 风向控制（上、下、左、右、固定）
- 定时功能（1小时、2小时、4小时、取消）

### 设备管理
- 添加设备（WiFi/蓝牙/局域网）
- 设备列表展示
- 设备分组管理
- 设备详情查看
- 设备删除

### 智能场景
- 创建自定义场景
- 场景一键触发
- 场景列表展示

### 数据统计
- 使用时长统计
- 能耗估算
- 温度变化曲线
- 使用频次分析

## 开发说明

### 代码规范
- 遵循Dart官方代码规范
- 使用代码格式化：`flutter format .`
- 运行代码分析：`flutter analyze`

### 测试
```bash
# 运行所有测试
flutter test

# 运行特定测试
flutter test test/widget_test.dart
```

### 构建
```bash
# 构建Android APK
flutter build apk --release

# 构建Android App Bundle
flutter build appbundle --release

# �iOS IPA
flutter build ios --release
```

## 常见问题

### Q: 如何添加设备？
A: 在首页点击右下角"添加设备"按钮，填写设备信息后添加。

### Q: 如何配置天气API？
A: 进入设置页面，点击"天气API"，输入API密钥后保存。

### Q: 如何配置MQTT？
A: 进入设置页面，点击"MQTT配置"，填写服务器信息后保存。

### Q: 设备显示离线怎么办？
A: 检查设备与手机是否在同一网络，确认设备IP地址正确。

## 贡献指南

欢迎提交Issue和Pull Request！

## 许可证

本项目仅供学习和研究使用。

## 联系方式

如有问题，请提交Issue。

---

**注意**: 本项目为演示项目，部分功能可能需要根据实际硬件设备进行调整。
