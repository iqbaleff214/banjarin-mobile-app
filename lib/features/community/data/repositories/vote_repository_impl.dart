import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_error_mapper.dart';
import '../../domain/entities/vote.dart';
import '../../domain/repositories/vote_repository.dart';
import '../datasources/vote_remote_data_source.dart';

class VoteRepositoryImpl implements VoteRepository {
  final VoteRemoteDataSource _remoteDataSource;

  VoteRepositoryImpl({required VoteRemoteDataSource remoteDataSource})
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
  Future<Either<Failure, Vote>> castVote({
    required String targetId,
    required VoteTargetType targetType,
    required VoteValue value,
  }) async {
    try {
      final model = await _remoteDataSource.castVote(
        targetId: targetId,
        targetType: targetType,
        value: value,
      );
      return Right(model.toEntity());
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }

  @override
  Future<Either<Failure, void>> removeVote({
    required String targetId,
    required VoteTargetType targetType,
  }) async {
    try {
      await _remoteDataSource.removeVote(
        targetId: targetId,
        targetType: targetType,
      );
      return const Right(null);
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }
}
