package com.example.nexo

import android.content.Context
import android.os.Build
import androidx.media3.common.C
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.datasource.DefaultHttpDataSource
import androidx.media3.datasource.cache.CacheDataSource
import androidx.media3.datasource.cache.LeastRecentlyUsedCacheEvictor
import androidx.media3.datasource.cache.SimpleCache
import androidx.media3.exoplayer.DefaultLoadControl
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.hls.HlsMediaSource
import androidx.media3.exoplayer.trackselection.DefaultTrackSelector
import java.io.File

object PlayerPerformance {

    // ── Cache (singleton — ek baar banao) ────────────────────────────────────
    private var simpleCache: SimpleCache? = null

    fun getCache(context: Context): SimpleCache {
        if (simpleCache == null) {
            val cacheDir = File(context.cacheDir, "nexo_stream_cache")
            val cacheSize = 50L * 1024 * 1024 // 50 MB
            simpleCache = SimpleCache(
                cacheDir,
                LeastRecentlyUsedCacheEvictor(cacheSize)
            )
        }
        return simpleCache!!
    }

    // ── Optimized ExoPlayer builder ───────────────────────────────────────────
    fun buildOptimizedPlayer(context: Context): ExoPlayer {

        // Track selector: auto quality based on bandwidth
        val trackSelector = DefaultTrackSelector(context).apply {
            setParameters(
                buildUponParameters()
                    .setMaxVideoSizeSd()                    // SD default (Firestick safe)
                    .setPreferredAudioLanguage("en")
                    .setForceHighestSupportedBitrate(false) // auto bandwidth
            )
        }

        // Load control: buffer tuning
        val loadControl = DefaultLoadControl.Builder()
            .setBufferDurationsMs(
                /* minBufferMs    */ 15_000,   // 15s minimum buffer
                /* maxBufferMs    */ 50_000,   // 50s maximum buffer
                /* bufferForPlaybackMs             */ 2_500,
                /* bufferForPlaybackAfterRebufferMs*/ 5_000
            )
            .setPrioritizeTimeOverSizeThresholds(true)
            .build()

        return ExoPlayer.Builder(context)
            .setTrackSelector(trackSelector)
            .setLoadControl(loadControl)
            .setHandleAudioBecomingNoisy(true) // pause on headphone unplug
            .build()
            .apply {
                // Wake lock: keep screen on during playback
                setWakeMode(C.WAKE_MODE_NETWORK)
                // Auto repeat for Live TV (optional)
                repeatMode = Player.REPEAT_MODE_OFF
            }
    }

    // ── HLS Media Source with cache + custom headers ──────────────────────────
    fun buildHlsSource(
        context: Context,
        url: String,
        extraHeaders: Map<String, String> = emptyMap()
    ): HlsMediaSource {

        val httpDataSource = DefaultHttpDataSource.Factory().apply {
            setConnectTimeoutMs(15_000)
            setReadTimeoutMs(20_000)
            setAllowCrossProtocolRedirects(true)
            if (extraHeaders.isNotEmpty()) {
                setDefaultRequestProperties(extraHeaders)
            }
        }

        val cacheDataSource = CacheDataSource.Factory()
            .setCache(getCache(context))
            .setUpstreamDataSourceFactory(httpDataSource)
            .setFlags(CacheDataSource.FLAG_IGNORE_CACHE_ON_ERROR)

        return HlsMediaSource.Factory(cacheDataSource)
            .setAllowChunklessPreparation(true)
            .createMediaSource(MediaItem.fromUri(url))
    }

    // ── Firestick: detect device type ─────────────────────────────────────────
    fun isFireStick(): Boolean {
        val manufacturer = Build.MANUFACTURER.lowercase()
        val model = Build.MODEL.lowercase()
        return manufacturer.contains("amazon") ||
                model.contains("firetv") ||
                model.contains("fire tv") ||
                model.contains("aftt") ||
                model.contains("aftm")
    }

    fun isAndroidTV(): Boolean {
        return !isFireStick() &&
                Build.MODEL.lowercase().contains("atv") ||
                Build.DEVICE.lowercase().contains("fugu")
    }

    // ── Release cache on app close ────────────────────────────────────────────
    fun releaseCache() {
        simpleCache?.release()
        simpleCache = null
    }
}