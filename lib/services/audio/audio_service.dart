import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

/// Audio playback service for DreamWeaver
/// 
/// Handles all audio playback operations including:
/// - Play, pause, resume, stop, seek operations
/// - Speed and volume control
/// - Background audio support
/// - Audio mixing (speech + background music)
/// - Stream listeners for UI updates
class AudioService {
  late AudioPlayer _audioPlayer;
  late AudioSession _audioSession;

  /// Current background music URL (for mixing)
  String? _backgroundMusicUrl;
  
  /// Background music player for mixing
  late AudioPlayer _backgroundMusicPlayer;

  /// Initialize audio service
  /// 
  /// Sets up audio session configuration and initializes players
  Future<void> initialize() async {
    try {
      // Initialize main audio player
      _audioPlayer = AudioPlayer();
      _backgroundMusicPlayer = AudioPlayer();

      // Configure audio session for background playback
      _audioSession = await AudioSession.instance;
      await _audioSession.configure(
        const AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.duckOthers,
          avAudioSessionMode: AVAudioSessionMode.default_,
          avAudioSessionRouteSharingPolicy:
              AVAudioSessionRouteSharingPolicy.defaultPolicy,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.speech,
            flags: AndroidAudioFlags.audibilityEnforced,
            usage: AndroidAudioUsage.media,
          ),
          androidWillPauseWhenDucked: true,
        ),
      );
    } catch (e) {
      throw Exception('Failed to initialize audio service: $e');
    }
  }

  /// Play audio from URL
  /// 
  /// Parameters:
  /// - [url]: Audio URL to play
  /// - [autoPlay]: Whether to auto-play (default: true)
  /// 
  /// Throws: [DreamWeaverAudioException] if playback fails
  Future<void> play(
    String url, {
    bool autoPlay = true,
  }) async {
    try {
      await _audioPlayer.setAudioSource(
        AudioSource.uri(Uri.parse(url)),
        preload: true,
      );
      if (autoPlay) {
        await _audioPlayer.play();
      }
    } catch (e) {
      throw DreamWeaverAudioException('Failed to play audio: $e');
    }
  }

  /// Pause audio playback
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      throw DreamWeaverAudioException('Failed to pause audio: $e');
    }
  }

  /// Resume audio playback
  Future<void> resume() async {
    try {
      await _audioPlayer.play();
    } catch (e) {
      throw DreamWeaverAudioException('Failed to resume audio: $e');
    }
  }

  /// Stop audio playback and reset position
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.seek(Duration.zero);
    } catch (e) {
      throw DreamWeaverAudioException('Failed to stop audio: $e');
    }
  }

  /// Seek to specific position in audio
  /// 
  /// Parameters:
  /// - [duration]: Position to seek to
  Future<void> seek(Duration duration) async {
    try {
      await _audioPlayer.seek(duration);
    } catch (e) {
      throw DreamWeaverAudioException('Failed to seek: $e');
    }
  }

  /// Set playback speed
  /// 
  /// Parameters:
  /// - [speed]: Playback speed multiplier (e.g., 1.0 = normal, 1.5 = 1.5x speed)
  /// - Valid range: 0.5 to 2.0
  Future<void> setSpeed(double speed) async {
    try {
      if (speed < 0.5 || speed > 2.0) {
        throw DreamWeaverAudioException('Speed must be between 0.5 and 2.0');
      }
      await _audioPlayer.setSpeed(speed);
    } catch (e) {
      throw DreamWeaverAudioException('Failed to set speed: $e');
    }
  }

  /// Set playback volume
  /// 
  /// Parameters:
  /// - [volume]: Volume level (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      if (volume < 0.0 || volume > 1.0) {
        throw DreamWeaverAudioException('Volume must be between 0.0 and 1.0');
      }
      await _audioPlayer.setVolume(volume);
    } catch (e) {
      throw DreamWeaverAudioException('Failed to set volume: $e');
    }
  }

  /// Play audio with background music
  /// 
  /// Mixes speech audio with background music at specified volume levels
  /// 
  /// Parameters:
  /// - [speechUrl]: URL of speech/story audio
  /// - [musicUrl]: URL of background music
  /// - [musicVolume]: Volume of background music (0.0 to 1.0)
  /// 
  /// Note: Background music runs in parallel with speech
  Future<void> playWithBackgroundMusic({
    required String speechUrl,
    required String musicUrl,
    double musicVolume = 0.3,
  }) async {
    try {
      // Store for reference
      _backgroundMusicUrl = musicUrl;

      // Play background music at lower volume
      await _backgroundMusicPlayer.setAudioSource(
        AudioSource.uri(Uri.parse(musicUrl)),
        preload: true,
      );
      await _backgroundMusicPlayer.setVolume(musicVolume);
      
      // Start background music in loop
      await _backgroundMusicPlayer.setLoopMode(LoopMode.all);
      await _backgroundMusicPlayer.play();

      // Play speech audio on top
      await play(speechUrl, autoPlay: true);
    } catch (e) {
      throw DreamWeaverAudioException('Failed to play with background music: $e');
    }
  }

  /// Stop background music (used with mixed audio)
  Future<void> stopBackgroundMusic() async {
    try {
      await _backgroundMusicPlayer.stop();
      _backgroundMusicUrl = null;
    } catch (e) {
      throw DreamWeaverAudioException('Failed to stop background music: $e');
    }
  }

  /// Get current playback position
  Duration get position => _audioPlayer.position;

  /// Get total duration
  Duration get duration => _audioPlayer.duration ?? Duration.zero;

  /// Get current player state
  PlayerState get playerState => _audioPlayer.playerState;

  /// Stream of position updates
  /// 
  /// Use this stream to update UI with current playback position
  Stream<Duration> get positionStream => _audioPlayer.positionStream;

  /// Stream of duration updates
  /// 
  /// Use this stream to update UI with total duration
  Stream<Duration> get durationStream => _audioPlayer.durationStream;

  /// Stream of player state changes
  /// 
  /// Use this stream to update UI with play/pause/stopped states
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  /// Stream of buffering progress
  /// 
  /// Use this stream to show loading/buffering progress
  Stream<BufferingState> get bufferingStream => _audioPlayer.bufferingStateStream;

  /// Check if audio is currently playing
  bool get isPlaying => _audioPlayer.playing;

  /// Check if background music is playing
  bool get isBackgroundMusicPlaying => _backgroundMusicPlayer.playing;

  /// Dispose resources and cleanup
  Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
      await _backgroundMusicPlayer.dispose();
    } catch (e) {
      throw DreamWeaverAudioException('Failed to dispose audio service: $e');
    }
  }
}

/// Custom exception for audio service errors
class DreamWeaverAudioException implements Exception {
  final String message;

  DreamWeaverAudioException(this.message);

  @override
  String toString() => 'DreamWeaverAudioException: $message';
}
