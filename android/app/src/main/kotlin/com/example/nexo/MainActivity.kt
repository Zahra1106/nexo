package com.example.nexo

import android.view.KeyEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private var activePlayerView: ExoPlayerView? = null
    private lateinit var remoteChannel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ExoPlayer native view register
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                "nexo_exoplayer",
                ExoPlayerFactory(
                    flutterEngine.dartExecutor.binaryMessenger
                ) { playerView ->
                    activePlayerView = playerView
                }
            )

        // Remote button channel
        remoteChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "nexo_remote"
        )
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        // Pehle ExoPlayerView ko dena try karo (D-pad etc.)
        val handled = activePlayerView?.handleKeyEvent(keyCode, event) ?: false
        if (handled) return true

        // Firestick remote media buttons Flutter ko bhejna
        val buttonName = when (keyCode) {
            KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE  -> "play_pause"
            KeyEvent.KEYCODE_MEDIA_PLAY        -> "play"
            KeyEvent.KEYCODE_MEDIA_PAUSE       -> "pause"
            KeyEvent.KEYCODE_MEDIA_REWIND      -> "rewind"
            KeyEvent.KEYCODE_MEDIA_FAST_FORWARD -> "fast_forward"
            KeyEvent.KEYCODE_MEDIA_NEXT        -> "channel_down"
            KeyEvent.KEYCODE_MEDIA_PREVIOUS    -> "channel_up"
            KeyEvent.KEYCODE_MENU              -> "menu"
            else                               -> return super.onKeyDown(keyCode, event)
        }

        remoteChannel.invokeMethod("onRemoteButton", buttonName)
        return true
    }

    override fun onKeyUp(keyCode: Int, event: KeyEvent?): Boolean {
        return super.onKeyUp(keyCode, event)
    }
}