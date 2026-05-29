import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

class FlagCommentParams {
  final String commentId;

  const FlagCommentParams({required this.commentId});
}

class FlagComment implements UseCase<Comment, FlagCommentParams> {
  final CommentRepository _repository;

  FlagComment(this._repository);

  @override
  Future<Either<Failure, Comment>> call(FlagCommentParams params) {
    return _repository.flagComment(commentId: params.commentId);
  }
}
