import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordParams {
  final String email;

  const ForgotPasswordParams({required this.email});
}

class ForgotPassword implements UseCase<void, ForgotPasswordParams> {
  final AuthRepository _repository;

  ForgotPassword(this._repository);

  @override
  Future<Either<Failure, void>> call(ForgotPasswordParams params) {
    return _repository.forgotPassword(email: params.email);
  }
}
