# DreamWeaver Services

Complete service layer implementation for the DreamWeaver Flutter app.

## Service Structure

```
services/
├── api/
│   ├── api_client.dart          # Main API client with Dio
│   └── endpoints.dart           # API endpoint constants
├── audio/
│   ├── audio_service.dart       # Audio playback service (just_audio)
│   └── audio_cache_service.dart # Local audio caching
├── auth/
│   └── firebase_auth_service.dart # Firebase auth wrapper
├── storage/
│   └── local_cache_service.dart # Hive-based local storage
└── analytics/
    └── analytics_service.dart   # Analytics tracking (Firebase-ready)
```

## Services Overview

### API Services (`api/`)

#### `DreamWeaverApiClient`
Main HTTP client using Dio with:
- Automatic auth token injection via interceptors
- Request/response logging in debug mode
- Custom error handling with `DreamWeaverApiException`
- All backend endpoints implemented:
  - **Auth**: signUp, signIn, refreshToken
  - **Users**: getProfile, updateProfile, updatePreferences, getDailyQuota
  - **Content**: getContentList, getContentById, generateContent, searchContent
  - **Trending**: getTrending, getTrendingByCategory, getWeeklyTrending
  - **Interactions**: likeContent, unlikeContent, saveContent, unsaveContent, getUserLikes, getUserSaves
  - **Audio**: getAudioUrl, getVoices
  - **Subscriptions**: getTiers, upgradeToTier

#### `DreamWeaverEndpoints`
Static constants for all API paths with helper methods for path parameter replacement.

---

### Audio Services (`audio/`)

#### `AudioService`
Playback service using just_audio with:
- Play, pause, resume, stop, seek operations
- Speed control (0.5x to 2.0x)
- Volume control
- Background audio support
- Audio mixing (speech + background music)
- Stream getters for position, duration, player state, buffering
- `DreamWeaverAudioException` for error handling

#### `AudioCacheService`
Local audio file caching with:
- Cache audio files to device storage using path_provider
- Get cached audio paths
- Check cache status
- Clear cache (all or specific files)
- Get cache size in bytes or formatted (MB)
- Auto-purge cache when exceeding size limits
- TTL-based expiry support

---

### Auth Service (`auth/`)

#### `FirebaseAuthService`
Firebase Authentication wrapper with:
- Username/password auth (converted to username@dreamweaver.app email format)
- signUpWithEmailPassword
- signInWithEmailPassword
- signOut
- getCurrentUser
- getIdToken (for API authentication)
- authStateChanges() stream
- Password reset
- Password update
- Account deletion
- User-friendly error messages
- `FirebaseAuthServiceException` for errors

---

### Storage Service (`storage/`)

#### `LocalCacheService`
Hive-based persistent local storage with:
- **User Management**: saveUser, getUser, deleteUser
- **Content Caching**: saveContent, getContent, getAllCachedContent, deleteContent
- **Preferences**: savePreferences, getPreferences, deletePreferences
- TTL-based automatic expiry
- Cache statistics
- Clear all or selective cleanup
- `LocalCacheException` for errors

---

### Analytics Service (`analytics/`)

#### `AnalyticsService`
Analytics tracking stub ready for Firebase Analytics with:
- logEvent (custom events)
- logContentView
- logContentGenerated
- logSignUp
- logSubscriptionUpgrade
- logAudioPlayback
- logContentLiked
- logSearch
- setUserProperty
- setUserId
- setAnalyticsCollectionEnabled
- All methods are async-ready for Firebase integration
- `AnalyticsException` for errors

---

## Usage Examples

### API Client
```dart
// Initialize
final apiClient = DreamWeaverApiClient(
  baseUrl: 'https://api.dreamweaver.app',
  authToken: 'user_token_here',
);

// Sign up
final signUpResult = await apiClient.signUp(
  username: 'john_doe',
  password: 'password123',
  childAge: 5,
);

// Get trending content
final trending = await apiClient.getTrending(page: 1);

// Like content
await apiClient.likeContent('content_id_123');
```

### Audio Service
```dart
// Initialize
final audioService = AudioService();
await audioService.initialize();

// Play audio
await audioService.play('https://audio.url/story.mp3');

// Listen to position changes
audioService.positionStream.listen((position) {
  print('Position: ${position.inSeconds}s');
});

// Play with background music
await audioService.playWithBackgroundMusic(
  speechUrl: 'https://audio.url/story.mp3',
  musicUrl: 'https://audio.url/music.mp3',
  musicVolume: 0.3,
);
```

### Audio Cache Service
```dart
// Initialize
final cacheService = AudioCacheService();
await cacheService.initialize();

// Cache audio
await cacheService.cacheAudio('content_123', audioBytes);

// Check if cached
if (await cacheService.isCached('content_123')) {
  final cachedPath = await cacheService.getCachedAudio('content_123');
}

// Get cache size
final size = await cacheService.getCacheSizeFormatted();
```

### Firebase Auth Service
```dart
// Initialize
final authService = FirebaseAuthService();
authService.initialize();

// Sign up
final user = await authService.signUpWithEmailPassword(
  username: 'john_doe',
  password: 'password123',
);

// Get ID token for API
final token = await authService.getIdToken();

// Listen to auth state
authService.authStateChanges().listen((user) {
  if (user != null) {
    print('User logged in: ${user.email}');
  }
});
```

### Local Cache Service
```dart
// Initialize
final cacheService = LocalCacheService();
await cacheService.initialize();

// Save user
await cacheService.saveUser({
  'id': '123',
  'name': 'John',
  'age': 5,
});

// Get user with 24-hour expiry
final user = await cacheService.getUser(
  maxAgeDuration: Duration(hours: 24),
);

// Save content
await cacheService.saveContent('story_1', {
  'title': 'Bedtime Story',
  'duration': 300,
});
```

### Analytics Service
```dart
// Initialize
final analyticsService = AnalyticsService();
await analyticsService.initialize();

// Set user ID
await analyticsService.setUserId('user_123');

// Log sign up
await analyticsService.logSignUp(
  method: 'email',
  childAge: 5,
  source: 'organic',
);

// Log content view
await analyticsService.logContentView(
  contentId: 'story_123',
  contentTitle: 'Sleeping Beauty',
  contentType: 'story',
);

// Log custom event
await analyticsService.logEvent(
  'button_clicked',
  {'button_name': 'play', 'screen': 'content_detail'},
);
```

## Error Handling

Each service has custom exceptions for proper error handling:

- `DreamWeaverApiException` - API client errors
- `DreamWeaverAudioException` - Audio service errors
- `AudioCacheException` - Audio cache errors
- `FirebaseAuthServiceException` - Authentication errors
- `LocalCacheException` - Local storage errors
- `AnalyticsException` - Analytics errors

Example:
```dart
try {
  await apiClient.getContentById('invalid_id');
} on DreamWeaverApiException catch (e) {
  print('API Error: ${e.message}');
  print('Status Code: ${e.statusCode}');
}
```

## Dependencies

These services require the following packages in `pubspec.yaml`:
- `dio` - HTTP client
- `just_audio` - Audio playback
- `audio_session` - Audio session management
- `path_provider` - File system paths
- `hive_flutter` - Local storage
- `firebase_auth` - Authentication
- `firebase_analytics` - Analytics (future integration)

## Notes

- All services use async/await for non-blocking operations
- Services are designed to be Singleton instances in the app
- Authentication token is injected automatically in all API requests
- Local cache supports TTL-based expiry for automatic cleanup
- Analytics is Firebase-ready with stub implementation in debug mode
