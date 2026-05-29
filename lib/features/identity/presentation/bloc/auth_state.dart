import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';

sealed class AuthState extends Equatable {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();

  @override
  List<Object?> get props => [];
}

final class AuthLoading extends AuthState {
  const AuthLoading();

  @override
  List<Object?> get props => [];
}

final class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

final class RegisterSuccess extends AuthState {
  final String email;

  const RegisterSuccess(this.email);

  @override
  List<Object?> get props => [email];
}

final class Unauthenticated extends AuthState {
  const Unauthenticated();

  @override
  List<Object?> get props => [];
}

final class AuthError extends AuthState {
  final Failure failure;

  const AuthError(this.failure);

  @override
  List<Object?> get props => [failure];
}
