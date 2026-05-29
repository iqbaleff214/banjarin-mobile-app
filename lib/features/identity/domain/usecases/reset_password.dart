import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordParams {
  final String token;
  final String password;
  final String passwordConfirmation;

  const ResetPasswordParams({
    required this.token,
    required this.password,
    required this.passwordConfirmation,
  });
}

class ResetPassword implements UseCase<void, ResetPasswordParams> {
  final AuthRepository _repository;

  ResetPassword(this._repository);

  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) async {
    if (params.token.isEmpty) {
      return Left(ValidationFailure(
        fieldErrors: {'token': ['Token tidak valid.']},
      ));
    }
    if (params.password.length < 8) {
      return Left(ValidationFailure(
        fieldErrors: {'password': ['Kata sandi minimal 8 karakter.']},
      ));
    }
    if (params.password != params.passwordConfirmation) {
      return Left(ValidationFailure(
        fieldErrors: {
          'password_confirmation': ['Konfirmasi kata sandi tidak cocok.']
        },
      ));
    }
    return _repository.resetPassword(
      token: params.token,
      password: params.password,
      passwordConfirmation: params.passwordConfirmation,
    );
  }
}
