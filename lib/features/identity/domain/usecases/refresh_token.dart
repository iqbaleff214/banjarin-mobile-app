import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/token_pair.dart';
import '../repositories/auth_repository.dart';

class RefreshTokenParams {
  final String refreshToken;

  const RefreshTokenParams({required this.refreshToken});
}

class RefreshToken implements UseCase<TokenPair, RefreshTokenParams> {
  final AuthRepository _repository;

  RefreshToken(this._repository);

  @override
  Future<Either<Failure, TokenPair>> call(RefreshTokenParams params) {
    return _repository.refreshToken(refreshToken: params.refreshToken);
  }
}
