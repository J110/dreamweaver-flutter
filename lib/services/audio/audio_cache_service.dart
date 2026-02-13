import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Local audio caching service for DreamWeaver
/// 
/// Manages caching of audio files to local storage for offline playback
/// and faster access to frequently used audio files.
class AudioCacheService {
  late Directory _cacheDir;
  bool _initialized = false;

  /// Initialize cache directory
  Future<void> initialize() async {
    try {
      final baseDir = await getApplicationCacheDirectory();
      _cacheDir = Directory('${baseDir.path}/audio_cache');
      
      // Create cache directory if it doesn't exist
      if (!await _cacheDir.exists()) {
        await _cacheDir.create(recursive: true);
      }
      _initialized = true;
    } catch (e) {
      throw AudioCacheException('Failed to initialize audio cache: $e');
    }
  }

  /// Cache audio file from bytes
  /// 
  /// Parameters:
  /// - [contentId]: Unique identifier for the content
  /// - [bytes]: Audio file bytes to cache
  /// 
  /// Returns: Path to cached file
  Future<String> cacheAudio(String contentId, List<int> bytes) async {
    if (!_initialized) {
      throw AudioCacheException('AudioCacheService not initialized');
    }

    try {
      final file = File('${_cacheDir.path}/$contentId.m4a');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      throw AudioCacheException('Failed to cache audio: $e');
    }
  }

  /// Get cached audio file path
  /// 
  /// Parameters:
  /// - [contentId]: Content identifier
  /// 
  /// Returns: Path to cached file, or null if not cached
  Future<String?> getCachedAudio(String contentId) async {
    if (!_initialized) {
      throw AudioCacheException('AudioCacheService not initialized');
    }

    try {
      final file = File('${_cacheDir.path}/$contentId.m4a');
      if (await file.exists()) {
        return file.path;
      }
      return null;
    } catch (e) {
      throw AudioCacheException('Failed to get cached audio: $e');
    }
  }

  /// Check if audio is cached
  /// 
  /// Parameters:
  /// - [contentId]: Content identifier
  /// 
  /// Returns: True if audio is cached
  Future<bool> isCached(String contentId) async {
    if (!_initialized) {
      throw AudioCacheException('AudioCacheService not initialized');
    }

    try {
      final file = File('${_cacheDir.path}/$contentId.m4a');
      return await file.exists();
    } catch (e) {
      throw AudioCacheException('Failed to check cache status: $e');
    }
  }

  /// Clear entire audio cache
  Future<void> clearCache() async {
    if (!_initialized) {
      throw AudioCacheException('AudioCacheService not initialized');
    }

    try {
      if (await _cacheDir.exists()) {
        await _cacheDir.delete(recursive: true);
        await _cacheDir.create(recursive: true);
      }
    } catch (e) {
      throw AudioCacheException('Failed to clear cache: $e');
    }
  }

  /// Clear specific cached audio
  /// 
  /// Parameters:
  /// - [contentId]: Content identifier
  Future<void> clearCachedAudio(String contentId) async {
    if (!_initialized) {
      throw AudioCacheException('AudioCacheService not initialized');
    }

    try {
      final file = File('${_cacheDir.path}/$contentId.m4a');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw AudioCacheException('Failed to clear cached audio: $e');
    }
  }

  /// Get total cache size in bytes
  /// 
  /// Returns: Total size of all cached audio files
  Future<int> getCacheSize() async {
    if (!_initialized) {
      throw AudioCacheException('AudioCacheService not initialized');
    }

    try {
      int totalSize = 0;
      if (await _cacheDir.exists()) {
        final files = _cacheDir.listSync();
        for (final file in files) {
          if (file is File) {
            totalSize += await file.length();
          }
        }
      }
      return totalSize;
    } catch (e) {
      throw AudioCacheException('Failed to get cache size: $e');
    }
  }

  /// Get cache size in human-readable format (MB)
  /// 
  /// Returns: Cache size as string (e.g., "15.5 MB")
  Future<String> getCacheSizeFormatted() async {
    final bytes = await getCacheSize();
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  /// Get list of all cached content IDs
  /// 
  /// Returns: List of content IDs that are cached
  Future<List<String>> getCachedContentIds() async {
    if (!_initialized) {
      throw AudioCacheException('AudioCacheService not initialized');
    }

    try {
      final ids = <String>[];
      if (await _cacheDir.exists()) {
        final files = _cacheDir.listSync();
        for (final file in files) {
          if (file is File && file.path.endsWith('.m4a')) {
            final filename = file.path.split('/').last;
            final contentId = filename.replaceAll('.m4a', '');
            ids.add(contentId);
          }
        }
      }
      return ids;
    } catch (e) {
      throw AudioCacheException('Failed to get cached content IDs: $e');
    }
  }

  /// Clear cache if it exceeds maximum size
  /// 
  /// Parameters:
  /// - [maxSizeBytes]: Maximum cache size in bytes (default: 500MB)
  /// 
  /// Deletes oldest files first until under limit
  Future<void> clearCacheIfExceeds(int maxSizeBytes) async {
    if (!_initialized) {
      throw AudioCacheException('AudioCacheService not initialized');
    }

    try {
      final currentSize = await getCacheSize();
      if (currentSize > maxSizeBytes) {
        // Get all files sorted by modification time (oldest first)
        final files = _cacheDir.listSync();
        final fileList = <File>[];
        for (final file in files) {
          if (file is File) {
            fileList.add(file);
          }
        }
        
        fileList.sort(
          (a, b) => a.statSync().modified.compareTo(b.statSync().modified),
        );

        // Delete oldest files until under limit
        int deletedSize = 0;
        for (final file in fileList) {
          if (currentSize - deletedSize <= maxSizeBytes) {
            break;
          }
          final fileSize = file.lengthSync();
          await file.delete();
          deletedSize += fileSize;
        }
      }
    } catch (e) {
      throw AudioCacheException('Failed to clear cache by size: $e');
    }
  }
}

/// Custom exception for audio cache errors
class AudioCacheException implements Exception {
  final String message;

  AudioCacheException(this.message);

  @override
  String toString() => 'AudioCacheException: $message';
}
