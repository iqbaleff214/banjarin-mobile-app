import 'package:equatable/equatable.dart';

import '../../../identity/domain/entities/user_role.dart';

sealed class UserMgmtEvent extends Equatable {
  const UserMgmtEvent();
}

final class LoadAdminUsers extends UserMgmtEvent {
  final String? query;
  final UserRole? role;
  final bool? isActive;

  const LoadAdminUsers({this.query, this.role, this.isActive});

  @override
  List<Object?> get props => [query, role, isActive];
}

final class BanUserEvent extends UserMgmtEvent {
  final String userId;
  final String reason;

  const BanUserEvent({required this.userId, required this.reason});

  @override
  List<Object?> get props => [userId, reason];
}

final class UnbanUserEvent extends UserMgmtEvent {
  final String userId;
  const UnbanUserEvent(this.userId);
  @override List<Object?> get props => [userId];
}

final class ChangeUserRoleEvent extends UserMgmtEvent {
  final String userId;
  final UserRole newRole;

  const ChangeUserRoleEvent({required this.userId, required this.newRole});

  @override
  List<Object?> get props => [userId, newRole];
}
