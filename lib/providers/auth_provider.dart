import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// AuthNotifier handles authentication logic
class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuthService _authService;
  final ApiClient _apiClient;

  AuthNotifier({
    required FirebaseAuthService authService,
    required ApiClient apiClient,
  })  : _authService = authService,
        _apiClient = apiClient,
        super(const AuthStateInitial());

  /// Sign up with username, password, and child age
  Future<void> signUp({
    required String username,
    required String password,
    required int childAge,
  }) async {
    try {
      state = const AuthStateLoading();
      final userId = await _authService.signUp(username, password);
      
      // Register user on backend with child age
      await _apiClient.registerUser(
        userId: userId,
        username: username,
        childAge: childAge,
      );
      
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
      final userId = await _authService.signIn(username, password);
      state = AuthStateAuthenticated(userId: userId, username: username);
    } catch (e) {
      state = AuthStateError(message: e.toString());
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      state = const AuthStateLoading();
      await _authService.signOut();
      state = const AuthStateUnauthenticated();
    } catch (e) {
      state = AuthStateError(message: e.toString());
    }
  }

  /// Check current authentication status
  Future<void> checkAuthStatus() async {
    try {
      state = const AuthStateLoading();
      final userId = _authService.getCurrentUserId();
      
      if (userId != null) {
        final username = await _apiClient.getUserUsername(userId);
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

/// Provider for API client
final apiClientProvider = Provider((ref) {
  return ApiClient();
});
