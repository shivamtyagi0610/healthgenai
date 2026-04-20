import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

/// Concrete implementation of AuthRepository.
/// Acts as the bridge between Domain and Data layers.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Stream<UserEntity?> get authStateChanges {
    return _remoteDataSource.authStateChanges.map((firebaseUser) {
      if (firebaseUser == null) return null;
      return UserModel.fromFirebaseUser(firebaseUser);
    });
  }

  @override
  UserEntity? get currentUser {
    final user = _remoteDataSource.currentUser;
    if (user == null) return null;
    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<UserEntity> signInWithEmailPassword(String email, String password) async {
    final user = await _remoteDataSource.signInWithEmailPassword(email, password);
    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<UserEntity> signUpWithEmailPassword(String email, String password, String name) async {
    final user = await _remoteDataSource.signUpWithEmailPassword(email, password, name);
    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<void> signOut() => _remoteDataSource.signOut();
}
