import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PlayerController extends GetxController {
  static const MethodChannel _channel =
  MethodChannel('nexo_exoplayer/controls');

  // --- Observables ---
  final isPlaying = false.obs;
  final isBuffering = true.obs;
  final isFullscreen = false.obs;
  final showControls = true.obs;
  final currentPosition = Duration.zero.obs;
  final totalDuration = Duration.zero.obs;
  final errorMessage = ''.obs;
  final bufferPercent = 0.0.obs;

  String? streamUrl;
  String? channelTitle;

  @override
  void onInit() {
    super.onInit();
    _channel.setMethodCallHandler(_handleNativeCall);
    _startControlsTimer();
  }

  // ─── Called from PlayerScreen ───────────────────────────────────────────────

  void initPlayer({required String url, String? title}) {
    streamUrl = url;
    channelTitle = title ?? 'Live TV';
    isBuffering.value = true;
    errorMessage.value = '';
    _invokeMethod('initialize', {'url': url});
  }

  void togglePlayPause() {
    if (isPlaying.value) {
      _invokeMethod('pause');
    } else {
      _invokeMethod('play');
    }
    _resetControlsTimer();
  }

  void seekTo(Duration position) {
    _invokeMethod('seekTo', {'position': position.inMilliseconds});
    _resetControlsTimer();
  }

  void seekForward({int seconds = 10}) {
    final target = currentPosition.value + Duration(seconds: seconds);
    seekTo(target > totalDuration.value ? totalDuration.value : target);
  }

  void seekBackward({int seconds = 10}) {
    final target = currentPosition.value - Duration(seconds: seconds);
    seekTo(target < Duration.zero ? Duration.zero : target);
  }

  void setVolume(double volume) {
    _invokeMethod('setVolume', {'volume': volume.clamp(0.0, 1.0)});
  }

  void toggleFullscreen() {
    isFullscreen.toggle();
    _invokeMethod('setFullscreen', {'fullscreen': isFullscreen.value});
  }

  void tapScreen() {
    showControls.toggle();
    if (showControls.value) _resetControlsTimer();
  }

  void disposePlayer() {
    _invokeMethod('dispose');
  }

  // ─── Native → Flutter callbacks ─────────────────────────────────────────────

  Future<void> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'onPlayerReady':
        isBuffering.value = false;
        isPlaying.value = true;
        final durationMs = call.arguments['duration'] as int? ?? 0;
        totalDuration.value = Duration(milliseconds: durationMs);
        break;

      case 'onPlaybackStateChanged':
        final state = call.arguments['state'] as String?;
        isPlaying.value = state == 'playing';
        isBuffering.value = state == 'buffering';
        break;

      case 'onPositionChanged':
        final posMs = call.arguments['position'] as int? ?? 0;
        currentPosition.value = Duration(milliseconds: posMs);
        final bufPct = call.arguments['bufferPercent'] as double? ?? 0.0;
        bufferPercent.value = bufPct;
        break;

      case 'onError':
        final msg = call.arguments['message'] as String? ?? 'Playback error';
        errorMessage.value = msg;
        isBuffering.value = false;
        isPlaying.value = false;
        break;

      case 'onPlayerEnded':
        isPlaying.value = false;
        currentPosition.value = totalDuration.value;
        break;
    }
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  Future<void> _invokeMethod(String method, [Map<String, dynamic>? args]) async {
    try {
      await _channel.invokeMethod(method, args);
    } on PlatformException catch (e) {
      errorMessage.value = 'Channel error: ${e.message}';
    }
  }

  // Auto-hide controls after 4 seconds
  late final _controlsTimer = _ControlsTimer(onHide: () => showControls.value = false);

  void _startControlsTimer() => _controlsTimer.start();
  void _resetControlsTimer() => _controlsTimer.reset();

  String get formattedPosition => _formatDuration(currentPosition.value);
  String get formattedDuration => _formatDuration(totalDuration.value);
  double get progressRatio {
    if (totalDuration.value.inMilliseconds == 0) return 0;
    return currentPosition.value.inMilliseconds /
        totalDuration.value.inMilliseconds;
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  void onClose() {
    _controlsTimer.cancel();
    disposePlayer();
    super.onClose();
  }
}

// Simple debounce timer helper
class _ControlsTimer {
  final VoidCallback onHide;
  _ControlsTimer({required this.onHide});

  static const _delay = Duration(seconds: 4);
  Future<void>? _future;
  bool _cancelled = false;

  void start() => _schedule();
  void reset() {
    _cancelled = true;
    _cancelled = false;
    _schedule();
  }

  void cancel() => _cancelled = true;

  void _schedule() async {
    _cancelled = false;
    await Future.delayed(_delay);
    if (!_cancelled) onHide();
  }
}