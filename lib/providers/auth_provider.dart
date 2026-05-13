import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dreamweaver/config/env.dart';
import 'package:dreamweaver/services/auth/firebase_auth_service.dart';
import 'package:dreamweaver/services/api/api_client.dart';

/// Auth state sealed class with different states for authentication flow
sealed class AuthState {
  const AuthState();
}

class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateAuthenticated extends AuthState {
  final String userId;
  final String username;

  const AuthStateAuthenticated({
    required this.userId,
    required this.username,
  });
}

class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

class AuthStateError extends AuthState {
  final String message;

  const AuthStateError({required this.message});
}

/// Extension on AuthState for convenient .isLoading / .when() pattern usage
extension AuthStateExtension on AuthState {
  bool get isLoading => this is AuthStateLoading;
  bool get isAuthenticated => this is AuthStateAuthenticated;
  bool get isError => this is AuthStateError;
}

/// Simple result type used by login/signup to support .fold() pattern
class AuthResult {
  final String? error;
  final AuthUser? user;

  AuthResult.success(this.user) : error = null;
  AuthResult.failure(this.error) : user = null;

  /// Fold over success/failure, matching the pattern screens use:
  ///   result.fold((error) => ..., (user) => ...)
  T fold<T>(T Function(String error) onError, T Function(AuthUser user) onSuccess) {
    if (error != null) {
      return onError(error!);
    }
    return onSuccess(user!);
  }
}

/// Lightweight user object returned by login/signup
class AuthUser {
  final String userId;
  final String username;

  AuthUser({required this.userId, required this.username});
}

/// AuthNotifier handles authentication logic
class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuthService _authService;
  final ApiClient _apiClient;

  /// Email domain suffix used by FirebaseAuthService to derive username
  static const String _emailDomain = '@dreamweaver.app';

  AuthNotifier({
    required FirebaseAuthService authService,
    required ApiClient apiClient,
  })  : _authService = authService,
        _apiClient = apiClient,
        super(const AuthStateInitial());

  /// Extract username from Firebase email (strip @dreamweaver.app)
  String _usernameFromEmail(String email) {
    return email.replaceAll(_emailDomain, '');
  }

  /// Login method used by login_screen.dart -- returns AuthResult for .fold()
  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    try {
      state = const AuthStateLoading();
      final user = await _authService.signInWithEmailPassword(
        username: username,
        password: password,
      );
      final userId = user.uid;

      // Update the API client auth token for subsequent requests
      final token = await _authService.getIdToken();
      _apiClient.setAuthToken(token);

      state = AuthStateAuthenticated(userId: userId, username: username);
      return AuthResult.success(AuthUser(userId: userId, username: username));
    } catch (e) {
      final message = e.toString();
      state = AuthStateError(message: message);
      return AuthResult.failure(message);
    }
  }

  /// Signup method used by signup_screen.dart -- returns AuthResult for .fold()
  Future<AuthResult> signup({
    required String username,
    required String password,
  }) async {
    try {
      state = const AuthStateLoading();
      final user = await _authService.signUpWithEmailPassword(
        username: username,
        password: password,
      );
      final userId = user.uid;

      // Register user on backend
      await _apiClient.registerUser(
        userId: userId,
        username: username,
        childAge: 5, // Default child age; will be set in age_setup_screen
      );

      // Update the API client auth token for subsequent requests
      final token = await _authService.getIdToken();
      _apiClient.setAuthToken(token);

      state = AuthStateAuthenticated(userId: userId, username: username);
      return AuthResult.success(AuthUser(userId: userId, username: username));
    } catch (e) {
      final message = e.toString();
      state = AuthStateError(message: message);
      return AuthResult.failure(message);
    }
  }

  /// Sign up with username, password, and child age (full version)
  Future<void> signUp({
    required String username,
    required String password,
    required int childAge,
  }) async {
    try {
      state = const AuthStateLoading();
      final user = await _authService.signUpWithEmailPassword(
        username: username,
        password: password,
      );
      final userId = user.uid;

      // Register user on backend with child age
      await _apiClient.registerUser(
        userId: userId,
        username: username,
        childAge: childAge,
      );

      // Update the API client auth token for subsequent requests
      final token = await _authService.getIdToken();
      _apiClient.setAuthToken(token);

      state = AuthStateAuthenticated(userId: userId, username: username);
    } catch (e) {
      state = AuthStateError(message: e.toString());
    }
  }

  /// Sign in with username and password
  Future<void> signIn({
    required String username,
    required String password,
  }) async {
    try {
      state = const AuthStateLoading();
      final user = await _authService.signInWithEmailPassword(
        username: username,
        password: password,
      );
      final userId = user.uid;

      // Update the API client auth token for subsequent requests
      final token = await _authService.getIdToken();
      _apiClient.setAuthToken(token);

      state = AuthStateAuthenticated(userId: userId, username: username);
    } catch (e) {
      state = AuthStateError(message: e.toString());
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      state = const AuthStateLoading();
      _apiClient.clearAuthToken();
      await _authService.signOut();
      state = const AuthStateUnauthenticated();
    } catch (e) {
      state = AuthStateError(message: e.toString());
    }
  }

  /// Logout convenience method -- delegates to [signOut]
  Future<void> logout() => signOut();

  /// Check current authentication status
  Future<void> checkAuthStatus() async {
    try {
      state = const AuthStateLoading();
      final user = _authService.getCurrentUser();

      if (user != null) {
        final userId = user.uid;
        final username = _usernameFromEmail(user.email ?? '');

        // Refresh the API client auth token
        final token = await _authService.getIdToken();
        _apiClient.setAuthToken(token);

        state = AuthStateAuthenticated(userId: userId, username: username);
      } else {
        state = const AuthStateUnauthenticated();
      }
    } catch (e) {
      state = AuthStateError(message: e.toString());
    }
  }
}

/// Riverpod provider for auth state
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = FirebaseAuthService();
  final apiClient = ref.watch(apiClientProvider);

  final notifier = AuthNotifier(
    authService: authService,
    apiClient: apiClient,
  );

  // Check auth status on initialization
  notifier.checkAuthStatus();

  return notifier;
});

/// Alias so screens can use either `authProvider` or `authStateProvider`
final authProvider = authStateProvider;

/// Provider for API client -- returns the high-level [ApiClient] wrapper
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});
