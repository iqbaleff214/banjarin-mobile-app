import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../identity/domain/entities/user.dart';
import '../../../identity/domain/entities/user_role.dart';
import '../repositories/admin_repository.dart';

class ChangeUserRoleParams {
  final String userId;
  final UserRole newRole;
  const ChangeUserRoleParams({required this.userId, required this.newRole});
}

class ChangeUserRole implements UseCase<User, ChangeUserRoleParams> {
  final AdminRepository _repository;
  ChangeUserRole(this._repository);

  @override
  Future<Either<Failure, User>> call(ChangeUserRoleParams params) =>
      _repository.changeUserRole(userId: params.userId, role: params.newRole);
}
