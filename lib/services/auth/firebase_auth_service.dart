import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Authentication service for DreamWeaver
/// 
/// Wraps Firebase Authentication with DreamWeaver-specific logic:
/// - Uses email/password auth with email format: username@dreamweaver.app
/// - The @dreamweaver.app suffix is hidden from UI (username only shown)
/// - Provides ID token for API authentication
class FirebaseAuthService {
  late FirebaseAuth _firebaseAuth;
  
  static const String _emailDomain = '@dreamweaver.app';

  /// Initialize Firebase Authentication
  void initialize() {
    _firebaseAuth = FirebaseAuth.instance;
  }

  /// Sign up new user with username and password
  /// 
  /// Internally converts username to email format (username@dreamweaver.app)
  /// 
  /// Parameters:
  /// - [username]: User's chosen username (displayed to user)
  /// - [password]: User's password
  /// 
  /// Returns: Firebase User object
  /// 
  /// Throws: [FirebaseAuthException] on authentication failure
  Future<User> signUpWithEmailPassword({
    required String username,
    required String password,
  }) async {
    try {
      // Convert username to email format
      final email = _convertUsernameToEmail(username);

      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw FirebaseAuthServiceException(
        'Sign up failed: $e',
        originalError: e,
      );
    }
  }

  /// Sign in existing user with username and password
  /// 
  /// Internally converts username to email format (username@dreamweaver.app)
  /// 
  /// Parameters:
  /// - [username]: User's username
  /// - [password]: User's password
  /// 
  /// Returns: Firebase User object
  /// 
  /// Throws: [FirebaseAuthServiceException] on authentication failure
  Future<User> signInWithEmailPassword({
    required String username,
    required String password,
  }) async {
    try {
      // Convert username to email format
      final email = _convertUsernameToEmail(username);

      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw FirebaseAuthServiceException(
        'Sign in failed: $e',
        originalError: e,
      );
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw FirebaseAuthServiceException(
        'Sign out failed: $e',
        originalError: e,
      );
    }
  }

  /// Get currently authenticated user
  /// 
  /// Returns: Firebase User or null if not authenticated
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  /// Get ID token for API authentication
  /// 
  /// The token is used in Authorization header as "Bearer {token}"
  /// 
  /// Returns: ID token string
  /// 
  /// Throws: [FirebaseAuthServiceException] if not authenticated
  Future<String> getIdToken({bool forceRefresh = false}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw FirebaseAuthServiceException('User not authenticated');
      }

      final tokenResult = await user.getIdTokenResult(forceRefresh);
      return tokenResult.token ?? '';
    } catch (e) {
      throw FirebaseAuthServiceException(
        'Failed to get ID token: $e',
        originalError: e,
      );
    }
  }

  /// Stream of authentication state changes
  /// 
  /// Emits User object when signed in, null when signed out
  /// 
  /// Use this to listen for login/logout events:
  /// ```dart
  /// authService.authStateChanges().listen((user) {
  ///   if (user != null) {
  ///     // User signed in
  ///   } else {
  ///     // User signed out
  ///   }
  /// });
  /// ```
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  /// Check if user is currently authenticated
  /// 
  /// Returns: True if user is logged in
  bool isAuthenticated() {
    return _firebaseAuth.currentUser != null;
  }

  /// Send password reset email
  /// 
  /// Parameters:
  /// - [username]: Username (will be converted to email format)
  Future<void> sendPasswordResetEmail(String username) async {
    try {
      final email = _convertUsernameToEmail(username);
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw FirebaseAuthServiceException(
        'Failed to send password reset email: $e',
        originalError: e,
      );
    }
  }

  /// Update user password
  /// 
  /// Parameters:
  /// - [newPassword]: New password
  /// 
  /// Throws: [FirebaseAuthServiceException] if not authenticated
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw FirebaseAuthServiceException('User not authenticated');
      }
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw FirebaseAuthServiceException(
        'Failed to update password: $e',
        originalError: e,
      );
    }
  }

  /// Delete current user account
  /// 
  /// Throws: [FirebaseAuthServiceException] if not authenticated
  Future<void> deleteUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw FirebaseAuthServiceException('User not authenticated');
      }
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw FirebaseAuthServiceException(
        'Failed to delete user: $e',
        originalError: e,
      );
    }
  }

  // ===== PRIVATE HELPERS =====

  /// Convert username to Firebase email format
  String _convertUsernameToEmail(String username) {
    return '$username$_emailDomain';
  }

  /// Convert Firebase email to username format
  String _convertEmailToUsername(String email) {
    return email.replaceAll(_emailDomain, '');
  }

  /// Handle Firebase auth exceptions with user-friendly messages
  FirebaseAuthServiceException _handleFirebaseAuthException(
    FirebaseAuthException e,
  ) {
    String message;

    switch (e.code) {
      case 'weak-password':
        message = 'Password is too weak. Use at least 6 characters.';
        break;
      case 'email-already-in-use':
        message = 'This username is already registered.';
        break;
      case 'invalid-email':
        message = 'Invalid email format.';
        break;
      case 'user-disabled':
        message = 'This account has been disabled.';
        break;
      case 'user-not-found':
        message = 'Username not found.';
        break;
      case 'wrong-password':
        message = 'Incorrect password.';
        break;
      case 'invalid-credential':
        message = 'Invalid credentials. Please check and try again.';
        break;
      case 'too-many-requests':
        message = 'Too many login attempts. Please try again later.';
        break;
      case 'operation-not-allowed':
        message = 'Operation not allowed. Please contact support.';
        break;
      default:
        message = 'Authentication error: ${e.message}';
    }

    return FirebaseAuthServiceException(
      message,
      code: e.code,
      originalError: e,
    );
  }
}

/// Custom exception for Firebase auth service errors
class FirebaseAuthServiceException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  FirebaseAuthServiceException(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'FirebaseAuthServiceException: $message';
}
