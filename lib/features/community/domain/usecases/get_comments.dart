import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/paginated_result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

class GetCommentsParams {
  final String wordId;
  final int page;
  final int perPage;

  const GetCommentsParams({
    required this.wordId,
    this.page = 1,
    this.perPage = 20,
  });
}

class GetComments implements UseCase<PaginatedResult<Comment>, GetCommentsParams> {
  final CommentRepository _repository;

  GetComments(this._repository);

  @override
  Future<Either<Failure, PaginatedResult<Comment>>> call(
    GetCommentsParams params,
  ) {
    return _repository.getComments(
      wordId: params.wordId,
      page: params.page,
      perPage: params.perPage,
    );
  }
}
