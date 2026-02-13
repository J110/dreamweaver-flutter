# DreamWeaver Flutter App - Code Reference Guide

## Overview
Complete implementation of 21 screens and widgets for the DreamWeaver bedtime story app. All components use Flutter Riverpod for state management and DreamTheme for consistent styling.

---

## Player Module (4 files)

### PlayerScreen
**Path**: `lib/features/player/screens/player_screen.dart`
**Type**: ConsumerStatefulWidget
**Key Features**:
- Full-screen audio player interface
- Animated starfield background
- Hero animation support for album art
- Scrollable text content overlay
- Voice speed and volume controls
- Background music selection

**Key Methods**:
```dart
- _buildStarfield() // Creates animated starfield
- _showText toggle state management
```

**Provider Dependencies**:
- `audioPlayerProvider` - Audio state management

**UI Elements**:
- AppBar with favorite button
- Album art with glow shadow (300x300)
- Progress bar with time labels
- Playback controls row
- Bottom control bar with toggles

---

### PlaybackControls
**Path**: `lib/features/player/widgets/playback_controls.dart`
**Type**: StatefulWidget
**Props**:
- `isPlaying` - Current playback state
- `hasPlaylist` - Show prev/next buttons
- `repeatMode` - 0: off, 1: all, 2: one
- Callbacks: `onPlayPause`, `onNext`, `onPrevious`, `onRepeatChanged`

**Features**:
- Animated play/pause icon (80x80)
- 15s skip buttons
- Optional playlist navigation
- Repeat mode toggle

---

### ProgressBar
**Path**: `lib/features/player/widgets/progress_bar.dart`
**Type**: StatefulWidget
**Props**:
- `currentPosition` - Current playback position
- `totalDuration` - Total content duration
- `bufferedPosition` - Buffered content position
- `onSeek` - Callback when user seeks

**Features**:
- Gradient slider track
- Glowing thumb
- Dragging state management
- Time format: MM:SS or HH:MM:SS
- Buffered indicator

---

### BackgroundMusicToggle
**Path**: `lib/features/player/widgets/background_music_toggle.dart`
**Type**: StatefulWidget
**Props**:
- `isEnabled` - Music on/off
- `volume` - Music volume (0-1)
- `onToggle` - Enable/disable callback
- `onVolumeChanged` - Volume change callback

**Features**:
- Toggle button with icon color feedback
- Volume slider (expands when enabled)
- Music type chips (Ambient, Lullaby, Nature, Rain)
- Expandable interface

---

## Content Module (4 files)

### ContentDetailScreen
**Path**: `lib/features/content/screens/content_detail_screen.dart`
**Type**: ConsumerWidget
**Props**:
- `contentId` - Content identifier
- `heroTag` - Optional hero animation tag

**Features**:
- Hero animation on album art
- Content metadata display
- Category chips
- Age suitability badge
- Like/Save buttons
- Action buttons (Play, Customize & Play)
- Text preview with read more
- Similar content carousel

**Key Methods**:
- `_getMockContent()` - Returns mock content data

---

### ContentLibraryScreen
**Path**: `lib/features/content/screens/content_library_screen.dart`
**Type**: ConsumerStatefulWidget
**State Variables**:
- `_selectedFilter` - Currently selected filter
- `_selectedSort` - Sort method
- `_currentPage` - Pagination page
- `_scrollController` - Infinite scroll control

**Features**:
- Search bar with input
- Filter chips: All, Stories, Poems, Songs
- Sort dropdown: Newest, Most Popular, Duration
- Infinite scroll pagination
- 2-column responsive grid
- Empty state handling

---

### CategoryBrowseScreen
**Path**: `lib/features/content/screens/category_browse_screen.dart`
**Type**: ConsumerWidget
**Props**:
- `categoryName` - Category title
- `categoryDescription` - Optional category info

**Features**:
- Category description section
- Filtered content grid
- Custom scrolling with SliverAppBar

---

### AlbumArtDisplay
**Path**: `lib/features/content/widgets/album_art_display.dart`
**Type**: StatelessWidget
**Props**:
- `url` - Image URL
- `contentType` - 'story', 'poem', 'song'
- `size` - Optional custom size (default 200)
- `hasGlow` - Enable glow shadow

**Features**:
- CachedNetworkImage
- Content type gradient placeholder
- Type-specific icons
- Rounded corners (16px)
- Optional glow shadow

---

## Customization Module (4 files)

