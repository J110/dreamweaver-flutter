package com.vervetogether.dreamvalley

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import android.os.IBinder
import android.support.v4.media.MediaMetadataCompat
import android.support.v4.media.session.MediaSessionCompat
import android.support.v4.media.session.PlaybackStateCompat
import androidx.core.app.NotificationCompat
import androidx.media.session.MediaButtonReceiver
import kotlinx.coroutines.*
import java.net.URL

/**
 * Foreground service that provides Android lock screen media controls
 * for audio playing inside the WebView.
 *
 * Communication flow:
 *   JS (mediaSessionManager.js)
 *     → Dart (JavaScriptChannel "DreamValleyMedia")
 *       → Kotlin (MethodChannel → this service)
 *         → Android MediaSession → lock screen / notification
 *
 * Lock screen button taps flow back:
 *   MediaSession.Callback → MainActivity.mediaActionSink → Dart → JS
 */
class MediaPlaybackService : Service() {

    companion object {
        const val CHANNEL_ID = "dreamvalley_media"
        const val NOTIFICATION_ID = 1001

        const val ACTION_UPDATE_METADATA = "UPDATE_METADATA"
        const val ACTION_UPDATE_STATE = "UPDATE_STATE"
        const val ACTION_UPDATE_POSITION = "UPDATE_POSITION"
        const val ACTION_STOP = "STOP"

        private var instance: MediaPlaybackService? = null

        // Persists across START_STICKY service kill+recreate within the same
        // app process. The system kills foreground services under memory
        // pressure and re-invokes onStartCommand with a null intent; without
        // this snapshot the service would come back showing default title
        // (no notification reapplied) until the next user-driven content
        // change refired metadata.
        @Volatile private var lastTitle: String? = null
        @Volatile private var lastArtist: String? = null
        @Volatile private var lastAlbum: String? = null
        @Volatile private var lastArtworkUrl: String? = null
        @Volatile private var lastPosition: Long = 0L
        @Volatile private var lastDuration: Long = 0L
        @Volatile private var lastIsPlaying: Boolean = false

        fun getInstance(): MediaPlaybackService? = instance
    }

    private lateinit var mediaSession: MediaSessionCompat
    private val serviceScope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    private var artworkJob: Job? = null

    // Current state
    private var currentTitle = "Dream Valley Story"
    private var currentArtist = "Dream Valley"
    private var currentAlbum = "Bedtime Stories"
    private var currentArtwork: Bitmap? = null
    private var isPlaying = false
    private var currentPosition = 0L
    private var currentDuration = 0L

    override fun onCreate() {
        super.onCreate()
        instance = this
        createNotificationChannel()
        initMediaSession()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        MediaButtonReceiver.handleIntent(mediaSession, intent)

        // Null intent / unknown action = system recreated us after a
        // START_STICKY kill. Reapply the last remembered state so the
        // notification doesn't come back showing the default title.
        if (intent?.action == null) {
            restoreFromLastState()
            return START_STICKY
        }

        when (intent.action) {
            ACTION_UPDATE_METADATA -> {
                currentTitle = intent.getStringExtra("title") ?: currentTitle
                currentArtist = intent.getStringExtra("artist") ?: currentArtist
                currentAlbum = intent.getStringExtra("album") ?: currentAlbum
                val artworkUrl = intent.getStringExtra("artworkUrl")

                lastTitle = currentTitle
                lastArtist = currentArtist
                lastAlbum = currentAlbum
                lastArtworkUrl = artworkUrl

                updateMetadata(artworkUrl)
            }
            ACTION_UPDATE_STATE -> {
                isPlaying = intent.getBooleanExtra("playing", false)
                lastIsPlaying = isPlaying
                updatePlaybackState()
                updateNotification()
            }
            ACTION_UPDATE_POSITION -> {
                currentPosition = intent.getLongExtra("position", 0)
                currentDuration = intent.getLongExtra("duration", 0)
                lastPosition = currentPosition
                lastDuration = currentDuration
                updatePlaybackState()
                // Refresh the visible notification so it doesn't lag stale
                // after a service kill+recreate (cheap on Android — the
                // NotificationManager dedupes by ID).
                updateNotification()
            }
            ACTION_STOP -> {
                stopSelf()
                return START_NOT_STICKY
            }
        }

        return START_STICKY
    }

    /**
     * Reapply the last-known metadata + state after the system recreated us
     * with a null intent. Bitmap artwork doesn't survive instance recreation
     * (instance fields reset), so we re-download it from the remembered URL.
     */
    private fun restoreFromLastState() {
        val title = lastTitle ?: return  // nothing to restore — fresh process

        currentTitle = title
        lastArtist?.let { currentArtist = it }
        lastAlbum?.let { currentAlbum = it }
        currentPosition = lastPosition
        currentDuration = lastDuration
        isPlaying = lastIsPlaying

        // updateMetadata applies title/artist/album synchronously, posts the
        // notification, and kicks off async artwork download if URL non-null.
        updateMetadata(lastArtworkUrl)
        updatePlaybackState()
    }

