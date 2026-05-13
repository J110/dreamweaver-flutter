import 'package:hive_flutter/hive_flutter.dart';

/// Local cache service using Hive for DreamWeaver
/// 
/// Provides fast, persistent local storage for:
/// - User data and preferences
/// - Content metadata
/// - Cache data with optional TTL-based expiry
class LocalCacheService {
  static const String _userBoxName = 'user_box';
  static const String _contentBoxName = 'content_box';
  static const String _preferencesBoxName = 'preferences_box';

  late Box<Map<String, dynamic>> _userBox;
  late Box<Map<String, dynamic>> _contentBox;
  late Box<Map<String, dynamic>> _preferencesBox;

  bool _initialized = false;

  /// Initialize Hive and open boxes
  /// 
  /// Must be called before using any other methods
  Future<void> initialize() async {
    try {
      await Hive.initFlutter();

      // Register adapters if needed (for custom Hive objects)
      // This is optional if storing only Maps and primitives

      // Open boxes
      _userBox = await Hive.openBox<Map<String, dynamic>>(_userBoxName);
      _contentBox = await Hive.openBox<Map<String, dynamic>>(_contentBoxName);
      _preferencesBox = await Hive.openBox<Map<String, dynamic>>(_preferencesBoxName);

      _initialized = true;
    } catch (e) {
      throw LocalCacheException('Failed to initialize local cache: $e');
    }
  }

  // ===== USER DATA =====

  /// Save user data to local cache
  /// 
  /// Parameters:
  /// - [user]: User data map
  /// - [key]: Storage key (default: 'current_user')
  Future<void> saveUser(Map<String, dynamic> user, {String key = 'current_user'}) async {
    try {
      _checkInitialized();
      // Add timestamp for TTL tracking
      user['_cached_at'] = DateTime.now().millisecondsSinceEpoch;
      await _userBox.put(key, user);
    } catch (e) {
      throw LocalCacheException('Failed to save user: $e');
    }
  }

  /// Get cached user data
  /// 
  /// Parameters:
  /// - [key]: Storage key (default: 'current_user')
  /// - [maxAgeDuration]: Maximum age of cache (null = no expiry)
  /// 
  /// Returns: User data map or null if not found/expired
  Future<Map<String, dynamic>?> getUser({
    String key = 'current_user',
    Duration? maxAgeDuration,
  }) async {
    try {
      _checkInitialized();
      final user = _userBox.get(key);

      if (user == null) return null;

      // Check TTL expiry if maxAgeDuration is specified
      if (maxAgeDuration != null) {
        final cachedAt = user['_cached_at'] as int?;
        if (cachedAt != null) {
          final age = DateTime.now().millisecondsSinceEpoch - cachedAt;
          if (age > maxAgeDuration.inMilliseconds) {
            await _userBox.delete(key);
            return null;
          }
        }
      }

      return user;
    } catch (e) {
      throw LocalCacheException('Failed to get user: $e');
    }
  }

  /// Delete cached user data
  /// 
  /// Parameters:
  /// - [key]: Storage key (default: 'current_user')
  Future<void> deleteUser({String key = 'current_user'}) async {
    try {
      _checkInitialized();
      await _userBox.delete(key);
    } catch (e) {
      throw LocalCacheException('Failed to delete user: $e');
    }
  }

  // ===== CONTENT DATA =====

  /// Save content metadata to cache
  /// 
  /// Parameters:
  /// - [content]: Content data map
  /// - [id]: Content ID (used as storage key)
  Future<void> saveContent(String id, Map<String, dynamic> content) async {
    try {
      _checkInitialized();
      // Add timestamp for TTL tracking
      content['_cached_at'] = DateTime.now().millisecondsSinceEpoch;
      await _contentBox.put(id, content);
    } catch (e) {
      throw LocalCacheException('Failed to save content: $e');
    }
  }

  /// Get cached content by ID
  /// 
  /// Parameters:
  /// - [id]: Content ID
  /// - [maxAgeDuration]: Maximum age of cache (null = no expiry)
  /// 
  /// Returns: Content data map or null if not found/expired
  Future<Map<String, dynamic>?> getContent(
    String id, {
    Duration? maxAgeDuration,
  }) async {
    try {
      _checkInitialized();
      final content = _contentBox.get(id);

      if (content == null) return null;

      // Check TTL expiry
      if (maxAgeDuration != null) {
        final cachedAt = content['_cached_at'] as int?;
        if (cachedAt != null) {
          final age = DateTime.now().millisecondsSinceEpoch - cachedAt;
          if (age > maxAgeDuration.inMilliseconds) {
            await _contentBox.delete(id);
            return null;
          }
        }
      }

      return content;
    } catch (e) {
      throw LocalCacheException('Failed to get content: $e');
    }
  }

