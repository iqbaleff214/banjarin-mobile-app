import 'package:banjarin/core/error/exceptions.dart';
import 'package:banjarin/features/identity/data/datasources/auth_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late AuthRemoteDataSourceImpl dataSource;

  final tLoginResponse = {
    'success': true,
    'data': {
      'access_token': 'acc_tok',
      'refresh_token': 'ref_tok',
      'expires_in': 900,
    },
  };

  final tUserResponse = {
    'success': true,
    'data': {
      'id': '1',
      'name': 'Ahmad',
      'email': 'ahmad@test.com',
      'role': 'user',
      'is_active': true,
      'email_verified_at': null,
      'created_at': '2024-01-01T00:00:00.000Z',
    },
  };

  setUp(() {
    mockDio = MockDio();
    dataSource = AuthRemoteDataSourceImpl(dio: mockDio);
    registerFallbackValue(RequestOptions(path: '/'));
    registerFallbackValue(<String, dynamic>{});
  });

  // -------------------------------------------------------------------------
  // login
  // -------------------------------------------------------------------------
  group('login', () {
    test('on 200 returns TokenPairModel', () async {
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
          )).thenAnswer(
        (_) async => Response(
          data: tLoginResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/auth/login'),
        ),
      );

      final result = await dataSource.login(
        email: 'ahmad@test.com',
        password: 'secret',
      );

      expect(result.accessToken, 'acc_tok');
      expect(result.refreshToken, 'ref_tok');
      expect(result.expiresIn, 900);
    });

    test('on DioException with ServerException propagates it', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/login'),
          error: const ServerException(
            code: 'UNAUTHORIZED',
            message: 'Invalid credentials',
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        () => dataSource.login(email: 'a@b.com', password: 'wrong'),
        throwsA(isA<DioException>()),
      );
    });

    test('on DioException with RATE_LIMITED ServerException propagates it',
        () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/login'),
          error: const ServerException(
            code: 'RATE_LIMITED',
            message: 'Too many requests',
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        () => dataSource.login(email: 'a@b.com', password: 'pass'),
        throwsA(isA<DioException>()),
      );
    });
  });

  // -------------------------------------------------------------------------
  // register
  // -------------------------------------------------------------------------
  group('register', () {
    test('on 201 returns UserModel', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: tUserResponse,
          statusCode: 201,
          requestOptions: RequestOptions(path: '/auth/register'),
        ),
      );

      final result = await dataSource.register(
        name: 'Ahmad',
        email: 'ahmad@test.com',
        password: 'secret123',
      );

      expect(result.name, 'Ahmad');
      expect(result.email, 'ahmad@test.com');
    });
  });

  // -------------------------------------------------------------------------
  // getProfile
  // -------------------------------------------------------------------------
  group('getProfile', () {
    test('on 200 returns UserModel', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: tUserResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/auth/me'),
        ),
      );

      final result = await dataSource.getProfile();

      expect(result.id, '1');
      expect(result.email, 'ahmad@test.com');
    });
  });

  // -------------------------------------------------------------------------
  // logout
  // -------------------------------------------------------------------------
  group('logout', () {
    test('on 204 completes without error', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          statusCode: 204,
          requestOptions: RequestOptions(path: '/auth/logout'),
        ),
      );

      await expectLater(
        dataSource.logout(refreshToken: 'ref_tok'),
        completes,
      );
    });
  });
}
