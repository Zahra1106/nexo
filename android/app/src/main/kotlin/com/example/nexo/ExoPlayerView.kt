package com.example.nexo

import android.content.Context
import android.view.KeyEvent
import android.view.View
import androidx.media3.common.MediaItem
import androidx.media3.common.PlaybackException
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.ui.PlayerView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class ExoPlayerView(
    context: Context,
    messenger: BinaryMessenger,
    viewId: Int,
    creationParams: Map<String, Any>?
) : PlatformView, MethodChannel.MethodCallHandler {

    // ── Views & Player ───────────────────────────────────────────────────────
    private val playerView: PlayerView = PlayerView(context)
    private val player: ExoPlayer = ExoPlayer.Builder(context).build()

    // ── Channels ─────────────────────────────────────────────────────────────
    // Flutter → Kotlin  (controls: play, pause, seek …)
    private val controlChannel = MethodChannel(messenger, "nexo_exoplayer/controls")
    // Kotlin → Flutter  (events: position, state, error …)
    private val eventChannel  = MethodChannel(messenger, "nexo_exoplayer/events")

    init {
        // Attach player to view
        playerView.player = player
        playerView.useController = false   // We use Flutter UI controls
        playerView.isFocusable = true
        playerView.isFocusableInTouchMode = true

        // Listen for Flutter → Kotlin method calls
        controlChannel.setMethodCallHandler(this)

        // ExoPlayer listener (Kotlin → Flutter callbacks)
        player.addListener(object : Player.Listener {

            override fun onPlaybackStateChanged(playbackState: Int) {
                val state = when (playbackState) {
                    Player.STATE_BUFFERING -> "buffering"
                    Player.STATE_READY     -> "playing"
                    Player.STATE_ENDED     -> "ended"
                    else                   -> "idle"
                }
                eventChannel.invokeMethod(
                    "onPlaybackStateChanged",
                    mapOf("state" to state)
                )
                if (playbackState == Player.STATE_READY) {
                    eventChannel.invokeMethod(
                        "onPlayerReady",
                        mapOf("duration" to player.duration)
                    )
                }
                if (playbackState == Player.STATE_ENDED) {
                    eventChannel.invokeMethod("onPlayerEnded", null)
                }
            }

            override fun onIsPlayingChanged(isPlaying: Boolean) {
                val state = if (isPlaying) "playing" else "paused"
                eventChannel.invokeMethod(
                    "onPlaybackStateChanged",
                    mapOf("state" to state)
                )
            }

            override fun onPlayerError(error: PlaybackException) {
                eventChannel.invokeMethod(
                    "onError",
                    mapOf("message" to (error.message ?: "Unknown playback error"))
                )
            }
        })

        // Position ticker — update Flutter every second
        playerView.postDelayed(object : Runnable {
            override fun run() {
                if (player.isPlaying) {
                    val buffered = if (player.duration > 0)
                        player.bufferedPosition.toDouble() / player.duration.toDouble()
                    else 0.0

                    eventChannel.invokeMethod(
                        "onPositionChanged",
                        mapOf(
                            "position"      to player.currentPosition,
                            "bufferPercent" to buffered
                        )
                    )
                }
                playerView.postDelayed(this, 1000)
            }
        }, 1000)

        // Auto-play the URL from creationParams if provided
        creationParams?.get("url")?.toString()?.let { loadStream(it) }
    }

    // ─── Flutter → Kotlin: method calls ─────────────────────────────────────

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> {
                val url = call.argument<String>("url") ?: ""
                loadStream(url)
                result.success(null)
            }
            "play" -> {
                player.play()
                result.success(null)
            }
            "pause" -> {
                player.pause()
                result.success(null)
            }
            "seekTo" -> {
                val posMs = call.argument<Int>("position")?.toLong() ?: 0L
                player.seekTo(posMs)
                result.success(null)
            }
            "setVolume" -> {
                val volume = call.argument<Double>("volume")?.toFloat() ?: 1f
                player.volume = volume
                result.success(null)
            }
            "setFullscreen" -> {
                // Fullscreen is handled on Flutter side (orientation lock)
                result.success(null)
            }
            "dispose" -> {
                dispose()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    // ─── D-pad / Remote key handling ─────────────────────────────────────────

    fun handleKeyEvent(keyCode: Int, event: KeyEvent): Boolean {
        if (event.action != KeyEvent.ACTION_DOWN) return false

        return when (keyCode) {
            // Center / OK → play/pause toggle
            KeyEvent.KEYCODE_DPAD_CENTER,
            KeyEvent.KEYCODE_ENTER,
            KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE -> {
                if (player.isPlaying) player.pause() else player.play()
                eventChannel.invokeMethod("onDpadEvent", mapOf("key" to "playPause"))
                true
            }
            // Right arrow → seek +10s
            KeyEvent.KEYCODE_DPAD_RIGHT,
            KeyEvent.KEYCODE_MEDIA_FAST_FORWARD -> {
                player.seekTo((player.currentPosition + 10_000).coerceAtMost(player.duration))
                eventChannel.invokeMethod("onDpadEvent", mapOf("key" to "seekForward"))
                true
            }
            // Left arrow → seek -10s
            KeyEvent.KEYCODE_DPAD_LEFT,
            KeyEvent.KEYCODE_MEDIA_REWIND -> {
                player.seekTo((player.currentPosition - 10_000).coerceAtLeast(0))
                eventChannel.invokeMethod("onDpadEvent", mapOf("key" to "seekBackward"))
                true
            }
            // Volume up/down
            KeyEvent.KEYCODE_VOLUME_UP -> {
                player.volume = (player.volume + 0.1f).coerceAtMost(1f)
                true
            }
            KeyEvent.KEYCODE_VOLUME_DOWN -> {
                player.volume = (player.volume - 0.1f).coerceAtLeast(0f)
                true
            }
            // Back → tell Flutter to pop
            KeyEvent.KEYCODE_BACK -> {
                eventChannel.invokeMethod("onDpadEvent", mapOf("key" to "back"))
                true
            }
            else -> false
        }
    }

    // ─── Helpers ─────────────────────────────────────────────────────────────

    private fun loadStream(url: String) {
        val mediaItem = MediaItem.fromUri(url)
        player.setMediaItem(mediaItem)
        player.prepare()
        player.playWhenReady = true
    }

    override fun getView(): View = playerView

    override fun dispose() {
        controlChannel.setMethodCallHandler(null)
        player.release()
    }
}