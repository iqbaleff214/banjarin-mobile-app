import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_error_mapper.dart';
import '../../domain/entities/translation_result.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/ai_remote_data_source.dart';

class AIRepositoryImpl implements AIRepository {
  final AIRemoteDataSource _remoteDataSource;

  AIRepositoryImpl({required AIRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

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
  Future<Either<Failure, TranslationResult>> translate({
    required String text,
    String? context,
  }) async {
    // Never cached — stateless per API spec
    try {
      final model = await _remoteDataSource.translate(
        text: text,
        context: context,
      );
      return Right(model.toEntity());
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }
}
