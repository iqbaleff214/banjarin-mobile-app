import 'package:equatable/equatable.dart';

import 'user_role.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final bool isActive;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    this.emailVerifiedAt,
    required this.createdAt,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get emailVerified => emailVerifiedAt != null;

  User copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    bool? isActive,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, email, role, isActive, emailVerifiedAt, createdAt];
}
