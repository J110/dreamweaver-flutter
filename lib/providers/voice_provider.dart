import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dreamweaver/models/common/voice_model.dart';
import 'package:dreamweaver/services/api/api_client.dart';
import 'package:dreamweaver/providers/auth_provider.dart';

/// Voice selection state
class VoiceSelectionState {
  final List<Voice> availableVoices;
  final Voice selectedVoice;
  final String selectedTone;
  final List<TonePreset> availableTones;
  final bool isLoadingVoices;
  final bool isPreviewPlaying;
  final String? previewVoiceId;
  final String? ttsEngine;
  final String? error;

  VoiceSelectionState({
    this.availableVoices = const [],
    Voice? selectedVoice,
    this.selectedTone = 'calm',
    this.availableTones = const [],
    this.isLoadingVoices = false,
    this.isPreviewPlaying = false,
    this.previewVoiceId,
    this.ttsEngine,
    this.error,
  }) : selectedVoice = selectedVoice ?? Voice.defaultVoice();

  VoiceSelectionState copyWith({
    List<Voice>? availableVoices,
    Voice? selectedVoice,
    String? selectedTone,
    List<TonePreset>? availableTones,
    bool? isLoadingVoices,
    bool? isPreviewPlaying,
    String? previewVoiceId,
    String? ttsEngine,
    String? error,
  }) {
    return VoiceSelectionState(
      availableVoices: availableVoices ?? this.availableVoices,
      selectedVoice: selectedVoice ?? this.selectedVoice,
      selectedTone: selectedTone ?? this.selectedTone,
      availableTones: availableTones ?? this.availableTones,
      isLoadingVoices: isLoadingVoices ?? this.isLoadingVoices,
      isPreviewPlaying: isPreviewPlaying ?? this.isPreviewPlaying,
      previewVoiceId: previewVoiceId,
      ttsEngine: ttsEngine ?? this.ttsEngine,
      error: error,
    );
  }

  /// Filter voices by gender
  List<Voice> voicesByGender(VoiceGender? gender) {
    if (gender == null) return availableVoices;
    return availableVoices.where((v) => v.gender == gender).toList();
  }
}

/// Voice selection notifier
class VoiceSelectionNotifier extends StateNotifier<VoiceSelectionState> {
  final DreamWeaverApiClient _apiClient;

  VoiceSelectionNotifier(this._apiClient) : super(VoiceSelectionState());

  /// Get the preview URL for a voice
  String getPreviewUrl(String voiceId, {String? tone}) {
    return _apiClient.getVoicePreviewUrl(
      voiceId,
      tone: tone ?? state.selectedTone,
    );
  }

  /// Load available voices and tones from the backend
  Future<void> loadVoices() async {
    state = state.copyWith(isLoadingVoices: true, error: null);

    try {
      final voicesResponse = await _apiClient.getVoices();
      final voicesList = voicesResponse['data']?['voices'] as List? ?? [];
      final voices = voicesList
          .map((v) => Voice.fromJson(v as Map<String, dynamic>))
          .toList();

      final tonesResponse = await _apiClient.getTones();
      final tonesList = tonesResponse['data']?['tones'] as List? ?? [];
      final tones = tonesList
          .map((t) => TonePreset.fromJson(t as Map<String, dynamic>))
          .toList();

      final engineResponse = await _apiClient.getEngineInfo();
      final engine = engineResponse['engine'] as String?;

      state = state.copyWith(
        availableVoices: voices,
        availableTones: tones,
        ttsEngine: engine,
        isLoadingVoices: false,
      );

      // If the selected voice isn't in the loaded list, pick the first
      if (voices.isNotEmpty &&
          !voices.any((v) => v.id == state.selectedVoice.id)) {
        state = state.copyWith(selectedVoice: voices.first);
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingVoices: false,
        error: e.toString(),
      );
    }
  }

  /// Select a voice
  void selectVoice(Voice voice) {
    state = state.copyWith(selectedVoice: voice);
  }

  /// Select a tone
  void selectTone(String tone) {
    state = state.copyWith(selectedTone: tone);
  }

  /// Mark preview as playing for a voice
  void startPreview(String voiceId) {
    state = state.copyWith(isPreviewPlaying: true, previewVoiceId: voiceId);
  }

  /// Mark preview as stopped
  void stopPreview() {
    if (mounted) {
      state = state.copyWith(isPreviewPlaying: false);
    }
  }
}

/// Voice selection provider
final voiceSelectionProvider =
    StateNotifierProvider<VoiceSelectionNotifier, VoiceSelectionState>(
  (ref) {
    final apiClient = ref.watch(apiClientProvider);
    return VoiceSelectionNotifier(apiClient.raw);
  },
);