### StoryCustomizationScreen
**Path**: `lib/features/customization/screens/story_customization_screen.dart`
**Type**: ConsumerStatefulWidget
**State Variables**:
- `_selectedContentType` - Story/Poem/Song/Mixed
- `_selectedLength` - Short/Medium/Long
- `_selectedMood` - Theme selection
- `_selectedCategory` - Category selection
- `_includePoems`, `_includeSongs` - Content mix
- `_includeQA`, `_includeMiniGames` - Features

**Features**:
- Content type selector
- Length slider with moon phases
- Mood/theme grid
- Category selector
- Content mix toggles
- Interactive features toggles
- Quota indicator
- Magic generate button

**Available Options**:
- Moods: Adventure, Calm, Mystery, Magical, Heroic, Whimsical
- Categories: Fantasy, Animals, Space, Underwater, Dinosaurs, Fairy Tales
- Lengths: Short (2-3 min), Medium (5-7 min), Long (10-15 min)

---

### VoiceSelectionScreen
**Path**: `lib/features/customization/screens/voice_selection_screen.dart`
**Type**: ConsumerStatefulWidget
**State Variables**:
- `_selectedVoice` - Current voice selection
- `_isPreviewPlaying` - Preview playback state

**Features**:
- 6 voice cards in 2-column grid
- Voice info: name, gender, description, accent
- Preview button for each voice
- Selection checkmark indicator
- Gender icons

**Available Voices**:
1. Luna - Female, American, Soft and dreamy
2. Orion - Male, British, Deep and calming
3. Aurora - Female, American, Warm and nurturing
4. Zephyr - Male, Australian, Gentle and soothing
5. Nova - Female, Canadian, Playful and energetic
6. Echo - Male, American, Clear and pleasant

---

### LengthSlider
**Path**: `lib/features/customization/widgets/length_slider.dart`
**Type**: StatefulWidget
**Props**:
- `selectedLength` - Short/Medium/Long
- `onChanged` - Selection change callback

**Features**:
- Slider with 3 stops
- Moon phase icons (crescent, half, full)
- Duration labels under each stop
- Selection highlighting
- Tap to select boxes

---

### ContentTypeSelector
**Path**: `lib/features/customization/widgets/content_type_selector.dart`
**Type**: StatelessWidget
**Props**:
- `selected` - Currently selected type
- `onChanged` - Selection change callback

**Features**:
- 4 selectable cards
- Icons and descriptions
- Animated selection with glow
- Type-specific icons and colors

---

## Subscription Module (2 files)

### SubscriptionScreen
**Path**: `lib/features/subscription/screens/subscription_screen.dart`
**Type**: ConsumerWidget
**Features**:
- 3 tier cards (Free, Premium, Unlimited)
- Horizontal scrollable tier list
- Feature comparison table
- FAQ section with expandable items
- Upgrade button per tier

**Tiers**:
1. **Free**: $0/month
   - 1 story/day, 10 favorites, 3 basic voices

2. **Premium**: $9.99/month (Most Popular)
   - 5 stories/day, 50 favorites, all voices, background music, ad-free

3. **Unlimited**: $19.99/month
   - Unlimited stories, unlimited favorites, premium music, offline, family sharing (5 kids)

---

### TierComparisonCard
**Path**: `lib/features/subscription/widgets/tier_comparison_card.dart`
**Type**: StatelessWidget
**Props**:
- `name` - Tier name
- `price` - Price with currency
- `period` - Billing period
- `isCurrent` - If this is active plan
- `isPopular` - If premium/popular tier
- `features` - List of features
- `onUpgrade` - Upgrade callback

**Features**:
- Price and period display
- Badge system (Most Popular, Current Plan)
- Feature list with checkmarks
- Contextual button (Upgrade/Current Plan)
- Border and color changes per tier

---

## Search Module (1 file)

### SearchScreen
**Path**: `lib/features/search/screens/search_screen.dart`
**Type**: ConsumerStatefulWidget
**State Variables**:
- `_searchController` - Search input
- `_recentSearches` - Local history (max 5)
- `_selectedTypeFilter` - Type filter
- `_searchResults` - Search results list
- `_isSearching` - Loading state

**Features**:
- Auto-focus search bar
- Type filter chips
- Recent searches display
- Search results grid
- Empty state: "Search for stories, poems, and songs"
- Clear button in search field
- Loading indicator

**Filter Options**: All, Stories, Poems, Songs

---

## Settings Module (1 file)

### SettingsScreen
**Path**: `lib/features/settings/screens/settings_screen.dart`
**Type**: ConsumerWidget
**Sections**:

1. **Account**
   - Username
   - Child age
   - Subscription status

2. **Playback**
   - Default voice selection
   - Speech speed
   - Background music toggle
   - Music volume

3. **Content Preferences**
   - Preferred categories
   - Content types
   - Explicit content filter

