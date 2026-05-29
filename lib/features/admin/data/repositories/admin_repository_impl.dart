import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_error_mapper.dart';
import '../../../../core/usecase/paginated_result.dart';
import '../../../community/domain/entities/comment.dart';
import '../../../community/domain/entities/contribution.dart';
import '../../../dictionary/domain/entities/word.dart';
import '../../../dictionary/domain/entities/word_summary.dart';
import '../../../identity/domain/entities/user.dart';
import '../../../identity/domain/entities/user_role.dart';
import '../../domain/entities/ai_request.dart';
import '../../domain/entities/moderation_stats.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remote;

  AdminRepositoryImpl({required AdminRemoteDataSource remote})
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
  Future<Either<Failure, PaginatedResult<WordSummary>>> getAdminWords(
      GetAdminWordsParams params) async {
    try {
      final result = await _remote.getAdminWords(params);
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
  Future<Either<Failure, Word>> createWord(CreateWordParams params) async {
    try {
      final model = await _remote.createWord(params);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }

  @override
  Future<Either<Failure, Word>> updateWord(UpdateWordParams params) async {
    try {
      final model = await _remote.updateWord(params);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }

  @override
  Future<Either<Failure, void>> deleteWord({required String wordId}) async {
    try {
      await _remote.deleteWord(wordId: wordId);
      return const Right(null);
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }

  @override
  Future<Either<Failure, PaginatedResult<User>>> getAdminUsers(
      GetAdminUsersParams params) async {
    try {
      final result = await _remote.getAdminUsers(params);
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
  Future<Either<Failure, User>> getUserDetail({required String userId}) async {
    try {
      return Right((await _remote.getUserDetail(userId: userId)).toEntity());
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }

  @override
  Future<Either<Failure, User>> banUser(
      {required String userId, required String reason}) async {
    try {
      return Right(
          (await _remote.banUser(userId: userId, reason: reason)).toEntity());
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }

  @override
  Future<Either<Failure, User>> unbanUser({required String userId}) async {
    try {
      return Right((await _remote.unbanUser(userId: userId)).toEntity());
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }

  @override
  Future<Either<Failure, User>> changeUserRole(
      {required String userId, required UserRole role}) async {
    try {
      return Right(
          (await _remote.changeUserRole(userId: userId, role: role)).toEntity());
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }

  @override
  Future<Either<Failure, PaginatedResult<Contribution>>> getModerationQueue(
      GetModerationQueueParams params) async {
    try {
      final result = await _remote.getModerationQueue(params);
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
  Future<Either<Failure, PaginatedResult<Comment>>> getFlaggedComments(
      {int page = 1, int perPage = 20}) async {
    try {
      final result = await _remote.getFlaggedComments(
          page: page, perPage: perPage);
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
  Future<Either<Failure, ModerationStats>> getModerationStats() async {
    try {
      return Right((await _remote.getModerationStats()).toEntity());
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }

  @override
  Future<Either<Failure, Contribution>> approveContribution(
      {required String contributionId, String? note}) async {
    try {
      return Right((await _remote.approveContribution(
              contributionId: contributionId, note: note))
          .toEntity());
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }

  @override
  Future<Either<Failure, Contribution>> rejectContribution(
      {required String contributionId, required String note}) async {
    try {
      return Right((await _remote.rejectContribution(
              contributionId: contributionId, note: note))
          .toEntity());
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }

  // -------------------------------------------------------------------------
  // AI Enrichment
  // -------------------------------------------------------------------------

  Future<Either<Failure, AIRequest>> _wrapAI(
    Future<AIRequest> Function() fn,
  ) async {
    try {
      return Right(await fn());
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }

  @override
  Future<Either<Failure, AIRequest>> triggerEnrich({required String wordId}) =>
      _wrapAI(() async =>
          (await _remote.triggerEnrich(wordId: wordId)).toEntity());

  @override
  Future<Either<Failure, AIRequest>> triggerExample({required String wordId}) =>
      _wrapAI(() async =>
          (await _remote.triggerExample(wordId: wordId)).toEntity());

  @override
  Future<Either<Failure, AIRequest>> triggerRelated({required String wordId}) =>
      _wrapAI(() async =>
          (await _remote.triggerRelated(wordId: wordId)).toEntity());

  @override
  Future<Either<Failure, AIRequest>> runQualityCheck(
          {required String contributionId}) =>
      _wrapAI(() async =>
          (await _remote.runQualityCheck(contributionId: contributionId))
              .toEntity());

  @override
  Future<Either<Failure, PaginatedResult<AIRequest>>> getAIRequests(
      GetAIRequestsParams params) async {
    try {
      final result = await _remote.getAIRequests(params);
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
  Future<Either<Failure, AIRequest>> getAIRequestDetail(
          {required String requestId}) =>
      _wrapAI(() async =>
          (await _remote.getAIRequestDetail(requestId: requestId)).toEntity());

  @override
  Future<Either<Failure, AIRequest>> approveAIRequest(
          {required String requestId}) =>
      _wrapAI(() async =>
          (await _remote.approveAIRequest(requestId: requestId)).toEntity());

  @override
  Future<Either<Failure, AIRequest>> rejectAIRequest(
          {required String requestId}) =>
      _wrapAI(() async =>
          (await _remote.rejectAIRequest(requestId: requestId)).toEntity());
}
