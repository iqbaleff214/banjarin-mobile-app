import 'package:banjarin/core/network/token_interceptor.dart';
import 'package:banjarin/core/storage/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTokenStorage extends Mock implements TokenStorage {}

class MockHttpClientAdapter extends Mock implements HttpClientAdapter {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

void main() {
  late MockTokenStorage mockStorage;
  late Dio refreshDio;
  late MockHttpClientAdapter mockAdapter;
  late TokenInterceptor interceptor;

  setUp(() {
    mockStorage = MockTokenStorage();
    mockAdapter = MockHttpClientAdapter();

    refreshDio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v2'));
    refreshDio.httpClientAdapter = mockAdapter;

    interceptor = TokenInterceptor(
      tokenStorage: mockStorage,
      refreshDio: refreshDio,
    );

    registerFallbackValue(RequestOptions(path: '/'));
    registerFallbackValue(ResponseBody.fromString('', 200));
    registerFallbackValue(
      DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.unknown,
      ),
    );
    registerFallbackValue(
      Response<dynamic>(requestOptions: RequestOptions(path: '/')),
    );
  });

  // ---------------------------------------------------------------------------
  // isPublicPath
  // ---------------------------------------------------------------------------
  group('isPublicPath', () {
    test('returns true for /auth/login', () {
      expect(interceptor.isPublicPath('/auth/login'), isTrue);
    });

    test('returns true for /auth/register', () {
      expect(interceptor.isPublicPath('/auth/register'), isTrue);
    });

    test('returns true for /auth/refresh', () {
      expect(interceptor.isPublicPath('/auth/refresh'), isTrue);
    });

    test('returns true for /auth/forgot-password', () {
      expect(interceptor.isPublicPath('/auth/forgot-password'), isTrue);
    });

    test('returns false for /words', () {
      expect(interceptor.isPublicPath('/words'), isFalse);
    });

    test('returns false for /bookmarks', () {
      expect(interceptor.isPublicPath('/bookmarks'), isFalse);
    });

    test('returns false for /contributions', () {
      expect(interceptor.isPublicPath('/contributions'), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // attachToken
  // ---------------------------------------------------------------------------
  group('attachToken', () {
    test('attaches Bearer token to protected request', () async {
      when(() => mockStorage.getAccessToken())
          .thenAnswer((_) async => 'my_access_token');

      final options = RequestOptions(path: '/words');
      final attached = await interceptor.attachToken(options);

      expect(attached, isTrue);
      expect(options.headers['Authorization'], 'Bearer my_access_token');
    });

    test('does not attach token to public path /auth/login', () async {
      when(() => mockStorage.getAccessToken())
          .thenAnswer((_) async => 'my_access_token');

      final options = RequestOptions(path: '/auth/login');
      final attached = await interceptor.attachToken(options);

      expect(attached, isFalse);
      expect(options.headers['Authorization'], isNull);
    });

    test('does not attach token to public path /auth/register', () async {
      when(() => mockStorage.getAccessToken())
          .thenAnswer((_) async => 'my_access_token');

      final options = RequestOptions(path: '/auth/register');
      final attached = await interceptor.attachToken(options);

      expect(attached, isFalse);
      expect(options.headers['Authorization'], isNull);
    });

    test('does not attach header when access token is null', () async {
      when(() => mockStorage.getAccessToken()).thenAnswer((_) async => null);

      final options = RequestOptions(path: '/words');
      final attached = await interceptor.attachToken(options);

      expect(attached, isFalse);
      expect(options.headers['Authorization'], isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // handleRefresh — no refresh token
  // ---------------------------------------------------------------------------
  group('handleRefresh — no refresh token stored', () {
    test('clears tokens and passes error through when refresh token is null',
        () async {
      when(() => mockStorage.getRefreshToken()).thenAnswer((_) async => null);
      when(() => mockStorage.clearTokens()).thenAnswer((_) async {});

      final err = _make401('/words');
      final handler = MockErrorInterceptorHandler();
      when(() => handler.next(any())).thenReturn(null);

      await interceptor.handleRefresh(err, handler);

      verify(() => mockStorage.clearTokens()).called(1);
      verify(() => handler.next(any())).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // handleRefresh — refresh call succeeds
  // ---------------------------------------------------------------------------
  group('handleRefresh — refresh succeeds', () {
    test('saves new tokens after successful refresh', () async {
      when(() => mockStorage.getRefreshToken())
          .thenAnswer((_) async => 'old_refresh');
      when(
        () => mockStorage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      ).thenAnswer((_) async {});

      when(() => mockAdapter.fetch(any(), any(), any()))
          .thenAnswer((invocation) async {
        final opts =
            invocation.positionalArguments[0] as RequestOptions;

        if (opts.path.endsWith('/auth/refresh')) {
          return ResponseBody.fromString(
            '{"data":{"access_token":"new_acc","refresh_token":"new_ref"}}',
            200,
            headers: {
              'content-type': ['application/json']
            },
          );
        }
        // retry response
        return ResponseBody.fromString(
          '{"success":true}',
          200,
          headers: {
            'content-type': ['application/json']
          },
        );
      });

      final err = _make401('/words');
      final handler = MockErrorInterceptorHandler();
      when(() => handler.resolve(any())).thenReturn(null);

      await interceptor.handleRefresh(err, handler);

      verify(
        () => mockStorage.saveTokens(
          accessToken: 'new_acc',
          refreshToken: 'new_ref',
        ),
      ).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // handleRefresh — refresh call fails
  // ---------------------------------------------------------------------------
  group('handleRefresh — refresh fails', () {
    test('clears tokens when refresh call throws', () async {
      when(() => mockStorage.getRefreshToken())
          .thenAnswer((_) async => 'stale_refresh');
      when(() => mockStorage.clearTokens()).thenAnswer((_) async {});

      when(() => mockAdapter.fetch(any(), any(), any()))
          .thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/refresh'),
          type: DioExceptionType.badResponse,
        ),
      );

      final err = _make401('/words');
      final handler = MockErrorInterceptorHandler();
      when(() => handler.next(any())).thenReturn(null);

      await interceptor.handleRefresh(err, handler);

      verify(() => mockStorage.clearTokens()).called(1);
    });
  });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

DioException _make401(String path) => DioException(
      requestOptions: RequestOptions(path: path),
      response: Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 401,
      ),
      type: DioExceptionType.badResponse,
    );
