import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../../domain/entities/user_entity.dart';

/// Data Transfer Object (DTO) for User
/// Maps Data Layer (Firebase) objects to Domain Layer Entities.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
  });

  /// Factory to map from Firebase's User object safely.
  factory UserModel.fromFirebaseUser(firebase.User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName,
    );
  }
}
