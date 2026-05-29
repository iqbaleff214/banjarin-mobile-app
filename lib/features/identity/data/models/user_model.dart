import '../../domain/entities/user.dart';
import '../../domain/entities/user_role.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final bool isActive;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    this.emailVerifiedAt,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.fromString(json['role'] as String? ?? 'user'),
      isActive: json['is_active'] as bool? ?? true,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'is_active': isActive,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      role: role,
      isActive: isActive,
      emailVerifiedAt: emailVerifiedAt,
      createdAt: createdAt,
    );
  }
}
