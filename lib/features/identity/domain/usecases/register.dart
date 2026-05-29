import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterParams {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;

  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });
}

class Register implements UseCase<User, RegisterParams> {
  final AuthRepository _repository;

  Register(this._repository);

  @override
  Future<Either<Failure, User>> call(RegisterParams params) async {
    if (params.password.length < 8) {
      return Left(ValidationFailure(
        fieldErrors: {'password': ['Kata sandi minimal 8 karakter.']},
      ));
    }
    if (params.password != params.passwordConfirmation) {
      return Left(ValidationFailure(
        fieldErrors: {'password_confirmation': ['Konfirmasi kata sandi tidak cocok.']},
      ));
    }
    return _repository.register(
      name: params.name,
      email: params.email,
      password: params.password,
    );
  }
}
