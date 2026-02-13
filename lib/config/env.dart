/// Environment configuration for DreamWeaver
class Env {
  static const String appName = 'DreamWeaver';
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );
  static const String groqApiKey = String.fromEnvironment('GROQ_API_KEY');
  static const int defaultPageSize = 20;
  static const Duration cacheExpiry = Duration(hours: 24);
  static const Duration audioCacheExpiry = Duration(days: 7);
}
