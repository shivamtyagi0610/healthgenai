import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../viewmodels/auth_viewmodel.dart';

/// Provides the FirebaseAuth instance.
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Provides the Remote Data Source for Auth.
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return AuthRemoteDataSource(firebaseAuth);
});

/// Provides the Auth Repository implementation typed as the Domain interface.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource);
});

/// Stream provider to reactively watch authentication state changes.
/// UI can listen to this to know if the user is logged in or out.
final authStateProvider = StreamProvider<UserEntity?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

/// Exposes the AuthViewModel logic for SignIn/SignUp UI actions.
final authViewModelProvider = AsyncNotifierProvider<AuthViewModel, void>(() {
  return AuthViewModel();
});
