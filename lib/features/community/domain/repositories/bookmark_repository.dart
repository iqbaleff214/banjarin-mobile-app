import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/paginated_result.dart';
import '../entities/bookmark.dart';

abstract class BookmarkRepository {
  Future<Either<Failure, PaginatedResult<Bookmark>>> getBookmarks({
    int page = 1,
    int perPage = 20,
  });

  Future<Either<Failure, Bookmark>> addBookmark({required String wordId});

  Future<Either<Failure, void>> removeBookmark({required String wordId});
}
