import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetProfile implements UseCase<User, NoParams> {
  final AuthRepository _repository;

  GetProfile(this._repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) {
    return _repository.getProfile();
  }
}
