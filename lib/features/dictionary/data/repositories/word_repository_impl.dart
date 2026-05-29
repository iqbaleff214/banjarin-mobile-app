import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_error_mapper.dart';
import '../../../../core/usecase/paginated_result.dart';
import '../../domain/entities/definition.dart';
import '../../domain/entities/example.dart';
import '../../domain/entities/word.dart';
import '../../domain/entities/word_summary.dart';
import '../../domain/repositories/word_repository.dart';
import '../datasources/word_local_data_source.dart';
import '../datasources/word_remote_data_source.dart';
import '../models/word_model.dart';
import '../models/word_summary_model.dart';

class WordRepositoryImpl implements WordRepository {
  final WordRemoteDataSource _remote;
  final WordLocalDataSource _local;

  WordRepositoryImpl({
    required WordRemoteDataSource remote,
    required WordLocalDataSource local,
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

  bool _isFirstPageNoFilter(WordListParams p) =>
      p.page == 1 &&
      p.wordClass == null &&
      p.isRoot == null &&
      p.source == null;

  @override
  Future<Either<Failure, PaginatedResult<WordSummary>>> getWordList(
    WordListParams params,
  ) async {
    // Cache-first only for page 1 with no filters
    if (_isFirstPageNoFilter(params)) {
      final cached = await _local.getCachedWordList();
      if (cached != null) {
        final models = cached.map(WordSummaryModel.fromJson);
        return Right(PaginatedResult(
          items: models.map((m) => m.toEntity()).toList(),
          page: 1,
          perPage: params.perPage,
          total: models.length,
        ));
      }
    }

    try {
      final result = await _remote.getWordList(params);
      if (_isFirstPageNoFilter(params)) {
        await _local.cacheWordList(
          result.items.map((m) => m.toJson()).toList(),
        );
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
  Future<Either<Failure, PaginatedResult<WordSummary>>> searchWords(
    SearchParams params,
  ) async {
    try {
      final result = await _remote.searchWords(params);
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
  Future<Either<Failure, Word>> getWordDetail(WordIdParams params) async {
    final cached = await _local.getCachedWord(params.wordId);
    if (cached != null) {
      return Right(WordModel.fromJson(cached).toEntity());
    }

    try {
      final model = await _remote.getWordDetail(params.wordId);
      await _local.cacheWord(params.wordId, model.toJson());
      return Right(model.toEntity());
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }

  @override
  Future<Either<Failure, List<Definition>>> getDefinitions(
    WordIdParams params,
  ) async {
    try {
      final models = await _remote.getDefinitions(params.wordId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }

  @override
  Future<Either<Failure, List<Example>>> getExamples(
    WordIdParams params,
  ) async {
    try {
      final models = await _remote.getExamples(params.wordId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }

  @override
  Future<Either<Failure, List<WordSummary>>> getRelatedWords(
    WordIdParams params,
  ) async {
    try {
      final models = await _remote.getRelatedWords(params.wordId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }
}