4. **App**
   - Notifications toggle
   - Cache size
   - Clear cache action
   - App version
   - Privacy policy link
   - Terms of service link

5. **Danger Zone**
   - Logout (confirmation dialog)
   - Delete account (confirmation dialog)

**Tile Types**:
- `_buildSettingsTile()` - Navigation setting
- `_buildToggleTile()` - Toggle setting
- `_buildButtonTile()` - Action button

---

## Shared Widgets Module (5 files)

### DreamAppBar
**Path**: `lib/widgets/common/dream_app_bar.dart`
**Type**: AppBar (implements PreferredSizeWidget)
**Props**:
- `title` - App bar title
- `leading` - Optional leading widget
- `actions` - Optional action buttons
- `centerTitle` - Center title flag

**Features**:
- Transparent background
- Quicksand font for title
- Gradient divider line (purple to accent)
- Flexible leading/trailing actions

---

### BottomNav
**Path**: `lib/widgets/common/bottom_nav.dart`
**Type**: StatefulWidget
**Props**:
- `currentIndex` - Active nav index
- `onTap` - Item selection callback

**Items**:
1. Home
2. Explore
3. Favorites
4. Profile

**Features**:
- Glass-morphism background
- Animated scale on selection
- Glow effect on active item
- Custom icon styling
- Smooth transitions

---

### LoadingIndicator
**Path**: `lib/widgets/common/loading_indicator.dart`
**Type**: StatefulWidget
**Props**:
- `size` - LoadingSize.small/medium/large
- `message` - Optional custom message

**Sizes**:
- Small: 40px
- Medium: 80px
- Large: 120px

**Features**:
- Animated moon with bob motion
- Orbiting stars animation
- "Weaving your dream..." text
- CustomPaint for starfield
- Uses dual AnimationControllers

---

### EmptyState
**Path**: `lib/widgets/common/empty_state.dart`
**Type**: StatefulWidget
**Props**:
- `icon` - IconData for display
- `title` - Empty state title
- `description` - Empty state description
- `actionLabel` - Optional action button text
- `onAction` - Optional action callback

**Features**:
- Icon with glow effect
- Fade and scale-in animation
- Optional action button
- Centered layout
- Reusable across app

---

### ContentTypeBadge
**Path**: `lib/widgets/common/content_type_badge.dart`
**Type**: StatelessWidget
**Props**:
- `type` - 'story', 'poem', 'song'

**Type Styles**:
- **Story**: Purple (DreamTheme.primary), book icon
- **Poem**: Pink, feather icon
- **Song**: Teal, music note icon

**Features**:
- Pill-shaped badge (12px radius)
- Type-specific colors and icons
- Compact size for card displays

---

## Theme Constants

All colors from `config/theme.dart`:
```dart
class DreamTheme {
  static const Color primary = DreamPurple;        // Deep purple
  static const Color secondary = MagicPurple;       // Lighter purple
  static const Color accent = StardustAqua;         // Bright accent
  static const Color primaryDark = NightSky;        // Very dark purple
}
```

Default Styling:
- **Font**: Quicksand (dreamy aesthetic)
- **Border Radius**: 12-16px (rounded)
- **Shadow**: Glow effects on interactive elements
- **Animation Duration**: 300-600ms

---

## Provider Dependencies

Screens expecting these providers:
- `audioPlayerProvider` - Player state
- Content providers (to be implemented)
- User/subscription provider
- Settings provider

---

## Navigation Structure

Recommended routing:
```
Home/
├── PlayerScreen (contentId)
├── ContentLibraryScreen
│   ├── ContentDetailScreen (contentId)
│   └── CategoryBrowseScreen (category)
├── SearchScreen
│   └── ContentDetailScreen (contentId)
├── StoryCustomizationScreen
│   └── VoiceSelectionScreen
├── SubscriptionScreen
└── SettingsScreen
```

---

## Implementation Notes

1. **Mock Data**: All screens include `_getMockContent()` or similar for testing
2. **Error Handling**: Built-in empty states and loading indicators
3. **Responsiveness**: SafeArea and responsive grids throughout
4. **Accessibility**: Proper icon sizes (16px, 20px, 24px, 28px, 32px)
5. **Animations**: Smooth transitions and micro-interactions
6. **Theme Consistency**: All files use DreamTheme colors

---

## Next Steps for Integration

1. Connect providers to actual state management
2. Implement API calls for content loading
3. Connect audio player functionality
4. Implement navigation routes
5. Add error handling and retry logic
6. Connect payment processing for subscriptions
7. Implement voice selection and playback
8. Add analytics and tracking

