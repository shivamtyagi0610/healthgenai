import '../entities/user_entity.dart';

/// Interface for Authentication.
/// Belongs to the Domain layer to define what can be done without knowing how.
abstract class AuthRepository {
  /// Stream to listen to real-time authentication state changes.
  Stream<UserEntity?> get authStateChanges;

  /// Get the currently signed in user, or null if unauthenticated.
  UserEntity? get currentUser;

  /// Sign in with email and password.
  Future<UserEntity> signInWithEmailPassword(String email, String password);

  /// Sign up with email, password, and an optional name.
  Future<UserEntity> signUpWithEmailPassword(
      String email, String password, String name);

  /// Sign the current user out.
  Future<void> signOut();
}
