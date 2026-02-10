import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/scene.dart';
import '../../services/scene_service.dart';

final sceneServiceProvider = Provider<SceneService>((ref) {
  return SceneService();
});

final scenesProvider = FutureProvider<List<Scene>>((ref) async {
  final service = ref.watch(sceneServiceProvider);
  return await service.getAllScenes();
});

final sceneByIdProvider = Provider.family<Scene?, String>((ref, id) {
  final scenesAsync = ref.watch(scenesProvider);
  return scenesAsync.value?.firstWhere(
    (scene) => scene.id == id,
    orElse: () => null as Scene,
  );
});

final sceneNotifierProvider =
    StateNotifierProvider<SceneNotifier, AsyncValue<List<Scene>>>((ref) {
      final service = ref.watch(sceneServiceProvider);
      return SceneNotifier(service);
    });

class SceneNotifier extends StateNotifier<AsyncValue<List<Scene>>> {
  final SceneService _service;

  SceneNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadScenes();
  }

  Future<void> _loadScenes() async {
    state = const AsyncValue.loading();
    try {
      final scenes = await _service.getAllScenes();
      state = AsyncValue.data(scenes);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> addScene(Scene scene) async {
    try {
      await _service.addScene(scene);
      await _loadScenes();
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> updateScene(Scene scene) async {
    try {
      await _service.updateScene(scene);
      await _loadScenes();
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> deleteScene(String sceneId) async {
    try {
      await _service.deleteScene(sceneId);
      await _loadScenes();
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> triggerScene(String sceneId) async {
    try {
      await _service.triggerScene(sceneId);
      await _loadScenes();
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> refresh() async {
    await _loadScenes();
  }
}
