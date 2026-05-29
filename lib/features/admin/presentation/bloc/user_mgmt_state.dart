import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../identity/domain/entities/user.dart';

sealed class UserMgmtState extends Equatable {
  const UserMgmtState();
}

final class UserMgmtInitial extends UserMgmtState {
  const UserMgmtInitial();
  @override List<Object?> get props => [];
}

final class UserMgmtLoading extends UserMgmtState {
  const UserMgmtLoading();
  @override List<Object?> get props => [];
}

final class UserMgmtLoaded extends UserMgmtState {
  final List<User> users;
  final bool hasMore;
  final int currentPage;

  const UserMgmtLoaded({
    required this.users,
    required this.hasMore,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [users, hasMore, currentPage];
}

final class Banning extends UserMgmtState {
  final List<User> currentUsers;
  const Banning(this.currentUsers);
  @override List<Object?> get props => [currentUsers];
}

final class Banned extends UserMgmtState {
  final List<User> users;
  final bool hasMore;
  final int currentPage;

  const Banned({required this.users, required this.hasMore, required this.currentPage});
  @override List<Object?> get props => [users, hasMore, currentPage];
}

final class ChangingRole extends UserMgmtState {
  final List<User> currentUsers;
  const ChangingRole(this.currentUsers);
  @override List<Object?> get props => [currentUsers];
}

final class RoleChanged extends UserMgmtState {
  final List<User> users;
  final bool hasMore;
  final int currentPage;

  const RoleChanged({required this.users, required this.hasMore, required this.currentPage});
  @override List<Object?> get props => [users, hasMore, currentPage];
}

final class UserMgmtError extends UserMgmtState {
  final Failure failure;
  const UserMgmtError(this.failure);
  @override List<Object?> get props => [failure];
}
