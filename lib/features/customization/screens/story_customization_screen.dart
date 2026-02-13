import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dreamweaver/config/theme.dart';
import 'package:dreamweaver/features/customization/widgets/length_slider.dart';
import 'package:dreamweaver/features/customization/widgets/content_type_selector.dart';

class StoryCustomizationScreen extends ConsumerStatefulWidget {
  const StoryCustomizationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StoryCustomizationScreen> createState() =>
      _StoryCustomizationScreenState();
}

class _StoryCustomizationScreenState
    extends ConsumerState<StoryCustomizationScreen> {
  String _selectedContentType = 'Story';
  String _selectedLength = 'Medium';
  String _selectedMood = 'Adventure';
  String _selectedCategory = 'Fantasy';
  bool _includePoems = true;
  bool _includeSongs = true;
  bool _includeQA = false;
  bool _includeMiniGames = false;

  final List<String> _moods = [
    'Adventure',
    'Calm',
    'Mystery',
    'Magical',
    'Heroic',
    'Whimsical',
  ];

  final List<String> _categories = [
    'Fantasy',
    'Animals',
    'Space',
    'Underwater',
    'Dinosaurs',
    'Fairy Tales',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Craft Your Dream Story'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content type selector
              _buildSection(
                title: 'Content Type',
                child: ContentTypeSelector(
                  selected: _selectedContentType,
                  onChanged: (type) {
                    setState(() => _selectedContentType = type);
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Story length
              _buildSection(
                title: 'Story Length',
                child: LengthSlider(
                  selectedLength: _selectedLength,
                  onChanged: (length) {
                    setState(() => _selectedLength = length);
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Theme/Mood selector
              _buildSection(
                title: 'Theme & Mood',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _moods.map((mood) {
                    return _buildMoodCard(mood);
                  }).toList(),
                ),
              ),

              const SizedBox(height: 32),

              // Category selector
              _buildSection(
                title: 'Category',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _categories.map((category) {
                    return _buildCategoryChip(category);
                  }).toList(),
                ),
              ),

              const SizedBox(height: 32),

              // Toggle options
              _buildSection(
                title: 'Content Mix',
                child: Column(
                  children: [
                    _buildToggleOption(
                      'Include poems in story?',
                      _includePoems,
                      (value) {
                        setState(() => _includePoems = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildToggleOption(
                      'Include songs in story?',
                      _includeSongs,
                      (value) {
                        setState(() => _includeSongs = value);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Interactive features
              _buildSection(
                title: 'Interactive Features',
                child: Column(
                  children: [
                    _buildToggleOption(
                      'Interactive Mode - for awake time fun!',
                      _includeQA,
                      (value) {
                        setState(() => _includeQA = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildToggleOption(
                      'Play Mode - for quality time together!',
                      _includeMiniGames,
                      (value) {
                        setState(() => _includeMiniGames = value);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Quota remaining
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DreamTheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: DreamTheme.accent.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: DreamTheme.accent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You have 3 stories remaining today',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Generate button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Generate story
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Generating your dream story...'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DreamTheme.accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.auto_awesome),
                      SizedBox(width: 8),
                      Text(
                        'Generate My Story',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildMoodCard(String mood) {
    final isSelected = _selectedMood == mood;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedMood = mood);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? DreamTheme.accent
              : DreamTheme.primary.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: DreamTheme.accent)
              : Border.all(color: Colors.transparent),
        ),
        child: Text(
          mood,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return FilterChip(
      label: Text(category),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedCategory = category);
        }
      },
      backgroundColor: DreamTheme.primary.withOpacity(0.2),
      selectedColor: DreamTheme.accent.withOpacity(0.3),
      labelStyle: TextStyle(
        color: isSelected ? DreamTheme.accent : Colors.white,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
      ),
    );
  }

  Widget _buildToggleOption(
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: DreamTheme.accent,
        ),
      ],
    );
  }
}
