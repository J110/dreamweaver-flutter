import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dreamweaver/config/theme.dart';
import 'package:dreamweaver/models/common/voice_model.dart';
import 'package:dreamweaver/providers/voice_provider.dart';
import 'package:dreamweaver/providers/audio_provider.dart';
import 'package:dreamweaver/services/audio/audio_service.dart';

class VoiceSelectionScreen extends ConsumerStatefulWidget {
  const VoiceSelectionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<VoiceSelectionScreen> createState() =>
      _VoiceSelectionScreenState();
}

class _VoiceSelectionScreenState extends ConsumerState<VoiceSelectionScreen> {
  VoiceGender? _genderFilter;
  AudioService? _previewPlayer;

  @override
  void initState() {
    super.initState();
    // Load voices from backend on first build
    Future.microtask(() {
      ref.read(voiceSelectionProvider.notifier).loadVoices();
    });
  }

  @override
  void dispose() {
    _previewPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceSelectionProvider);
    final filteredVoices = voiceState.voicesByGender(_genderFilter);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Select Voice'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: Navigator.of(context).pop,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Gender filter chips
            _buildGenderFilter(context),

            // Tone selector
            if (voiceState.availableTones.isNotEmpty)
              _buildToneSelector(context, voiceState),

            // Engine indicator
            if (voiceState.ttsEngine != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.graphic_eq,
                      size: 14,
                      color: Colors.white.withOpacity(0.4),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Engine: ${voiceState.ttsEngine}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Voice grid
            Expanded(
              child: _buildVoiceGrid(context, voiceState, filteredVoices),
            ),

            // Confirm button
            _buildConfirmButton(context, voiceState),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderFilter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          _buildFilterChip(
            context,
            label: 'All',
            icon: Icons.people,
            isSelected: _genderFilter == null,
            onTap: () => setState(() => _genderFilter = null),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: 'Female',
            icon: Icons.female,
            isSelected: _genderFilter == VoiceGender.female,
            onTap: () => setState(() => _genderFilter = VoiceGender.female),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: 'Male',
            icon: Icons.male,
            isSelected: _genderFilter == VoiceGender.male,
            onTap: () => setState(() => _genderFilter = VoiceGender.male),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected
              ? DreamTheme.primaryPurple.withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: isSelected
                ? DreamTheme.primaryPurple
                : Colors.white.withOpacity(0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? DreamTheme.primaryPurple : Colors.white.withOpacity(0.6)),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isSelected ? DreamTheme.primaryPurple : Colors.white.withOpacity(0.7),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToneSelector(BuildContext context, VoiceSelectionState voiceState) {
    final toneIcons = <String, IconData>{
      'calm': Icons.nights_stay,
      'relaxing': Icons.spa,
      'dramatic': Icons.theater_comedy,
      'energetic': Icons.bolt,
      'neutral': Icons.circle_outlined,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Narration Tone',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: voiceState.availableTones.map((tone) {
                final isSelected = voiceState.selectedTone == tone.name;
                final icon = toneIcons[tone.name] ?? Icons.music_note;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      ref.read(voiceSelectionProvider.notifier).selectTone(tone.name);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isSelected
                            ? DreamTheme.starYellow.withOpacity(0.2)
                            : Colors.white.withOpacity(0.05),
                        border: Border.all(
                          color: isSelected
                              ? DreamTheme.starYellow
                              : Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: 14,
                            color: isSelected ? DreamTheme.starYellow : Colors.white.withOpacity(0.5),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            tone.name[0].toUpperCase() + tone.name.substring(1),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: isSelected ? DreamTheme.starYellow : Colors.white.withOpacity(0.6),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceGrid(
    BuildContext context,
    VoiceSelectionState voiceState,
    List<Voice> filteredVoices,
  ) {
    if (voiceState.isLoadingVoices) {
      return const Center(
        child: CircularProgressIndicator(color: DreamTheme.primaryPurple),
      );
    }

    if (voiceState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.withOpacity(0.7), size: 48),
            const SizedBox(height: 12),
            Text(
              'Failed to load voices',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                ref.read(voiceSelectionProvider.notifier).loadVoices();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (filteredVoices.isEmpty) {
      return Center(
        child: Text(
          'No voices available',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.5),
              ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: filteredVoices.length,
      itemBuilder: (context, index) {
        final voice = filteredVoices[index];
        return _buildVoiceCard(context, voice, voiceState);
      },
    );
  }

  Widget _buildVoiceCard(
    BuildContext context,
    Voice voice,
    VoiceSelectionState voiceState,
  ) {
    final isSelected = voiceState.selectedVoice.id == voice.id;
    final isPreviewingThis =
        voiceState.isPreviewPlaying && voiceState.previewVoiceId == voice.id;

    return GestureDetector(
      onTap: () {
        ref.read(voiceSelectionProvider.notifier).selectVoice(voice);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? DreamTheme.primaryPurple
                : Colors.white.withOpacity(0.12),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? DreamTheme.primaryPurple.withOpacity(0.15)
              : Colors.white.withOpacity(0.04),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Voice name + gender icon
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSelected)
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: DreamTheme.primaryPurple,
                        ),
                        child: const Icon(Icons.check, size: 12, color: Colors.white),
                      ),
                    Flexible(
                      child: Text(
                        voice.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      voice.gender == VoiceGender.female
                          ? Icons.female
                          : voice.gender == VoiceGender.male
                              ? Icons.male
                              : Icons.circle_outlined,
                      size: 14,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      voice.gender.displayName,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ],
            ),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                voice.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 11,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Recommended-for chips
            if (voice.recommendedFor.isNotEmpty)
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 4,
                children: voice.recommendedFor.take(3).map((type) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: DreamTheme.magicTeal.withOpacity(0.15),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        color: DreamTheme.magicTeal,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),

            // Preview button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isPreviewingThis
                    ? null
                    : () => _playPreview(voice.id, voiceState.selectedTone),
                icon: isPreviewingThis
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: DreamTheme.starYellow,
                        ),
                      )
                    : const Icon(Icons.play_arrow, size: 16),
                label: Text(isPreviewingThis ? 'Playing...' : 'Preview'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DreamTheme.primaryPurple.withOpacity(0.25),
                  foregroundColor: DreamTheme.starYellow,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  textStyle: const TextStyle(fontSize: 12),
                  minimumSize: const Size(0, 32),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context, VoiceSelectionState voiceState) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // Persist selection to audio provider
            final notifier = ref.read(audioPlayerProvider.notifier);
            notifier.setVoiceId(voiceState.selectedVoice.id);
            notifier.setTone(voiceState.selectedTone);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: DreamTheme.primaryPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            'Confirm — ${voiceState.selectedVoice.name}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Future<void> _playPreview(String voiceId, String tone) async {
    final notifier = ref.read(voiceSelectionProvider.notifier);
    notifier.startPreview(voiceId);

    try {
      final url = notifier.getPreviewUrl(voiceId, tone: tone);

      _previewPlayer?.dispose();
      _previewPlayer = AudioService();
      await _previewPlayer!.initialize();
      await _previewPlayer!.play(url);

      // Stop preview state after playback (~5 seconds for a preview clip)
      await Future.delayed(const Duration(seconds: 5));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Preview unavailable: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      notifier.stopPreview();
    }
  }
}
