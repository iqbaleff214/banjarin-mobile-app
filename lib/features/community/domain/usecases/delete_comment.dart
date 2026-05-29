import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/comment_repository.dart';

class DeleteCommentParams {
  final String commentId;

  const DeleteCommentParams({required this.commentId});
}

class DeleteComment implements UseCase<void, DeleteCommentParams> {
  final CommentRepository _repository;

  DeleteComment(this._repository);

  @override
  Future<Either<Failure, void>> call(DeleteCommentParams params) {
    return _repository.deleteComment(commentId: params.commentId);
  }
}
