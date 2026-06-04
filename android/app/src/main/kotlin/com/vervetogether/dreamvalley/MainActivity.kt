package com.vervetogether.dreamvalley

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * Main activity that bridges Flutter/Dart ↔ Android native media controls.
 *
 * Sets up:
 * - MethodChannel "com.vervetogether.dreamvalley/media" for Dart → Kotlin calls
 * - EventChannel "com.vervetogether.dreamvalley/media_actions" for Kotlin → Dart events
 */
class MainActivity : FlutterActivity() {

    companion object {
        private const val MEDIA_CHANNEL = "com.vervetogether.dreamvalley/media"
        private const val MEDIA_ACTIONS_CHANNEL = "com.vervetogether.dreamvalley/media_actions"
        private const val AUTH_CHANNEL = "com.vervetogether.dreamvalley/auth"
        private const val SYSTEM_CHANNEL = "com.vervetogether.dreamvalley/system"

        private var actionSink: EventChannel.EventSink? = null

        /**
         * Called by MediaPlaybackService when a lock screen button is tapped.
         * Sends the action name back to Dart via EventChannel.
         */
        fun sendMediaAction(action: String, value: Double? = null) {
            actionSink?.success(
                if (value != null) mapOf("action" to action, "value" to value)
                else mapOf("action" to action)
            )
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Dart → Kotlin: durable identity storage (EncryptedSharedPreferences).
        // Mirror of iOS DreamValleyAuthStorage. Write-back-verify lives inside
        // the storage class — Dart only forwards the boolean result.
        val authStorage = DreamValleyAuthStorage(applicationContext)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AUTH_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "store" -> {
                        val token = call.argument<String>("token") ?: ""
                        result.success(authStorage.store(token))
                    }
                    "read" -> result.success(authStorage.read())
                    "clear" -> result.success(authStorage.clear())
                    else -> result.notImplemented()
                }
            }

        // System: open a URL in the EXTERNAL browser (Stripe checkout, #35).
        // Mirror of iOS DreamValleySystemBridge — keeps digital-goods checkout
        // out of the app WebView (reader-app compliance).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SYSTEM_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openExternal" -> {
                        val url = call.argument<String>("url")
                        if (url.isNullOrEmpty()) {
                            result.success(false)
                        } else {
                            try {
                                val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
                                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                }
                                startActivity(intent)
                                result.success(true)
                            } catch (e: Exception) {
                                Log.e("DVSystem", "openExternal failed: ${e.message}", e)
                                result.success(false)
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        // Dart → Kotlin: receive media commands from the web player
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, MEDIA_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "updateMetadata" -> {
                        val intent = Intent(this, MediaPlaybackService::class.java).apply {
                            action = MediaPlaybackService.ACTION_UPDATE_METADATA
                            putExtra("title", call.argument<String>("title"))
                            putExtra("artist", call.argument<String>("artist"))
                            putExtra("album", call.argument<String>("album"))
                            putExtra("artworkUrl", call.argument<String>("artworkUrl"))
                        }
                        startMediaService(intent)
                        result.success(null)
                    }
                    "updatePlaybackState" -> {
                        val intent = Intent(this, MediaPlaybackService::class.java).apply {
                            action = MediaPlaybackService.ACTION_UPDATE_STATE
                            putExtra("playing", call.argument<Boolean>("playing") ?: false)
                        }
                        startMediaService(intent)
                        result.success(null)
                    }
                    "updatePosition" -> {
                        val intent = Intent(this, MediaPlaybackService::class.java).apply {
                            action = MediaPlaybackService.ACTION_UPDATE_POSITION
                            putExtra("position", (call.argument<Double>("position") ?: 0.0).toLong() * 1000)
                            putExtra("duration", (call.argument<Double>("duration") ?: 0.0).toLong() * 1000)
                        }
                        startMediaService(intent)
                        result.success(null)
                    }
                    "stop" -> {
                        val intent = Intent(this, MediaPlaybackService::class.java).apply {
                            action = MediaPlaybackService.ACTION_STOP
                        }
                        startService(intent)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        // Kotlin → Dart: send lock screen button events back to the web page
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, MEDIA_ACTIONS_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    actionSink = events
                }
                override fun onCancel(arguments: Any?) {
                    actionSink = null
                }
            })
    }

    private fun startMediaService(intent: Intent) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }
}
