package com.example.nexo

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class ExoPlayerFactory(
    private val messenger: BinaryMessenger,
    private val onViewCreated: ((ExoPlayerView) -> Unit)? = null
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        @Suppress("UNCHECKED_CAST")
        val creationParams = args as? Map<String, Any>

        val playerView = ExoPlayerView(
            context  = context,
            messenger = messenger,
            viewId   = viewId,
            creationParams = creationParams
        )

        // Notify MainActivity so it can forward D-pad events
        onViewCreated?.invoke(playerView)

        return playerView
    }
}