import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_error_mapper.dart';
import '../../../../core/usecase/paginated_result.dart';
import '../../domain/entities/contribution.dart';
import '../../domain/repositories/contribution_repository.dart';
import '../datasources/contribution_remote_data_source.dart';

class ContributionRepositoryImpl implements ContributionRepository {
  final ContributionRemoteDataSource _remote;

  ContributionRepositoryImpl({required ContributionRemoteDataSource remote})
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
  Future<Either<Failure, Contribution>> submit({
    required ContributionType type,
    String? targetWordId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final model = await _remote.submit(
        type: type,
        targetWordId: targetWordId,
        payload: payload,
      );
      return Right(model.toEntity());
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }

  @override
  Future<Either<Failure, PaginatedResult<Contribution>>> getContributions({
    ContributionStatus? status,
    ContributionType? type,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final result = await _remote.getContributions(
        status: status,
        type: type,
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
  Future<Either<Failure, Contribution>> getContributionDetail({
    required String contributionId,
  }) async {
    try {
      final model = await _remote.getContributionDetail(
        contributionId: contributionId,
      );
      return Right(model.toEntity());
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }

  @override
  Future<Either<Failure, Contribution>> withdraw({
    required String contributionId,
  }) async {
    try {
      final model = await _remote.withdraw(contributionId: contributionId);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }
}
