import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/paginated_result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../identity/domain/entities/user.dart';
import '../repositories/admin_repository.dart';

class GetAdminUsers
    implements UseCase<PaginatedResult<User>, GetAdminUsersParams> {
  final AdminRepository _repository;
  GetAdminUsers(this._repository);

  @override
  Future<Either<Failure, PaginatedResult<User>>> call(
    GetAdminUsersParams params,
  ) =>
      _repository.getAdminUsers(params);
}
