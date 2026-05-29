import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/token_pair.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});
}

class Login implements UseCase<TokenPair, LoginParams> {
  final AuthRepository _repository;

  Login(this._repository);

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  Future<Either<Failure, TokenPair>> call(LoginParams params) async {
    if (params.email.trim().isEmpty) {
      return Left(ValidationFailure(
        fieldErrors: {'email': ['Email tidak boleh kosong.']},
      ));
    }
    if (!_emailRegex.hasMatch(params.email.trim())) {
      return Left(ValidationFailure(
        fieldErrors: {'email': ['Format email tidak valid.']},
      ));
    }
    if (params.password.isEmpty) {
      return Left(ValidationFailure(
        fieldErrors: {'password': ['Kata sandi tidak boleh kosong.']},
      ));
    }
    return _repository.login(
      email: params.email.trim(),
      password: params.password,
    );
  }
}
