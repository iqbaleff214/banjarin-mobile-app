import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_error_mapper.dart';
import '../../../../core/usecase/paginated_result.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasources/comment_remote_data_source.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource _remote;

  CommentRepositoryImpl({required CommentRemoteDataSource remote})
      : _remote = remote;

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
  Future<Either<Failure, PaginatedResult<Comment>>> getComments({
    required String wordId,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final result = await _remote.getComments(
        wordId: wordId,
        page: page,
        perPage: perPage,
      );
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
  Future<Either<Failure, Comment>> postComment({
    required String wordId,
    required String body,
  }) async {
    try {
      final model = await _remote.postComment(wordId: wordId, body: body);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }

  @override
  Future<Either<Failure, Comment>> editComment({
    required String commentId,
    required String body,
  }) async {
    try {
      final model = await _remote.editComment(commentId: commentId, body: body);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment({
    required String commentId,
  }) async {
    try {
      await _remote.deleteComment(commentId: commentId);
      return const Right(null);
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }

  @override
  Future<Either<Failure, Comment>> flagComment({
    required String commentId,
  }) async {
    try {
      final model = await _remote.flagComment(commentId: commentId);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }
}
