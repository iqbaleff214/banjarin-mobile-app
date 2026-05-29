import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/paginated_result.dart';
import '../entities/comment.dart';

abstract class CommentRepository {
  Future<Either<Failure, PaginatedResult<Comment>>> getComments({
    required String wordId,
    int page = 1,
    int perPage = 20,
  });

  Future<Either<Failure, Comment>> postComment({
    required String wordId,
    required String body,
  });

  Future<Either<Failure, Comment>> editComment({
    required String commentId,
    required String body,
  });

  Future<Either<Failure, void>> deleteComment({required String commentId});

  Future<Either<Failure, Comment>> flagComment({required String commentId});
}
