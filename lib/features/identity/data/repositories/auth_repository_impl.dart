import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_error_mapper.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/token_pair.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required TokenStorage tokenStorage,
  })  : _remoteDataSource = remoteDataSource,
        _tokenStorage = tokenStorage;

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
  Future<Either<Failure, TokenPair>> login({
    required String email,
    required String password,
  }) async {
    try {
      final model = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      await _tokenStorage.saveTokens(
        accessToken: model.accessToken,
        refreshToken: model.refreshToken,
      );
      return Right(model.toEntity());
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final model = await _remoteDataSource.register(
        name: name,
        email: email,
        password: password,
      );
      return Right(model.toEntity());
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }

  @override
  Future<Either<Failure, void>> logout({required String refreshToken}) async {
    try {
      await _remoteDataSource.logout(refreshToken: refreshToken);
      await _tokenStorage.clearTokens();
      return const Right(null);
    } on DioException catch (e) {
      await _tokenStorage.clearTokens();
      return _mapDioException(e);
    }
  }

  @override
  Future<Either<Failure, TokenPair>> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final model = await _remoteDataSource.refreshToken(
        refreshToken: refreshToken,
      );
      await _tokenStorage.saveTokens(
        accessToken: model.accessToken,
        refreshToken: model.refreshToken,
      );
      return Right(model.toEntity());
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }

  @override
  Future<Either<Failure, User>> getProfile() async {
    try {
      final model = await _remoteDataSource.getProfile();
      return Right(model.toEntity());
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({required String name}) async {
    try {
      final model = await _remoteDataSource.updateProfile(name: name);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _remoteDataSource.changePassword(
        currentPassword: currentPassword,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return const Right(null);
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) async {
    try {
      await _remoteDataSource.forgotPassword(email: email);
      return const Right(null);
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _remoteDataSource.resetPassword(
        token: token,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return const Right(null);
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }

  @override
  Future<Either<Failure, void>> verifyEmail({required String token}) async {
    try {
      await _remoteDataSource.verifyEmail(token: token);
      return const Right(null);
    } on DioException catch (e) {
      return _mapDioException(e);
    }
  }
}