    override fun onDestroy() {
        instance = null
        serviceScope.cancel()
        mediaSession.isActive = false
        mediaSession.release()
        super.onDestroy()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Story Playback",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows playback controls for bedtime stories"
                setShowBadge(false)
            }
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.createNotificationChannel(channel)
        }
    }

    private fun initMediaSession() {
        mediaSession = MediaSessionCompat(this, "DreamValleyMedia").apply {
            setCallback(object : MediaSessionCompat.Callback() {
                override fun onPlay() {
                    MainActivity.sendMediaAction("play")
                }
                override fun onPause() {
                    MainActivity.sendMediaAction("pause")
                }
                override fun onSeekTo(pos: Long) {
                    MainActivity.sendMediaAction("seekto", pos / 1000.0)
                }
                override fun onRewind() {
                    MainActivity.sendMediaAction("seekbackward")
                }
                override fun onFastForward() {
                    MainActivity.sendMediaAction("seekforward")
                }
                override fun onSkipToNext() {
                    MainActivity.sendMediaAction("next")
                }
                override fun onSkipToPrevious() {
                    MainActivity.sendMediaAction("previous")
                }
            })
            isActive = true
        }

        // Start as foreground immediately with a minimal notification
        startForeground(NOTIFICATION_ID, buildNotification())
    }

    private fun updateMetadata(artworkUrl: String?) {
        // Update metadata immediately without artwork
        applyMetadata()

        // Load artwork asynchronously if URL provided
        if (!artworkUrl.isNullOrEmpty() && artworkUrl != "null") {
            artworkJob?.cancel()
            artworkJob = serviceScope.launch(Dispatchers.IO) {
                try {
                    val url = if (artworkUrl.startsWith("http")) artworkUrl
                              else "https://dreamvalley.app$artworkUrl"
                    val connection = URL(url).openConnection()
                    connection.connectTimeout = 5000
                    connection.readTimeout = 5000
                    val bitmap = BitmapFactory.decodeStream(connection.getInputStream())
                    if (bitmap != null) {
                        currentArtwork = bitmap
                        withContext(Dispatchers.Main) {
                            applyMetadata()
                            updateNotification()
                        }
                    }
                } catch (e: Exception) {
                    // Failed to load artwork — app icon fallback is fine
                }
            }
        }
    }

    private fun applyMetadata() {
        val builder = MediaMetadataCompat.Builder()
            .putString(MediaMetadataCompat.METADATA_KEY_TITLE, currentTitle)
            .putString(MediaMetadataCompat.METADATA_KEY_ARTIST, currentArtist)
            .putString(MediaMetadataCompat.METADATA_KEY_ALBUM, currentAlbum)
            .putLong(MediaMetadataCompat.METADATA_KEY_DURATION, currentDuration)

        currentArtwork?.let {
            builder.putBitmap(MediaMetadataCompat.METADATA_KEY_ALBUM_ART, it)
        }

        mediaSession.setMetadata(builder.build())
        updateNotification()
    }

    private fun updatePlaybackState() {
        val stateBuilder = PlaybackStateCompat.Builder()
            .setActions(
                PlaybackStateCompat.ACTION_PLAY or
                PlaybackStateCompat.ACTION_PAUSE or
                PlaybackStateCompat.ACTION_PLAY_PAUSE or
                PlaybackStateCompat.ACTION_SEEK_TO or
                PlaybackStateCompat.ACTION_REWIND or
                PlaybackStateCompat.ACTION_FAST_FORWARD or
                PlaybackStateCompat.ACTION_SKIP_TO_PREVIOUS or
                PlaybackStateCompat.ACTION_SKIP_TO_NEXT
            )
            .setState(
                if (isPlaying) PlaybackStateCompat.STATE_PLAYING
                else PlaybackStateCompat.STATE_PAUSED,
                currentPosition,
                if (isPlaying) 1.0f else 0.0f
            )

        mediaSession.setPlaybackState(stateBuilder.build())
    }

    private fun buildNotification(): Notification {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        val contentPendingIntent = PendingIntent.getActivity(
            this, 0, launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(currentTitle)
            .setContentText(currentArtist)
            .setSubText(currentAlbum)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(contentPendingIntent)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setOngoing(isPlaying)
            .setStyle(
                androidx.media.app.NotificationCompat.MediaStyle()
                    .setMediaSession(mediaSession.sessionToken)
                    .setShowActionsInCompactView(0, 1) // show skip-back + play/pause in compact
            )

        // Add rewind 10s action (uses ACTION_REWIND so it doesn't collide with
        // SKIP_TO_PREVIOUS, which is now reserved for playlist nav).
        builder.addAction(
            NotificationCompat.Action.Builder(
                R.drawable.ic_replay_10,
                "Rewind",
                MediaButtonReceiver.buildMediaButtonPendingIntent(
                    this, PlaybackStateCompat.ACTION_REWIND
                )
            ).build()
        )

        // Add play/pause action
        if (isPlaying) {
            builder.addAction(
                NotificationCompat.Action.Builder(
                    R.drawable.ic_pause,
                    "Pause",
                    MediaButtonReceiver.buildMediaButtonPendingIntent(
                        this, PlaybackStateCompat.ACTION_PAUSE
                    )
                ).build()
            )
        } else {
            builder.addAction(
                NotificationCompat.Action.Builder(
                    R.drawable.ic_play,
                    "Play",
                    MediaButtonReceiver.buildMediaButtonPendingIntent(
                        this, PlaybackStateCompat.ACTION_PLAY
                    )
                ).build()
            )
        }

        currentArtwork?.let { builder.setLargeIcon(it) }

        return builder.build()
    }

    private fun updateNotification() {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.notify(NOTIFICATION_ID, buildNotification())
    }
}
