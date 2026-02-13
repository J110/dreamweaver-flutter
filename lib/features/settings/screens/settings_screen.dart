import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dreamweaver/config/theme.dart';
import 'package:dreamweaver/widgets/common/dream_app_bar.dart';
import 'package:dreamweaver/providers/voice_provider.dart';
import 'package:dreamweaver/providers/audio_provider.dart';
import 'package:dreamweaver/features/customization/screens/voice_selection_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceState = ref.watch(voiceSelectionProvider);
    final audioState = ref.watch(audioPlayerProvider);

    return Scaffold(
      appBar: DreamAppBar(
        title: 'Settings',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Account section
              _buildSection(
                context,
                'Account',
                [
                  _buildSettingsTile(
                    context,
                    'Username',
                    'Luna\'s Parent',
                    Icons.person,
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    context,
                    'Child Age',
                    '5 years old',
                    Icons.child_care,
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    context,
                    'Subscription',
                    'Premium',
                    Icons.star,
                    onTap: () {},
                  ),
                ],
              ),

              // Playback section
              _buildSection(
                context,
                'Playback',
                [
                  _buildSettingsTile(
                    context,
                    'Default Voice',
                    '${voiceState.selectedVoice.name} (${voiceState.selectedVoice.gender.displayName})',
                    Icons.record_voice_over,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const VoiceSelectionScreen(),
                        ),
                      );
                    },
                  ),
                  _buildToneSettingsTile(context, ref, voiceState),
                  _buildSliderTile(
                    context,
                    'Speech Speed',
                    '${audioState.speechSpeed.toStringAsFixed(1)}x',
                    Icons.speed,
                    audioState.speechSpeed,
                    min: 0.5,
                    max: 2.0,
                    divisions: 6,
                    onChanged: (value) {
                      ref.read(audioPlayerProvider.notifier).setSpeechSpeed(value);
                    },
                  ),
                  _buildToggleTile(
                    context,
                    'Background Music',
                    'Soft ambient music during playback',
                    audioState.isBackgroundMusicEnabled,
                    onChanged: (value) {
                      ref.read(audioPlayerProvider.notifier).toggleBackgroundMusic();
                    },
                  ),
                  _buildSliderTile(
                    context,
                    'Music Volume',
                    '${(audioState.musicVolume * 100).round()}%',
                    Icons.volume_up,
                    audioState.musicVolume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    onChanged: (value) {
                      ref.read(audioPlayerProvider.notifier).setMusicVolume(value);
                    },
                  ),
                ],
              ),

              // Content Preferences section
              _buildSection(
                context,
                'Content Preferences',
                [
                  _buildSettingsTile(
                    context,
                    'Preferred Categories',
                    'Fantasy, Animals, Adventure',
                    Icons.category,
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    context,
                    'Content Types',
                    'Stories, Poems, Songs',
                    Icons.auto_awesome,
                    onTap: () {},
                  ),
                  _buildToggleTile(
                    context,
                    'Explicit Content Filter',
                    'Restrict mature content',
                    true,
                    onChanged: (value) {},
                  ),
                ],
              ),

              // App section
              _buildSection(
                context,
                'App',
                [
                  _buildToggleTile(
                    context,
                    'Notifications',
                    'Daily story recommendations',
                    true,
                    onChanged: (value) {},
                  ),
                  _buildSettingsTile(
                    context,
                    'Cache Size',
                    '245 MB',
                    Icons.storage,
                    onTap: () {},
                  ),
                  _buildButtonTile(
                    context,
                    'Clear Cache',
                    Icons.delete,
                    Colors.orange,
                    onTap: () {
                      _showClearCacheDialog(context);
                    },
                  ),
                  _buildSettingsTile(
                    context,
                    'App Version',
                    '1.0.0',
                    Icons.info,
                    onTap: null,
                  ),
                  _buildButtonTile(
                    context,
                    'Privacy Policy',
                    Icons.privacy_tip,
                    Colors.white,
                    onTap: () {},
                  ),
                  _buildButtonTile(
                    context,
                    'Terms of Service',
                    Icons.description,
                    Colors.white,
                    onTap: () {},
                  ),
                ],
              ),

              // Danger Zone
              _buildSection(
                context,
                'Danger Zone',
                [
                  _buildButtonTile(
                    context,
                    'Logout',
                    Icons.logout,
                    Colors.amber,
                    onTap: () {
                      _showLogoutDialog(context);
                    },
                  ),
                  _buildButtonTile(
                    context,
                    'Delete Account',
                    Icons.delete_forever,
                    Colors.red,
                    onTap: () {
                      _showDeleteAccountDialog(context);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToneSettingsTile(
    BuildContext context,
    WidgetRef ref,
    VoiceSelectionState voiceState,
  ) {
    final toneIcons = <String, IconData>{
      'calm': Icons.nights_stay,
      'relaxing': Icons.spa,
      'dramatic': Icons.theater_comedy,
      'energetic': Icons.bolt,
      'neutral': Icons.circle_outlined,
    };

    final currentTone = voiceState.selectedTone;
    final displayTone = currentTone[0].toUpperCase() + currentTone.substring(1);
    final icon = toneIcons[currentTone] ?? Icons.music_note;

    return ListTile(
      leading: Icon(icon, color: Colors.white.withOpacity(0.7)),
      title: const Text(
        'Narration Tone',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        displayTone,
        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.white.withOpacity(0.5),
      ),
      onTap: () {
        _showTonePickerDialog(context, ref, voiceState);
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  void _showTonePickerDialog(
    BuildContext context,
    WidgetRef ref,
    VoiceSelectionState voiceState,
  ) {
    final toneIcons = <String, IconData>{
      'calm': Icons.nights_stay,
      'relaxing': Icons.spa,
      'dramatic': Icons.theater_comedy,
      'energetic': Icons.bolt,
      'neutral': Icons.circle_outlined,
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DreamTheme.cardDark,
        title: const Text(
          'Narration Tone',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: voiceState.availableTones.map((tone) {
            final isSelected = voiceState.selectedTone == tone.name;
            final icon = toneIcons[tone.name] ?? Icons.music_note;
            return ListTile(
              leading: Icon(
                icon,
                color: isSelected ? DreamTheme.starYellow : Colors.white.withOpacity(0.5),
              ),
              title: Text(
                tone.name[0].toUpperCase() + tone.name.substring(1),
                style: TextStyle(
                  color: isSelected ? DreamTheme.starYellow : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                tone.description,
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: DreamTheme.starYellow, size: 20)
                  : null,
              onTap: () {
                ref.read(voiceSelectionProvider.notifier).selectTone(tone.name);
                ref.read(audioPlayerProvider.notifier).setTone(tone.name);
                Navigator.of(context).pop();
              },
              dense: true,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: DreamTheme.starYellow,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Column(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1)
                Divider(
                  color: Colors.white.withOpacity(0.1),
                  height: 0,
                ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white.withOpacity(0.7),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 12,
        ),
      ),
      trailing: onTap != null
          ? Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.white.withOpacity(0.5),
            )
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildToggleTile(
    BuildContext context,
    String title,
    String subtitle,
    bool value, {
    required Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Icon(
        Icons.toggle_on,
        color: Colors.white.withOpacity(0.7),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 12,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: DreamTheme.primaryPurple,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildSliderTile(
    BuildContext context,
    String title,
    String valueLabel,
    IconData icon,
    double value, {
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white.withOpacity(0.7)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                valueLabel,
                style: TextStyle(
                  color: DreamTheme.primaryPurple,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildButtonTile(
    BuildContext context,
    String title,
    IconData icon,
    Color color, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.white.withOpacity(0.5),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DreamTheme.cardDark,
        title: const Text(
          'Clear Cache?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'This will delete downloaded content but won\'t affect your account.',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DreamTheme.cardDark,
        title: const Text(
          'Logout?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'You\'ll need to login again to access your dreams.',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Perform logout
              Navigator.of(context).pop();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.amber)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DreamTheme.cardDark,
        title: const Text(
          'Delete Account?',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          'This action is permanent. All your data will be deleted.',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Perform account deletion
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
