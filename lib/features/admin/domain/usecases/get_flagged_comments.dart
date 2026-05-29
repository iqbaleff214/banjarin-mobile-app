import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/paginated_result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../community/domain/entities/comment.dart';
import '../repositories/admin_repository.dart';

class GetFlaggedCommentsParams {
  final int page;
  final int perPage;
  const GetFlaggedCommentsParams({this.page = 1, this.perPage = 20});
}

class GetFlaggedComments
    implements UseCase<PaginatedResult<Comment>, GetFlaggedCommentsParams> {
  final AdminRepository _repository;
  GetFlaggedComments(this._repository);

  @override
  Future<Either<Failure, PaginatedResult<Comment>>> call(
    GetFlaggedCommentsParams params,
  ) =>
      _repository.getFlaggedComments(
        page: params.page,
        perPage: params.perPage,
      );
}
