import 'package:banjarin/core/error/failures.dart';
import 'package:banjarin/core/usecase/usecase.dart';
import 'package:banjarin/features/identity/domain/entities/user.dart';
import 'package:banjarin/features/identity/domain/entities/user_role.dart';
import 'package:banjarin/features/identity/domain/usecases/change_password.dart';
import 'package:banjarin/features/identity/domain/usecases/get_profile.dart';
import 'package:banjarin/features/identity/domain/usecases/update_profile.dart';
import 'package:banjarin/features/identity/presentation/bloc/profile_bloc.dart';
import 'package:banjarin/features/identity/presentation/bloc/profile_event.dart';
import 'package:banjarin/features/identity/presentation/bloc/profile_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockGetProfile extends Mock implements GetProfile {}

class MockUpdateProfile extends Mock implements UpdateProfile {}

class MockChangePassword extends Mock implements ChangePassword {}

void main() {
  late MockGetProfile mockGetProfile;
  late MockUpdateProfile mockUpdateProfile;
  late MockChangePassword mockChangePassword;

  final tUser = User(
    id: '1',
    name: 'Ahmad',
    email: 'ahmad@test.com',
    role: UserRole.user,
    isActive: true,
    emailVerifiedAt: DateTime(2024),
    createdAt: DateTime(2024),
  );

  final tUpdatedUser = tUser.copyWith(name: 'Ahmad Fauzi');

  setUp(() {
    mockGetProfile = MockGetProfile();
    mockUpdateProfile = MockUpdateProfile();
    mockChangePassword = MockChangePassword();

    registerFallbackValue(const NoParams());
    registerFallbackValue(const UpdateProfileParams(name: ''));
    registerFallbackValue(const ChangePasswordParams(
      currentPassword: '',
      newPassword: '',
      newPasswordConfirmation: '',
    ));
  });

  ProfileBloc makeBloc() => ProfileBloc(
        getProfile: mockGetProfile,
        updateProfile: mockUpdateProfile,
        changePassword: mockChangePassword,
      );

  // -------------------------------------------------------------------------
  // LoadProfile
  // -------------------------------------------------------------------------
  group('LoadProfile', () {
    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileLoaded(user)]',
      build: () {
        when(() => mockGetProfile(any())).thenAnswer((_) async => Right(tUser));
        return makeBloc();
      },
      act: (bloc) => bloc.add(const LoadProfile()),
      expect: () => [isA<ProfileLoading>(), isA<ProfileLoaded>()],
      verify: (bloc) {
        expect((bloc.state as ProfileLoaded).user, tUser);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'on failure emits [ProfileLoading, ProfileError]',
      build: () {
        when(() => mockGetProfile(any())).thenAnswer(
          (_) async => Left(const NetworkFailure()),
        );
        return makeBloc();
      },
      act: (bloc) => bloc.add(const LoadProfile()),
      expect: () => [isA<ProfileLoading>(), isA<ProfileError>()],
    );
  });

  // -------------------------------------------------------------------------
  // UpdateProfileName
  // -------------------------------------------------------------------------
  group('UpdateProfileName', () {
    blocTest<ProfileBloc, ProfileState>(
      'on success emits ProfileLoaded with updated user',
      build: () {
        when(() => mockUpdateProfile(any()))
            .thenAnswer((_) async => Right(tUpdatedUser));
        return makeBloc();
      },
      seed: () => ProfileLoaded(tUser),
      act: (bloc) => bloc.add(const UpdateProfileName('Ahmad Fauzi')),
      expect: () => [isA<ProfileLoaded>()],
      verify: (bloc) {
        expect((bloc.state as ProfileLoaded).user.name, 'Ahmad Fauzi');
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'on failure emits ProfileError',
      build: () {
        when(() => mockUpdateProfile(any())).thenAnswer(
          (_) async => Left(ValidationFailure(fieldErrors: {})),
        );
        return makeBloc();
      },
      seed: () => ProfileLoaded(tUser),
      act: (bloc) => bloc.add(const UpdateProfileName('A')),
      expect: () => [isA<ProfileError>()],
    );
  });

  // -------------------------------------------------------------------------
  // ProfileChangePassword
  // -------------------------------------------------------------------------
  group('ProfileChangePassword', () {
    blocTest<ProfileBloc, ProfileState>(
      'on success emits PasswordChanged',
      build: () {
        when(() => mockChangePassword(any()))
            .thenAnswer((_) async => const Right(null));
        return makeBloc();
      },
      seed: () => ProfileLoaded(tUser),
      act: (bloc) => bloc.add(const ProfileChangePassword(
        currentPassword: 'old',
        newPassword: 'newpass123',
        newPasswordConfirmation: 'newpass123',
      )),
      expect: () => [isA<PasswordChanged>()],
    );

    blocTest<ProfileBloc, ProfileState>(
      'on ValidationFailure emits ProfileError',
      build: () {
        when(() => mockChangePassword(any())).thenAnswer(
          (_) async => Left(ValidationFailure(fieldErrors: {})),
        );
        return makeBloc();
      },
      seed: () => ProfileLoaded(tUser),
      act: (bloc) => bloc.add(const ProfileChangePassword(
        currentPassword: 'old',
        newPassword: 'short',
        newPasswordConfirmation: 'short',
      )),
      expect: () => [isA<ProfileError>()],
    );
  });
}
