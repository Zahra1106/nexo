import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/PlayerController.dart';

class PlayerScreen extends StatefulWidget {
  final String streamUrl;
  final String channelTitle;

  const PlayerScreen({
    super.key,
    required this.streamUrl,
    required this.channelTitle,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final PlayerController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(PlayerController());

    // Force landscape + immersive fullscreen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.initPlayer(
        url: widget.streamUrl,
        title: widget.channelTitle,
      );
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Get.delete<PlayerController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTap: _ctrl.tapScreen,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Native ExoPlayer view ──────────────────────────────────────
              _NativePlayerView(streamUrl: widget.streamUrl),

              // ── Buffering spinner ──────────────────────────────────────────
              Obx(() => _ctrl.isBuffering.value
                  ? const Center(child: _BufferingIndicator())
                  : const SizedBox.shrink()),

              // ── Error overlay ──────────────────────────────────────────────
              Obx(() => _ctrl.errorMessage.value.isNotEmpty
                  ? _ErrorOverlay(
                message: _ctrl.errorMessage.value,
                onRetry: () => _ctrl.initPlayer(
                  url: widget.streamUrl,
                  title: widget.channelTitle,
                ),
              )
                  : const SizedBox.shrink()),

              // ── Controls overlay ───────────────────────────────────────────
              Obx(() => AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _ctrl.showControls.value ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: !_ctrl.showControls.value,
                  child: _ControlsOverlay(
                    ctrl: _ctrl,
                    channelTitle: widget.channelTitle,
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Native Android View (ExoPlayer) ──────────────────────────────────────────

class _NativePlayerView extends StatelessWidget {
  final String streamUrl;
  const _NativePlayerView({required this.streamUrl});

  @override
  Widget build(BuildContext context) {
    return AndroidView(
      viewType: 'nexo_exoplayer',
      creationParams: {'url': streamUrl},
      creationParamsCodec: const StandardMessageCodec(),
      layoutDirection: TextDirection.ltr,
    );
  }
}

// ─── Controls Overlay ─────────────────────────────────────────────────────────

class _ControlsOverlay extends StatelessWidget {
  final PlayerController ctrl;
  final String channelTitle;

  const _ControlsOverlay({required this.ctrl, required this.channelTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xCC000000),
            Colors.transparent,
            Colors.transparent,
            Color(0xCC000000),
          ],
          stops: [0.0, 0.2, 0.7, 1.0],
        ),
      ),
      child: Column(
        children: [
          // Top bar
          _TopBar(ctrl: ctrl, channelTitle: channelTitle),
          const Spacer(),
          // Center controls
          _CenterControls(ctrl: ctrl),
          const Spacer(),
          // Bottom bar: progress + time
          _BottomBar(ctrl: ctrl),
        ],
      ),
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final PlayerController ctrl;
  final String channelTitle;
  const _TopBar({required this.ctrl, required this.channelTitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              channelTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // LIVE badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE53935),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '● LIVE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() => IconButton(
            icon: Icon(
              ctrl.isFullscreen.value
                  ? Icons.fullscreen_exit
                  : Icons.fullscreen,
              color: Colors.white,
            ),
            onPressed: ctrl.toggleFullscreen,
          )),
        ],
      ),
    );
  }
}

// ─── Center Controls ──────────────────────────────────────────────────────────

class _CenterControls extends StatelessWidget {
  final PlayerController ctrl;
  const _CenterControls({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Seek back
        _SeekButton(
          icon: Icons.replay_10,
          onTap: ctrl.seekBackward,
        ),
        const SizedBox(width: 32),
        // Play / Pause
        Obx(() => GestureDetector(
          onTap: ctrl.togglePlayPause,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white54, width: 2),
            ),
            child: Icon(
              ctrl.isPlaying.value ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 40,
            ),
          ),
        )),
        const SizedBox(width: 32),
        // Seek forward
        _SeekButton(
          icon: Icons.forward_10,
          onTap: ctrl.seekForward,
        ),
      ],
    );
  }
}

class _SeekButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SeekButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}

// ─── Bottom Bar ───────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final PlayerController ctrl;
  const _BottomBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        children: [
          // Progress slider
          Obx(() => SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbColor: const Color(0xFFE53935),
              activeTrackColor: const Color(0xFFE53935),
              inactiveTrackColor: Colors.white30,
              overlayColor: Colors.red.withOpacity(0.2),
              thumbShape:
              const RoundSliderThumbShape(enabledThumbRadius: 7),
              trackHeight: 3,
            ),
            child: Slider(
              value: ctrl.progressRatio.clamp(0.0, 1.0),
              onChanged: (v) {
                final ms =
                (v * ctrl.totalDuration.value.inMilliseconds).toInt();
                ctrl.seekTo(Duration(milliseconds: ms));
              },
            ),
          )),
          // Time row
          Obx(() => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ctrl.formattedPosition,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  ctrl.formattedDuration,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// ─── Buffering Indicator ──────────────────────────────────────────────────────

class _BufferingIndicator extends StatelessWidget {
  const _BufferingIndicator();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            color: Color(0xFFE53935),
            strokeWidth: 3,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Buffering...',
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
        ),
      ],
    );
  }
}

// ─── Error Overlay ────────────────────────────────────────────────────────────

class _ErrorOverlay extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorOverlay({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFE53935), size: 56),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry', style: TextStyle(fontSize: 15)),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}