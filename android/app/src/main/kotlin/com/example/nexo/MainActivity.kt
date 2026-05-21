package com.example.nexo

import android.view.KeyEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    // Keep reference to active ExoPlayerView for D-pad forwarding
    private var activePlayerView: ExoPlayerView? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register the ExoPlayer native view factory
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                "nexo_exoplayer",
                ExoPlayerFactory(
                    flutterEngine.dartExecutor.binaryMessenger
                ) { playerView ->
                    // Capture the active player view when it's created
                    activePlayerView = playerView
                }
            )
    }

    // ── Forward ALL hardware key events to ExoPlayer ─────────────────────────
    override fun onKeyDown(keyCode: Int, event: KeyEvent): Boolean {
        val handled = activePlayerView?.handleKeyEvent(keyCode, event) ?: false
        return handled || super.onKeyDown(keyCode, event)
    }

    override fun onKeyUp(keyCode: Int, event: KeyEvent): Boolean {
        // Let ExoPlayer view handle key up for media keys if needed
        return super.onKeyUp(keyCode, event)
    }
}