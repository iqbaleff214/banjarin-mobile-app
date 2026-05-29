import 'package:banjarin/core/error/failures.dart';
import 'package:banjarin/core/storage/token_storage.dart';
import 'package:banjarin/core/usecase/usecase.dart';
import 'package:banjarin/features/identity/domain/entities/token_pair.dart';
import 'package:banjarin/features/identity/domain/entities/user.dart';
import 'package:banjarin/features/identity/domain/entities/user_role.dart';
import 'package:banjarin/features/identity/domain/usecases/get_profile.dart';
import 'package:banjarin/features/identity/domain/usecases/login.dart';
import 'package:banjarin/features/identity/domain/usecases/logout.dart';
import 'package:banjarin/features/identity/domain/usecases/register.dart';
import 'package:banjarin/features/identity/presentation/bloc/auth_bloc.dart';
import 'package:banjarin/features/identity/presentation/bloc/auth_event.dart';
import 'package:banjarin/features/identity/presentation/bloc/auth_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockLogin extends Mock implements Login {}

class MockRegister extends Mock implements Register {}

class MockLogout extends Mock implements Logout {}

class MockGetProfile extends Mock implements GetProfile {}

class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late MockLogin mockLogin;
  late MockRegister mockRegister;
  late MockLogout mockLogout;
  late MockGetProfile mockGetProfile;
  late MockTokenStorage mockTokenStorage;

  final tUser = User(
    id: '1',
    name: 'Ahmad',
    email: 'ahmad@test.com',
    role: UserRole.user,
    isActive: true,
    emailVerifiedAt: DateTime(2024),
    createdAt: DateTime(2024),
  );

  final tTokenPair = TokenPair(
    accessToken: 'acc',
    refreshToken: 'ref',
    expiresIn: 900,
  );

  setUp(() {
    mockLogin = MockLogin();
    mockRegister = MockRegister();
    mockLogout = MockLogout();
    mockGetProfile = MockGetProfile();
    mockTokenStorage = MockTokenStorage();

    registerFallbackValue(LoginParams(email: '', password: ''));
    registerFallbackValue(RegisterParams(
      name: '',
      email: '',
      password: '',
      passwordConfirmation: '',
    ));
    registerFallbackValue(LogoutParams(refreshToken: ''));
    registerFallbackValue(const NoParams());
  });

  AuthBloc makeBloc() => AuthBloc(
        login: mockLogin,
        register: mockRegister,
        logout: mockLogout,
        getProfile: mockGetProfile,
        tokenStorage: mockTokenStorage,
      );

  // -------------------------------------------------------------------------
  // CheckSession
  // -------------------------------------------------------------------------
  group('CheckSession', () {
    blocTest<AuthBloc, AuthState>(
      'when tokens exist and profile loads emits Authenticated',
      build: () {
        when(() => mockTokenStorage.getRefreshToken())
            .thenAnswer((_) async => 'ref_tok');
        when(() => mockGetProfile(any()))
            .thenAnswer((_) async => Right(tUser));
        return makeBloc();
      },
      act: (bloc) => bloc.add(const CheckSession()),
      expect: () => [isA<Authenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'when no tokens emits Unauthenticated',
      build: () {
        when(() => mockTokenStorage.getRefreshToken())
            .thenAnswer((_) async => null);
        return makeBloc();
      },
      act: (bloc) => bloc.add(const CheckSession()),
      expect: () => [isA<Unauthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'when profile fetch fails emits Unauthenticated',
      build: () {
        when(() => mockTokenStorage.getRefreshToken())
            .thenAnswer((_) async => 'ref_tok');
        when(() => mockGetProfile(any())).thenAnswer(
          (_) async => Left(const UnauthorizedFailure()),
        );
        return makeBloc();
      },
      act: (bloc) => bloc.add(const CheckSession()),
      expect: () => [isA<Unauthenticated>()],
    );
  });

  // -------------------------------------------------------------------------
  // AuthLogin
  // -------------------------------------------------------------------------
  group('AuthLogin', () {
    blocTest<AuthBloc, AuthState>(
      'on success emits [AuthLoading, Authenticated]',
      build: () {
        when(() => mockLogin(any())).thenAnswer((_) async => Right(tTokenPair));
        when(() => mockGetProfile(any())).thenAnswer((_) async => Right(tUser));
        return makeBloc();
      },
      act: (bloc) => bloc.add(const AuthLogin(
        email: 'ahmad@test.com',
        password: 'secret123',
      )),
      expect: () => [isA<AuthLoading>(), isA<Authenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'on UnauthorizedFailure emits [AuthLoading, AuthError]',
      build: () {
        when(() => mockLogin(any())).thenAnswer(
          (_) async => Left(const UnauthorizedFailure()),
        );
        return makeBloc();
      },
      act: (bloc) => bloc.add(const AuthLogin(
        email: 'a@b.com',
        password: 'wrong',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
      verify: (bloc) {
        final error = bloc.state as AuthError;
        expect(error.failure, isA<UnauthorizedFailure>());
      },
    );

    blocTest<AuthBloc, AuthState>(
      'on RateLimitedFailure emits [AuthLoading, AuthError] with retryAfter',
      build: () {
        when(() => mockLogin(any())).thenAnswer(
          (_) async => Left(const RateLimitedFailure(retryAfterSeconds: 60)),
        );
        return makeBloc();
      },
      act: (bloc) => bloc.add(const AuthLogin(
        email: 'a@b.com',
        password: 'pass',
      )),
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
      verify: (bloc) {
        final error = bloc.state as AuthError;
        expect(error.failure, isA<RateLimitedFailure>());
        expect((error.failure as RateLimitedFailure).retryAfterSeconds, 60);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'on ValidationFailure emits [AuthLoading, AuthError]',
      build: () {
        when(() => mockLogin(any())).thenAnswer(
          (_) async => Left(ValidationFailure(fieldErrors: {})),
        );
        return makeBloc();
      },
      act: (bloc) => bloc.add(const AuthLogin(email: '', password: '')),
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
    );
  });

  // -------------------------------------------------------------------------
  // AuthRegister
  // -------------------------------------------------------------------------
  group('AuthRegister', () {
    blocTest<AuthBloc, AuthState>(
      'on success emits [AuthLoading, RegisterSuccess]',
      build: () {
        when(() => mockRegister(any())).thenAnswer((_) async => Right(tUser));
        return makeBloc();
      },
      act: (bloc) => bloc.add(const AuthRegister(
        name: 'Ahmad',
        email: 'ahmad@test.com',
        password: 'secret123',
        passwordConfirmation: 'secret123',
      )),
      expect: () => [isA<AuthLoading>(), isA<RegisterSuccess>()],
      verify: (bloc) {
        expect((bloc.state as RegisterSuccess).email, tUser.email);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'on failure emits [AuthLoading, AuthError]',
      build: () {
        when(() => mockRegister(any())).thenAnswer(
          (_) async => Left(ValidationFailure(fieldErrors: {})),
        );
        return makeBloc();
      },
      act: (bloc) => bloc.add(const AuthRegister(
        name: 'A',
        email: 'a@b.com',
        password: 'short',
        passwordConfirmation: 'short',
      )),
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
    );
  });

  // -------------------------------------------------------------------------
  // AuthLogout
  // -------------------------------------------------------------------------
  group('AuthLogout', () {
    blocTest<AuthBloc, AuthState>(
      'emits Unauthenticated',
      build: () {
        when(() => mockTokenStorage.getRefreshToken())
            .thenAnswer((_) async => 'ref_tok');
        when(() => mockLogout(any()))
            .thenAnswer((_) async => const Right(null));
        return makeBloc();
      },
      act: (bloc) => bloc.add(const AuthLogout()),
      expect: () => [isA<Unauthenticated>()],
    );
  });

  // -------------------------------------------------------------------------
  // AuthSessionExpired
  // -------------------------------------------------------------------------
  group('AuthSessionExpired', () {
    blocTest<AuthBloc, AuthState>(
      'clears tokens and emits Unauthenticated',
      build: () {
        when(() => mockTokenStorage.clearTokens()).thenAnswer((_) async {});
        return makeBloc();
      },
      act: (bloc) => bloc.add(const AuthSessionExpired()),
      expect: () => [isA<Unauthenticated>()],
      verify: (_) {
        verify(() => mockTokenStorage.clearTokens()).called(1);
      },
    );
  });
}
