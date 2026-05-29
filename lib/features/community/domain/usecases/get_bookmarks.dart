import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/paginated_result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/bookmark.dart';
import '../repositories/bookmark_repository.dart';

class GetBookmarksParams {
  final int page;
  final int perPage;

  const GetBookmarksParams({this.page = 1, this.perPage = 20});
}

class GetBookmarks implements UseCase<PaginatedResult<Bookmark>, GetBookmarksParams> {
  final BookmarkRepository _repository;

  GetBookmarks(this._repository);

  @override
  Future<Either<Failure, PaginatedResult<Bookmark>>> call(
    GetBookmarksParams params,
  ) {
    return _repository.getBookmarks(page: params.page, perPage: params.perPage);
  }
}
