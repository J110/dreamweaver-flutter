/// Route path constants for the app
class Routes {
  static const String splash = '/';
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String ageSetup = '/auth/age-setup';
  static const String home = '/home';
  static const String explore = '/explore';
  static const String favorites = '/favorites';
  static const String profile = '/profile';
  static const String contentDetail = '/content/:id';
  static const String contentLibrary = '/library';
  static const String categoryBrowse = '/category/:categoryId';
  static const String customize = '/customize';
  static const String voiceSelection = '/customize/voice';
  static const String player = '/player/:id';
  static const String subscription = '/subscription';
  static const String search = '/search';
  static const String settings = '/settings';

  // Helper to build dynamic routes
  static String contentDetailPath(String id) => '/content/$id';
  static String categoryBrowsePath(String categoryId) => '/category/$categoryId';
  static String playerPath(String id) => '/player/$id';
}
