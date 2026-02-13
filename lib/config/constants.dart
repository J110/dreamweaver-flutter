/// App-wide constants
class AppConstants {
  // Subscription limits
  static const int freeContentPerDay = 1;
  static const int premiumContentPerDay = 5;
  static const int unlimitedContentPerDay = 999;

  static const int freeMaxFavorites = 10;
  static const int premiumMaxFavorites = 50;
  static const int unlimitedMaxFavorites = 9999;

  static const int freeMaxSaves = 5;
  static const int premiumMaxSaves = 25;
  static const int unlimitedMaxSaves = 9999;

  // Content limits
  static const int shortStoryMinWords = 200;
  static const int shortStoryMaxWords = 400;
  static const int mediumStoryMinWords = 400;
  static const int mediumStoryMaxWords = 800;
  static const int longStoryMinWords = 800;
  static const int longStoryMaxWords = 1500;

  // Audio
  static const double defaultMusicVolume = 0.25;
  static const double defaultSpeechSpeed = 0.9;
  static const int audioBitrate = 128000;

  // Age
  static const int minChildAge = 0;
  static const int maxChildAge = 14;

  // UI
  static const double cardBorderRadius = 20.0;
  static const double screenPadding = 20.0;
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Categories
  static const List<String> contentCategories = [
    'Fantasy',
    'Adventure',
    'Fairy Tales',
    'Animals',
    'Space',
    'Ocean',
    'Friendship',
    'Nature',
    'Mythology',
    'Legends',
    'Lullabies',
    'Educational',
    'Funny',
    'Magical',
    'Seasonal',
  ];

  static const List<String> storyThemes = [
    'Dreamy',
    'Adventurous',
    'Mystical',
    'Cozy',
    'Whimsical',
    'Enchanted',
    'Peaceful',
    'Playful',
  ];
}
