import 'package:banjarin/core/storage/secure_token_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecureTokenStorage secureTokenStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    secureTokenStorage = SecureTokenStorage(storage: mockStorage);
  });

  group('SecureTokenStorage', () {
    test('saveTokens writes both access and refresh tokens', () async {
      when(
        () => mockStorage.write(key: 'access_token', value: 'access123'),
      ).thenAnswer((_) async {});
      when(
        () => mockStorage.write(key: 'refresh_token', value: 'refresh456'),
      ).thenAnswer((_) async {});

      await secureTokenStorage.saveTokens(
        accessToken: 'access123',
        refreshToken: 'refresh456',
      );

      verify(
        () => mockStorage.write(key: 'access_token', value: 'access123'),
      ).called(1);
      verify(
        () => mockStorage.write(key: 'refresh_token', value: 'refresh456'),
      ).called(1);
    });

    test('getAccessToken returns null when not set', () async {
      when(() => mockStorage.read(key: 'access_token'))
          .thenAnswer((_) async => null);

      final result = await secureTokenStorage.getAccessToken();

      expect(result, isNull);
    });

    test('getAccessToken returns stored token', () async {
      when(() => mockStorage.read(key: 'access_token'))
          .thenAnswer((_) async => 'my_token');

      final result = await secureTokenStorage.getAccessToken();

      expect(result, 'my_token');
    });

    test('getRefreshToken returns stored refresh token', () async {
      when(() => mockStorage.read(key: 'refresh_token'))
          .thenAnswer((_) async => 'my_refresh');

      final result = await secureTokenStorage.getRefreshToken();

      expect(result, 'my_refresh');
    });

    test('clearTokens deletes both access and refresh tokens', () async {
      when(() => mockStorage.delete(key: 'access_token'))
          .thenAnswer((_) async {});
      when(() => mockStorage.delete(key: 'refresh_token'))
          .thenAnswer((_) async {});

      await secureTokenStorage.clearTokens();

      verify(() => mockStorage.delete(key: 'access_token')).called(1);
      verify(() => mockStorage.delete(key: 'refresh_token')).called(1);
    });
  });
}
