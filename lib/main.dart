import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'models/ac_device.dart';
import 'models/scene.dart';
import 'models/device_group.dart';
import 'models/usage_statistics.dart';
import 'models/user_settings.dart';
import 'features/home/widgets/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(ACDeviceAdapter());
  Hive.registerAdapter(SceneAdapter());
  Hive.registerAdapter(DeviceSettingAdapter());
  Hive.registerAdapter(DeviceGroupAdapter());
  Hive.registerAdapter(UsageStatisticsAdapter());
  Hive.registerAdapter(TemperatureReadingAdapter());
  Hive.registerAdapter(UserSettingsAdapter());
  Hive.registerAdapter(QuickActionAdapter());

  await Hive.openBox('smart_ac_box');

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const ProviderScope(child: SmartACApp()));
}

class SmartACApp extends StatelessWidget {
  const SmartACApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart AC Controller',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const HomePage(),
    );
  }
}
