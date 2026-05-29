import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/bookmark_repository.dart';

class RemoveBookmarkParams {
  final String wordId;

  const RemoveBookmarkParams({required this.wordId});
}

class RemoveBookmark implements UseCase<void, RemoveBookmarkParams> {
  final BookmarkRepository _repository;

  RemoveBookmark(this._repository);

  @override
  Future<Either<Failure, void>> call(RemoveBookmarkParams params) {
    return _repository.removeBookmark(wordId: params.wordId);
  }
}
