import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../identity/domain/entities/user.dart';
import '../repositories/admin_repository.dart';

class UnbanUserParams {
  final String userId;
  const UnbanUserParams({required this.userId});
}

class UnbanUser implements UseCase<User, UnbanUserParams> {
  final AdminRepository _repository;
  UnbanUser(this._repository);

  @override
  Future<Either<Failure, User>> call(UnbanUserParams params) =>
      _repository.unbanUser(userId: params.userId);
}
