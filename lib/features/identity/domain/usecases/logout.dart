import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class LogoutParams {
  final String refreshToken;

  const LogoutParams({required this.refreshToken});
}

class Logout implements UseCase<void, LogoutParams> {
  final AuthRepository _repository;

  Logout(this._repository);

  @override
  Future<Either<Failure, void>> call(LogoutParams params) {
    return _repository.logout(refreshToken: params.refreshToken);
  }
}
