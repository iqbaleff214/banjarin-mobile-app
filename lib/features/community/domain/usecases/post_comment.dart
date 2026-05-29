import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

class PostCommentParams {
  final String wordId;
  final String body;
  final bool isAuthenticated;

  const PostCommentParams({
    required this.wordId,
    required this.body,
    required this.isAuthenticated,
  });
}

class PostComment implements UseCase<Comment, PostCommentParams> {
  final CommentRepository _repository;

  PostComment(this._repository);

  @override
  Future<Either<Failure, Comment>> call(PostCommentParams params) async {
    if (!params.isAuthenticated) {
      return const Left(UnauthorizedFailure());
    }
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
    return _repository.postComment(
      wordId: params.wordId,
      body: params.body.trim(),
    );
  }
}
