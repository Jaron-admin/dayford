import 'dart:async';

import 'package:flutter/foundation.dart';

import '../constants/model_catalog.dart';

enum ModelPhase {
  none,
  cellular,
  downloading,
  paused,
  failed,
  storage,
  ready,
  unsupported,
}

/// Download and model selection boundary. The fake implementation never
/// opens a socket; task 3 replaces it with a real downloader.
abstract class ModelManager extends ChangeNotifier {
  ModelPhase get phase;
  double get progress;
  String? get activeModelId;
  bool get onCellular;

  void startDownload(String modelId);
  void pause();
  void resume();
  void retry();
  void allowCellularOnce();
  void deleteActive();
}

class FakeModelManager extends ModelManager {
  FakeModelManager({
    this.autoProgress = true,
    ModelPhase initial = ModelPhase.none,
    this.onCellular = false,
    this.hasSpace = true,
  }) : phase = initial;

  /// When false, download stays put so tests do not wait on a timer.
  final bool autoProgress;
  bool hasSpace;

  @override
  ModelPhase phase;

  @override
  double progress = 0;

  @override
  String? activeModelId;

  @override
  bool onCellular;

  bool cellularAllowed = false;
  String? _downloadingId;
  Timer? _timer;

  static const _tick = Duration(milliseconds: 120);

  void restore({
    required ModelPhase phase,
    required double progress,
    String? activeModelId,
  }) {
    _stop();
    this.phase = phase;
    this.progress = progress;
    this.activeModelId = activeModelId;
    if (phase == ModelPhase.downloading && autoProgress) _schedule();
    notifyListeners();
  }

  /// Pins a screen state for the debug gallery and screenshots.
  void debugForce(ModelPhase next, {double progress = 0.46, bool? cellular}) {
    _stop();
    phase = next;
    this.progress = progress.clamp(0, 1);
    if (cellular != null) onCellular = cellular;
    if (next == ModelPhase.ready) {
      activeModelId ??= ModelCatalog.mid.id;
    }
    if (next == ModelPhase.none || next == ModelPhase.unsupported) {
      if (next == ModelPhase.none) activeModelId = null;
    }
    notifyListeners();
  }

  @override
  void startDownload(String modelId) {
    if (phase == ModelPhase.unsupported) return;
    if (onCellular && !cellularAllowed) {
      phase = ModelPhase.cellular;
      _downloadingId = modelId;
      notifyListeners();
      return;
    }
    if (!hasSpace) {
      phase = ModelPhase.storage;
      _downloadingId = modelId;
      notifyListeners();
      return;
    }
    _downloadingId = modelId;
    phase = ModelPhase.downloading;
    if (progress <= 0 || progress >= 1) progress = 0.02;
    notifyListeners();
    if (autoProgress) _schedule();
  }

  @override
  void pause() {
    if (phase != ModelPhase.downloading) return;
    _stop();
    phase = ModelPhase.paused;
    notifyListeners();
  }

  @override
  void resume() {
    if (phase != ModelPhase.paused && phase != ModelPhase.failed) return;
    phase = ModelPhase.downloading;
    notifyListeners();
    if (autoProgress) _schedule();
  }

  @override
  void retry() => resume();

  @override
  void allowCellularOnce() {
    cellularAllowed = true;
    onCellular = true;
    startDownload(_downloadingId ?? ModelCatalog.mid.id);
  }

  @override
  void deleteActive() {
    _stop();
    phase = ModelPhase.none;
    progress = 0;
    activeModelId = null;
    _downloadingId = null;
    notifyListeners();
  }

  void _schedule() {
    _timer?.cancel();
    _timer = Timer.periodic(_tick, (_) {
      progress = (progress + 0.007).clamp(0, 1);
      if (progress >= 1) {
        _stop();
        phase = ModelPhase.ready;
        activeModelId = _downloadingId ?? ModelCatalog.mid.id;
        progress = 1;
      }
      notifyListeners();
    });
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }
}

String modelStatusLine(ModelPhase phase, double progress, String? modelId) {
  final name = modelId == null
      ? ModelCatalog.mid.name
      : ModelCatalog.byId(modelId).name;
  final percent = (progress * 100).round();
  return switch (phase) {
    ModelPhase.ready => '$name · 正在使用',
    ModelPhase.downloading => '$name · 下载中 $percent%',
    ModelPhase.paused => '$name · 已暂停',
    ModelPhase.failed => '$name · 下载断了，可以重试',
    ModelPhase.unsupported => '这台手机暂时用不了',
    ModelPhase.cellular => '还没下载 · 等 Wi‑Fi',
    ModelPhase.storage => '空间还不够 · 不影响写日记',
    ModelPhase.none => '还没下载 · 不影响写日记',
  };
}
