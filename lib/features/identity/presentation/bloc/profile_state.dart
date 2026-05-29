import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();

  @override
  List<Object?> get props => [];
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();

  @override
  List<Object?> get props => [];
}

final class ProfileLoaded extends ProfileState {
  final User user;

  const ProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

final class PasswordChanged extends ProfileState {
  const PasswordChanged();

  @override
  List<Object?> get props => [];
}

final class ProfileError extends ProfileState {
  final Failure failure;
  final User? currentUser;

  const ProfileError(this.failure, {this.currentUser});

  @override
  List<Object?> get props => [failure, currentUser];
}
