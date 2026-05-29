import 'package:banjarin/core/error/exceptions.dart';
import 'package:banjarin/core/error/failures.dart';
import 'package:banjarin/core/storage/token_storage.dart';
import 'package:banjarin/features/identity/data/datasources/auth_remote_data_source.dart';
import 'package:banjarin/features/identity/data/models/token_pair_model.dart';
import 'package:banjarin/features/identity/data/models/user_model.dart';
import 'package:banjarin/features/identity/data/repositories/auth_repository_impl.dart';
import 'package:banjarin/features/identity/domain/entities/user_role.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late MockAuthRemoteDataSource mockDataSource;
  late MockTokenStorage mockTokenStorage;
  late AuthRepositoryImpl repository;

  final tTokenPairModel = const TokenPairModel(
    accessToken: 'acc',
    refreshToken: 'ref',
    expiresIn: 900,
  );

  final tUserModel = UserModel(
    id: '1',
    name: 'Ahmad',
    email: 'ahmad@test.com',
    role: UserRole.user,
    isActive: true,
    createdAt: DateTime(2024),
  );

  DioException makeDioException(ServerException se) => DioException(
        requestOptions: RequestOptions(path: '/'),
        error: se,
        type: DioExceptionType.badResponse,
      );

  setUp(() {
    mockDataSource = MockAuthRemoteDataSource();
    mockTokenStorage = MockTokenStorage();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockDataSource,
      tokenStorage: mockTokenStorage,
    );
    registerFallbackValue(RequestOptions(path: '/'));
  });

  // -------------------------------------------------------------------------
  // login
  // -------------------------------------------------------------------------
  group('AuthRepositoryImpl.login', () {
    test('on success stores tokens and returns TokenPair', () async {
      when(() => mockDataSource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => tTokenPairModel);
      when(() => mockTokenStorage.saveTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          )).thenAnswer((_) async {});

      final result = await repository.login(
        email: 'ahmad@test.com',
        password: 'secret',
      );

      expect(result.isRight(), isTrue);
      verify(() => mockTokenStorage.saveTokens(
            accessToken: 'acc',
            refreshToken: 'ref',
          )).called(1);
    });

    test('on UNAUTHORIZED ServerException returns UnauthorizedFailure', () async {
      when(() => mockDataSource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(makeDioException(const ServerException(
        code: 'UNAUTHORIZED',
        message: 'Invalid credentials',
      )));

      final result = await repository.login(
        email: 'a@b.com',
        password: 'wrong',
      );

      expect(result.isLeft(), isTrue);
      expect(result.fold((f) => f, (_) => null), isA<UnauthorizedFailure>());
    });

    test('on RATE_LIMITED ServerException returns RateLimitedFailure', () async {
      when(() => mockDataSource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(makeDioException(const ServerException(
        code: 'RATE_LIMITED',
        message: 'Too many requests',
        details: {'retry_after': 60},
      )));

      final result = await repository.login(
        email: 'a@b.com',
        password: 'pass',
      );

      expect(result.fold((f) => f, (_) => null), isA<RateLimitedFailure>());
    });
  });

  // -------------------------------------------------------------------------
  // logout
  // -------------------------------------------------------------------------
  group('AuthRepositoryImpl.logout', () {
    test('on success clears tokens from storage', () async {
      when(() => mockDataSource.logout(refreshToken: any(named: 'refreshToken')))
          .thenAnswer((_) async {});
      when(() => mockTokenStorage.clearTokens()).thenAnswer((_) async {});

      await repository.logout(refreshToken: 'ref_tok');

      verify(() => mockTokenStorage.clearTokens()).called(1);
    });

    test('clears tokens even when API call throws', () async {
      when(() => mockDataSource.logout(refreshToken: any(named: 'refreshToken')))
          .thenThrow(makeDioException(const ServerException(
        code: 'UNAUTHORIZED',
        message: 'Already logged out',
      )));
      when(() => mockTokenStorage.clearTokens()).thenAnswer((_) async {});

      await repository.logout(refreshToken: 'ref_tok');

      verify(() => mockTokenStorage.clearTokens()).called(1);
    });
  });

  // -------------------------------------------------------------------------
  // getProfile
  // -------------------------------------------------------------------------
  group('AuthRepositoryImpl.getProfile', () {
    test('on success returns User entity', () async {
      when(() => mockDataSource.getProfile())
          .thenAnswer((_) async => tUserModel);

      final result = await repository.getProfile();

      expect(result.isRight(), isTrue);
      expect(result.fold((_) => null, (u) => u.email), 'ahmad@test.com');
    });

    test('on NetworkException returns NetworkFailure', () async {
      when(() => mockDataSource.getProfile()).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/auth/me'),
        error: const NetworkException('Network error'),
        type: DioExceptionType.connectionError,
      ));

      final result = await repository.getProfile();

      expect(result.fold((f) => f, (_) => null), isA<NetworkFailure>());
    });
  });
}
