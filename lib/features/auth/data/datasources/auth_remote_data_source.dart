import 'package:firebase_auth/firebase_auth.dart';

/// Remote Data Source directly interacting with Firebase Auth.
/// Handles raw Firebase API calls and exceptions.
class AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;

  AuthRemoteDataSource(this._firebaseAuth);

  /// Exposes the raw Firebase auth state changes.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Gets the currently authenticated user synchronously.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Sign in with email and password.
  Future<User> signInWithEmailPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        throw Exception("Unknown error occurred during sign in.");
      }
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: \${e.toString()}');
    }
  }

  /// Sign up with email, password, and immediately update the user's display name.
  Future<User> signUpWithEmailPassword(String email, String password, String name) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = credential.user;
      if (user == null) {
        throw Exception("Unknown error occurred during account creation.");
      }

      // Update the user's profile with their name immediately
      await user.updateDisplayName(name);
      await user.reload(); // Force reload to reflect changes
      
      return _firebaseAuth.currentUser!; // Return fresh user data
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: \${e.toString()}');
    }
  }

  /// Sign out.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Maps specific Firebase exceptions to user-friendly messages
  Exception _handleFirebaseException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return Exception('Invalid email or password.');
      case 'email-already-in-use':
        return Exception('This email is already in use by another account.');
      case 'weak-password':
        return Exception('The password provided is too weak.');
      case 'invalid-email':
        return Exception('The email address is improperly formatted.');
      case 'network-request-failed':
        return Exception('Network error. Please check your connection.');
      default:
        return Exception(e.message ?? 'An unknown authentication error occurred.');
    }
  }
}
