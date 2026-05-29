import 'package:banjarin/core/error/failures.dart';
import 'package:banjarin/core/usecase/usecase.dart';
import 'package:banjarin/features/identity/domain/entities/token_pair.dart';
import 'package:banjarin/features/identity/domain/entities/user.dart';
import 'package:banjarin/features/identity/domain/entities/user_role.dart';
import 'package:banjarin/features/identity/domain/repositories/auth_repository.dart';
import 'package:banjarin/features/identity/domain/usecases/change_password.dart';
import 'package:banjarin/features/identity/domain/usecases/forgot_password.dart';
import 'package:banjarin/features/identity/domain/usecases/get_profile.dart';
import 'package:banjarin/features/identity/domain/usecases/login.dart';
import 'package:banjarin/features/identity/domain/usecases/logout.dart';
import 'package:banjarin/features/identity/domain/usecases/refresh_token.dart';
import 'package:banjarin/features/identity/domain/usecases/register.dart';
import 'package:banjarin/features/identity/domain/usecases/reset_password.dart';
import 'package:banjarin/features/identity/domain/usecases/update_profile.dart';
import 'package:banjarin/features/identity/domain/usecases/verify_email.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;

  final tTokenPair = TokenPair(
    accessToken: 'acc',
    refreshToken: 'ref',
    expiresIn: 900,
  );
  final tUser = User(
    id: '1',
    name: 'Ahmad',
    email: 'ahmad@test.com',
    role: UserRole.user,
    isActive: true,
    createdAt: DateTime(2024),
  );

  setUp(() => mockRepo = MockAuthRepository());

  // -------------------------------------------------------------------------
  // Login
  // -------------------------------------------------------------------------
  group('Login', () {
    late Login login;
    setUp(() => login = Login(mockRepo));

    test('when credentials are valid delegates to repository', () async {
      when(() => mockRepo.login(email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async => Right(tTokenPair));

      final result = await login(const LoginParams(
        email: 'ahmad@test.com',
        password: 'secret123',
      ));

      expect(result.isRight(), isTrue);
    });

    test('when password is empty returns ValidationFailure', () async {
      final result = await login(const LoginParams(
        email: 'a@b.com',
        password: '',
      ));
      expect(result.isLeft(), isTrue);
      expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
    });

    test('when email is malformed returns ValidationFailure', () async {
      final result = await login(const LoginParams(
        email: 'not-an-email',
        password: 'secret123',
      ));
      expect(result.isLeft(), isTrue);
      expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
    });

    test('when email is empty returns ValidationFailure', () async {
      final result = await login(const LoginParams(
        email: '',
        password: 'secret123',
      ));
      expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
    });
  });

  // -------------------------------------------------------------------------
  // Register
  // -------------------------------------------------------------------------
  group('Register', () {
    late Register register;
    setUp(() => register = Register(mockRepo));

    test('when params are valid delegates to repository', () async {
      when(() => mockRepo.register(
            name: any(named: 'name'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => Right(tUser));

      final result = await register(const RegisterParams(
        name: 'Ahmad',
        email: 'ahmad@test.com',
        password: 'secret123',
        passwordConfirmation: 'secret123',
      ));

      expect(result.isRight(), isTrue);
    });

    test('when password is less than 8 chars returns ValidationFailure', () async {
      final result = await register(const RegisterParams(
        name: 'Ahmad',
        email: 'a@b.com',
        password: 'short',
        passwordConfirmation: 'short',
      ));
      expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
    });

    test('when password and confirmation mismatch returns ValidationFailure',
        () async {
      final result = await register(const RegisterParams(
        name: 'Ahmad',
        email: 'a@b.com',
        password: 'secret123',
        passwordConfirmation: 'different',
      ));
      expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
    });
  });

  // -------------------------------------------------------------------------
  // Logout
  // -------------------------------------------------------------------------
  group('Logout', () {
    late Logout logout;
    setUp(() => logout = Logout(mockRepo));

    test('delegates to repository', () async {
      when(() => mockRepo.logout(refreshToken: any(named: 'refreshToken')))
          .thenAnswer((_) async => const Right(null));

      final result = await logout(const LogoutParams(refreshToken: 'tok'));
      expect(result.isRight(), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // RefreshToken
  // -------------------------------------------------------------------------
  group('RefreshToken', () {
    late RefreshToken refreshToken;
    setUp(() => refreshToken = RefreshToken(mockRepo));

    test('delegates to repository with refresh token', () async {
      when(() => mockRepo.refreshToken(refreshToken: any(named: 'refreshToken')))
          .thenAnswer((_) async => Right(tTokenPair));

      final result = await refreshToken(
        const RefreshTokenParams(refreshToken: 'old_refresh'),
      );
      expect(result.isRight(), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // GetProfile
  // -------------------------------------------------------------------------
  group('GetProfile', () {
    late GetProfile getProfile;
    setUp(() => getProfile = GetProfile(mockRepo));

    test('delegates to repository', () async {
      when(() => mockRepo.getProfile()).thenAnswer((_) async => Right(tUser));

      final result = await getProfile(const NoParams());
      expect(result.isRight(), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // UpdateProfile
  // -------------------------------------------------------------------------
  group('UpdateProfile', () {
    late UpdateProfile updateProfile;
    setUp(() => updateProfile = UpdateProfile(mockRepo));

    test('when name is less than 2 chars returns ValidationFailure', () async {
      final result = await updateProfile(const UpdateProfileParams(name: 'A'));
      expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
    });

    test('when name is valid delegates to repository', () async {
      when(() => mockRepo.updateProfile(name: any(named: 'name')))
          .thenAnswer((_) async => Right(tUser));

      final result = await updateProfile(
        const UpdateProfileParams(name: 'Ahmad'),
      );
      expect(result.isRight(), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // ChangePassword
  // -------------------------------------------------------------------------
  group('ChangePassword', () {
    late ChangePassword changePassword;
    setUp(() => changePassword = ChangePassword(mockRepo));

    test('when new password is less than 8 chars returns ValidationFailure',
        () async {
      final result = await changePassword(const ChangePasswordParams(
        currentPassword: 'old_pass',
        newPassword: 'short',
        newPasswordConfirmation: 'short',
      ));
      expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
    });

    test('when new passwords mismatch returns ValidationFailure', () async {
      final result = await changePassword(const ChangePasswordParams(
        currentPassword: 'old_pass',
        newPassword: 'newpass123',
        newPasswordConfirmation: 'different',
      ));
      expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
    });

    test('when params are valid delegates to repository', () async {
      when(() => mockRepo.changePassword(
            currentPassword: any(named: 'currentPassword'),
            password: any(named: 'password'),
            passwordConfirmation: any(named: 'passwordConfirmation'),
          )).thenAnswer((_) async => const Right(null));

      final result = await changePassword(const ChangePasswordParams(
        currentPassword: 'old_pass',
        newPassword: 'newpass123',
        newPasswordConfirmation: 'newpass123',
      ));
      expect(result.isRight(), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // ForgotPassword
  // -------------------------------------------------------------------------
  group('ForgotPassword', () {
    late ForgotPassword forgotPassword;
    setUp(() => forgotPassword = ForgotPassword(mockRepo));

    test('delegates to repository with email', () async {
      when(() => mockRepo.forgotPassword(email: any(named: 'email')))
          .thenAnswer((_) async => const Right(null));

      final result = await forgotPassword(
        const ForgotPasswordParams(email: 'a@b.com'),
      );
      expect(result.isRight(), isTrue);
      verify(() => mockRepo.forgotPassword(email: 'a@b.com')).called(1);
    });
  });

  // -------------------------------------------------------------------------
  // ResetPassword
  // -------------------------------------------------------------------------
  group('ResetPassword', () {
    late ResetPassword resetPassword;
    setUp(() => resetPassword = ResetPassword(mockRepo));

    test('when token is empty returns ValidationFailure', () async {
      final result = await resetPassword(const ResetPasswordParams(
        token: '',
        password: 'newpass123',
        passwordConfirmation: 'newpass123',
      ));
      expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
    });

    test('when passwords mismatch returns ValidationFailure', () async {
      final result = await resetPassword(const ResetPasswordParams(
        token: 'valid_token',
        password: 'newpass123',
        passwordConfirmation: 'different',
      ));
      expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
    });

    test('when new password is less than 8 chars returns ValidationFailure',
        () async {
      final result = await resetPassword(const ResetPasswordParams(
        token: 'tok',
        password: 'short',
        passwordConfirmation: 'short',
      ));
      expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
    });

    test('when params are valid delegates to repository', () async {
      when(() => mockRepo.resetPassword(
            token: any(named: 'token'),
            password: any(named: 'password'),
            passwordConfirmation: any(named: 'passwordConfirmation'),
          )).thenAnswer((_) async => const Right(null));

      final result = await resetPassword(const ResetPasswordParams(
        token: 'valid_token',
        password: 'newpass123',
        passwordConfirmation: 'newpass123',
      ));
      expect(result.isRight(), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // VerifyEmail
  // -------------------------------------------------------------------------
  group('VerifyEmail', () {
    late VerifyEmail verifyEmail;
    setUp(() => verifyEmail = VerifyEmail(mockRepo));

    test('delegates to repository with token', () async {
      when(() => mockRepo.verifyEmail(token: any(named: 'token')))
          .thenAnswer((_) async => const Right(null));

      final result = await verifyEmail(
        const VerifyEmailParams(token: 'my_token'),
      );
      expect(result.isRight(), isTrue);
      verify(() => mockRepo.verifyEmail(token: 'my_token')).called(1);
    });
  });
}
