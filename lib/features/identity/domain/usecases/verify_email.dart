import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class VerifyEmailParams {
  final String token;

  const VerifyEmailParams({required this.token});
}

class VerifyEmail implements UseCase<void, VerifyEmailParams> {
  final AuthRepository _repository;

  VerifyEmail(this._repository);

  @override
  Future<Either<Failure, void>> call(VerifyEmailParams params) {
    return _repository.verifyEmail(token: params.token);
  }
}
