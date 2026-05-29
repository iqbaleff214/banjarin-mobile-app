import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class ChangePasswordParams {
  final String currentPassword;
  final String newPassword;
  final String newPasswordConfirmation;

  const ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });
}

class ChangePassword implements UseCase<void, ChangePasswordParams> {
  final AuthRepository _repository;

  ChangePassword(this._repository);

  @override
  Future<Either<Failure, void>> call(ChangePasswordParams params) async {
    if (params.newPassword.length < 8) {
      return Left(ValidationFailure(
        fieldErrors: {'password': ['Kata sandi baru minimal 8 karakter.']},
      ));
    }
    if (params.newPassword != params.newPasswordConfirmation) {
      return Left(ValidationFailure(
        fieldErrors: {
          'password_confirmation': ['Konfirmasi kata sandi tidak cocok.']
        },
      ));
    }
    return _repository.changePassword(
      currentPassword: params.currentPassword,
      password: params.newPassword,
      passwordConfirmation: params.newPasswordConfirmation,
    );
  }
}
