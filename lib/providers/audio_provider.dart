import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dreamweaver/models/content_model.dart' show Content;

/// Audio state enum
enum AudioState {
  idle,
  loading,
  playing,
  paused,
  buffering,
  error,
}

/// Audio player state class
class AudioPlayerState {
  final Content? currentContent;
  final AudioState audioState;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isBuffering;
  final bool isBackgroundMusicEnabled;
  final double musicVolume;
  final double speechSpeed;
  final String selectedVoiceId;
  final String selectedTone;
  final String? ttsTaskId;
  final String? audioUrl;

  AudioPlayerState({
    this.currentContent,
    this.audioState = AudioState.idle,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isPlaying = false,
    this.isBuffering = false,
    this.isBackgroundMusicEnabled = true,
    this.musicVolume = 0.7,
    this.speechSpeed = 1.0,
    this.selectedVoiceId = 'luna',
    this.selectedTone = 'calm',
    this.ttsTaskId,
    this.audioUrl,
  });

  AudioPlayerState copyWith({
    Content? currentContent,
    AudioState? audioState,
    Duration? position,
    Duration? duration,
    bool? isPlaying,
    bool? isBuffering,
    bool? isBackgroundMusicEnabled,
    double? musicVolume,
    double? speechSpeed,
    String? selectedVoiceId,
    String? selectedTone,
    String? ttsTaskId,
    String? audioUrl,
  }) {
    return AudioPlayerState(
      currentContent: currentContent ?? this.currentContent,
      audioState: audioState ?? this.audioState,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      isBackgroundMusicEnabled:
          isBackgroundMusicEnabled ?? this.isBackgroundMusicEnabled,
      musicVolume: musicVolume ?? this.musicVolume,
      speechSpeed: speechSpeed ?? this.speechSpeed,
      selectedVoiceId: selectedVoiceId ?? this.selectedVoiceId,
      selectedTone: selectedTone ?? this.selectedTone,
      ttsTaskId: ttsTaskId ?? this.ttsTaskId,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }
}

/// Audio player notifier
class AudioPlayerNotifier extends StateNotifier<AudioPlayerState> {
  AudioPlayerNotifier() : super(AudioPlayerState());

  /// Play content — triggers TTS generation via the backend
  Future<void> playContent(Content content) async {
    try {
      state = state.copyWith(
        currentContent: content,
        audioState: AudioState.loading,
      );

      // Simulate audio loading (in real integration, call the TTS API here)
      await Future.delayed(const Duration(milliseconds: 500));

      state = state.copyWith(
        audioState: AudioState.playing,
        isPlaying: true,
        duration: const Duration(minutes: 5), // Placeholder duration
      );
    } catch (e) {
      state = state.copyWith(audioState: AudioState.error);
    }
  }

  /// Set the audio URL after TTS generation completes
  void setAudioUrl(String url) {
    state = state.copyWith(audioUrl: url);
  }

  /// Set TTS task ID (used during polling)
  void setTtsTaskId(String taskId) {
    state = state.copyWith(ttsTaskId: taskId);
  }

  /// Update selected voice
  void setVoiceId(String voiceId) {
    state = state.copyWith(selectedVoiceId: voiceId);
  }

  /// Update selected tone
  void setTone(String tone) {
    state = state.copyWith(selectedTone: tone);
  }

  /// Pause playback
  void pause() {
    if (state.isPlaying) {
      state = state.copyWith(
        audioState: AudioState.paused,
        isPlaying: false,
      );
    }
  }

  /// Resume playback
  void resume() {
    if (!state.isPlaying && state.currentContent != null) {
      state = state.copyWith(
        audioState: AudioState.playing,
        isPlaying: true,
      );
    }
  }

  /// Stop playback
  void stop() {
    state = AudioPlayerState(
      selectedVoiceId: state.selectedVoiceId,
      selectedTone: state.selectedTone,
      musicVolume: state.musicVolume,
      speechSpeed: state.speechSpeed,
      isBackgroundMusicEnabled: state.isBackgroundMusicEnabled,
    );
  }

  /// Seek to position
  void seek(Duration position) {
    if (state.currentContent != null) {
      state = state.copyWith(position: position);
    }
  }

  /// Set music volume
  void setMusicVolume(double volume) {
    final clampedVolume = volume.clamp(0.0, 1.0);
    state = state.copyWith(musicVolume: clampedVolume);
  }

  /// Set speech speed
  void setSpeechSpeed(double speed) {
    final clampedSpeed = speed.clamp(0.5, 2.0);
    state = state.copyWith(speechSpeed: clampedSpeed);
  }

  /// Toggle background music
  void toggleBackgroundMusic() {
    state = state.copyWith(
      isBackgroundMusicEnabled: !state.isBackgroundMusicEnabled,
    );
  }
}

/// Audio player provider
final audioPlayerProvider =
    StateNotifierProvider<AudioPlayerNotifier, AudioPlayerState>((ref) {
  return AudioPlayerNotifier();
});

/// Current playback provider - provides formatted time strings
final currentPlaybackProvider = Provider<({String position, String duration})>(
  (ref) {
    final state = ref.watch(audioPlayerProvider);

    String formatDuration(Duration duration) {
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds.remainder(60);
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    return (
      position: formatDuration(state.position),
      duration: formatDuration(state.duration),
    );
  },
);
