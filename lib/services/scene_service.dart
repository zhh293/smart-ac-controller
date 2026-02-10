import 'package:hive_flutter/hive_flutter.dart';
import '../models/scene.dart';
import '../../core/constants/app_constants.dart';

class SceneService {
  late Box<Scene> _scenesBox;

  Future<void> init() async {
    if (!Hive.isBoxOpen(AppConstants.scenesBoxName)) {
      _scenesBox = await Hive.openBox(AppConstants.scenesBoxName);
    } else {
      _scenesBox = Hive.box(AppConstants.scenesBoxName);
    }
  }

  Future<List<Scene>> getAllScenes() async {
    await init();
    return _scenesBox.values.toList();
  }

  Future<Scene?> getSceneById(String id) async {
    await init();
    return _scenesBox.get(id);
  }

  Future<void> addScene(Scene scene) async {
    await init();
    await _scenesBox.put(scene.id, scene);
  }

  Future<void> updateScene(Scene scene) async {
    await init();
    await _scenesBox.put(scene.id, scene);
  }

  Future<void> deleteScene(String sceneId) async {
    await init();
    await _scenesBox.delete(sceneId);
  }

  Future<void> triggerScene(String sceneId) async {
    await init();
    final scene = _scenesBox.get(sceneId);
    if (scene != null) {
      final updated = scene.copyWith(lastTriggeredAt: DateTime.now());
      await _scenesBox.put(sceneId, updated);
    }
  }

  Future<void> clearAllScenes() async {
    await init();
    await _scenesBox.clear();
  }
}
