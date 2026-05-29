import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/bookmark.dart';
import '../repositories/bookmark_repository.dart';

class AddBookmarkParams {
  final String wordId;

  const AddBookmarkParams({required this.wordId});
}

class AddBookmark implements UseCase<Bookmark, AddBookmarkParams> {
  final BookmarkRepository _repository;

  AddBookmark(this._repository);

  @override
  Future<Either<Failure, Bookmark>> call(AddBookmarkParams params) {
    return _repository.addBookmark(wordId: params.wordId);
  }
}