  /// Get all cached content
  /// 
  /// Parameters:
  /// - [maxAgeDuration]: Maximum age of cache entries (null = no expiry)
  /// 
  /// Returns: Map of all cached content
  Future<Map<String, Map<String, dynamic>>> getAllCachedContent({
    Duration? maxAgeDuration,
  }) async {
    try {
      _checkInitialized();
      final result = <String, Map<String, dynamic>>{};
      final keysToDelete = <String>[];

      for (final entry in _contentBox.toMap().entries) {
        final key = entry.key as String;
        final content = entry.value as Map<String, dynamic>;

        // Check TTL expiry
        if (maxAgeDuration != null) {
          final cachedAt = content['_cached_at'] as int?;
          if (cachedAt != null) {
            final age = DateTime.now().millisecondsSinceEpoch - cachedAt;
            if (age > maxAgeDuration.inMilliseconds) {
              keysToDelete.add(key);
              continue;
            }
          }
        }

        result[key] = content;
      }

      // Delete expired entries
      for (final key in keysToDelete) {
        await _contentBox.delete(key);
      }

      return result;
    } catch (e) {
      throw LocalCacheException('Failed to get all content: $e');
    }
  }

  /// Delete cached content
  /// 
  /// Parameters:
  /// - [id]: Content ID
  Future<void> deleteContent(String id) async {
    try {
      _checkInitialized();
      await _contentBox.delete(id);
    } catch (e) {
      throw LocalCacheException('Failed to delete content: $e');
    }
  }

  // ===== PREFERENCES =====

  /// Save user preferences
  /// 
  /// Parameters:
  /// - [preferences]: Preferences data map
  /// - [key]: Storage key (default: 'user_preferences')
  Future<void> savePreferences(
    Map<String, dynamic> preferences, {
    String key = 'user_preferences',
  }) async {
    try {
      _checkInitialized();
      preferences['_cached_at'] = DateTime.now().millisecondsSinceEpoch;
      await _preferencesBox.put(key, preferences);
    } catch (e) {
      throw LocalCacheException('Failed to save preferences: $e');
    }
  }

  /// Get user preferences
  /// 
  /// Parameters:
  /// - [key]: Storage key (default: 'user_preferences')
  /// - [maxAgeDuration]: Maximum age of cache
  /// 
  /// Returns: Preferences map or null if not found
  Future<Map<String, dynamic>?> getPreferences({
    String key = 'user_preferences',
    Duration? maxAgeDuration,
  }) async {
    try {
      _checkInitialized();
      final prefs = _preferencesBox.get(key);

      if (prefs == null) return null;

      // Check TTL expiry
      if (maxAgeDuration != null) {
        final cachedAt = prefs['_cached_at'] as int?;
        if (cachedAt != null) {
          final age = DateTime.now().millisecondsSinceEpoch - cachedAt;
          if (age > maxAgeDuration.inMilliseconds) {
            await _preferencesBox.delete(key);
            return null;
          }
        }
      }

      return prefs;
    } catch (e) {
      throw LocalCacheException('Failed to get preferences: $e');
    }
  }

  /// Delete preferences
  /// 
  /// Parameters:
  /// - [key]: Storage key
  Future<void> deletePreferences({String key = 'user_preferences'}) async {
    try {
      _checkInitialized();
      await _preferencesBox.delete(key);
    } catch (e) {
      throw LocalCacheException('Failed to delete preferences: $e');
    }
  }

  // ===== GENERAL CACHE OPERATIONS =====

  /// Clear all cached data
  Future<void> clearAll() async {
    try {
      _checkInitialized();
      await Future.wait([
        _userBox.clear(),
        _contentBox.clear(),
        _preferencesBox.clear(),
      ]);
    } catch (e) {
      throw LocalCacheException('Failed to clear all cache: $e');
    }
  }

  /// Get cache statistics
  /// 
  /// Returns: Map with cache information
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      _checkInitialized();
      return {
        'user_items': _userBox.length,
        'content_items': _contentBox.length,
        'preferences_items': _preferencesBox.length,
        'total_items': _userBox.length + _contentBox.length + _preferencesBox.length,
      };
    } catch (e) {
      throw LocalCacheException('Failed to get cache stats: $e');
    }
  }

  /// Close Hive boxes
  /// 
  /// Call this when disposing the service
  Future<void> close() async {
    try {
      if (_initialized) {
        await Future.wait([
          _userBox.close(),
          _contentBox.close(),
          _preferencesBox.close(),
        ]);
        _initialized = false;
      }
    } catch (e) {
      throw LocalCacheException('Failed to close cache: $e');
    }
  }

  // ===== PRIVATE HELPERS =====

  void _checkInitialized() {
    if (!_initialized) {
      throw LocalCacheException('LocalCacheService not initialized. Call initialize() first.');
    }
  }
}

/// Custom exception for local cache errors
class LocalCacheException implements Exception {
  final String message;

  LocalCacheException(this.message);

  @override
  String toString() => 'LocalCacheException: $message';
}
