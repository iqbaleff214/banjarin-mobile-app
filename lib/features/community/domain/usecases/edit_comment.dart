import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

class EditCommentParams {
  final String commentId;
  final String body;

  const EditCommentParams({required this.commentId, required this.body});
}

class EditComment implements UseCase<Comment, EditCommentParams> {
  final CommentRepository _repository;

  EditComment(this._repository);

  @override
  Future<Either<Failure, Comment>> call(EditCommentParams params) async {
    if (params.body.trim().isEmpty) {
      return Left(ValidationFailure(
        fieldErrors: {'body': ['Komentar tidak boleh kosong.']},
      ));
    }
    if (params.body.length > 1000) {
      return Left(ValidationFailure(
        fieldErrors: {'body': ['Komentar maksimal 1000 karakter.']},
      ));
    }
    return _repository.editComment(
      commentId: params.commentId,
      body: params.body.trim(),
    );
  }
}
