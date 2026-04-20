import 'package:equatable/equatable.dart';

/// Represents an authenticated user in the domain layer.
/// This entity does not depend on Firebase or any data layer specifics.
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? name;

  const UserEntity({
    required this.id,
    required this.email,
    this.name,
  });

  @override
  List<Object?> get props => [id, email, name];
}
