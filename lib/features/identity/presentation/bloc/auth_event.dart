import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
}

final class CheckSession extends AuthEvent {
  const CheckSession();

  @override
  List<Object?> get props => [];
}

final class AuthLogin extends AuthEvent {
  final String email;
  final String password;

  const AuthLogin({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

final class AuthRegister extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;

  const AuthRegister({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object?> get props => [name, email, password, passwordConfirmation];
}

final class AuthLogout extends AuthEvent {
  const AuthLogout();

  @override
  List<Object?> get props => [];
}

final class AuthSessionExpired extends AuthEvent {
  const AuthSessionExpired();

  @override
  List<Object?> get props => [];
}
