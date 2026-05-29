import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_error_mapper.dart';
import '../../../../core/usecase/paginated_result.dart';
import '../../domain/entities/bookmark.dart';
import '../../domain/repositories/bookmark_repository.dart';
import '../datasources/bookmark_local_data_source.dart';
import '../datasources/bookmark_remote_data_source.dart';
import '../models/bookmark_model.dart';

class BookmarkRepositoryImpl implements BookmarkRepository {
  final BookmarkRemoteDataSource _remote;
  final BookmarkLocalDataSource _local;

  BookmarkRepositoryImpl({
    required BookmarkRemoteDataSource remote,
    required BookmarkLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  Either<Failure, T> _mapDioException<T>(DioException e) {
    final error = e.error;
    if (error is ServerException) {
      return Left(ApiErrorMapper.mapCode(error.code, error.message, error.details));
    }
    if (error is NetworkException) {
      return Left(NetworkFailure(error.message));
    }
    return Left(ServerFailure(e.message ?? 'Unexpected error'));
  }

  @override
  Future<Either<Failure, PaginatedResult<Bookmark>>> getBookmarks({
    int page = 1,
    int perPage = 20,
  }) async {
    // Return cached data for page 1
    if (page == 1) {
      final cached = await _local.getCachedBookmarks();
      if (cached != null) {
        final models = cached.map(BookmarkModel.fromJson);
        return Right(PaginatedResult(
          items: models.map((m) => m.toEntity()).toList(),
          page: 1,
          perPage: perPage,
          total: models.length,
        ));
      }
    }

    try {
      final result = await _remote.getBookmarks(page: page, perPage: perPage);
      if (page == 1) {
        await _local.cacheBookmarks(
          result.items.map((m) => m.toJson()).toList(),
        );
        // Update bookmarked IDs cache
        for (final m in result.items) {
          await _local.addBookmarkedId(m.wordId);
        }
      }
      return Right(PaginatedResult(
        items: result.items.map((m) => m.toEntity()).toList(),
        page: result.page,
        perPage: result.perPage,
        total: result.total,
      ));
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }

  @override
  Future<Either<Failure, Bookmark>> addBookmark({
    required String wordId,
  }) async {
    // Optimistic: mark as bookmarked locally
    await _local.addBookmarkedId(wordId);
    try {
      final model = await _remote.addBookmark(wordId: wordId);
      await _local.invalidate(); // invalidate list cache to force refresh
      return Right(model.toEntity());
    } on DioException catch (e) {
      // Rollback
      await _local.removeBookmarkedId(wordId);
      return _mapDioException(e);
    }
  }

  @override
  Future<Either<Failure, void>> removeBookmark({
    required String wordId,
  }) async {
    // Optimistic: remove from local cache
    await _local.removeBookmarkedId(wordId);
    try {
      await _remote.removeBookmark(wordId: wordId);
      await _local.invalidate();
      return const Right(null);
    } on DioException catch (e) {
      // Rollback
      await _local.addBookmarkedId(wordId);
      return _mapDioException(e);
    }
  }
}
