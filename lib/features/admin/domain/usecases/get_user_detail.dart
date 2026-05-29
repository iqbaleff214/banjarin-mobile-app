import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../identity/domain/entities/user.dart';
import '../repositories/admin_repository.dart';

class GetUserDetailParams {
  final String userId;
  const GetUserDetailParams({required this.userId});
}

class GetUserDetail implements UseCase<User, GetUserDetailParams> {
  final AdminRepository _repository;
  GetUserDetail(this._repository);

  @override
  Future<Either<Failure, User>> call(GetUserDetailParams params) =>
      _repository.getUserDetail(userId: params.userId);
}
