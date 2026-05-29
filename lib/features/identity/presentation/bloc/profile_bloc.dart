import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/change_password.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_profile.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfile _getProfile;
  final UpdateProfile _updateProfile;
  final ChangePassword _changePassword;

  ProfileBloc({
    required GetProfile getProfile,
    required UpdateProfile updateProfile,
    required ChangePassword changePassword,
  })  : _getProfile = getProfile,
        _updateProfile = updateProfile,
        _changePassword = changePassword,
        super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfileName>(_onUpdateProfile);
    on<ProfileChangePassword>(_onChangePassword);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await _getProfile(const NoParams());
    result.fold(
      (failure) => emit(ProfileError(failure)),
      (user) => emit(ProfileLoaded(user)),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfileName event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state is ProfileLoaded ? (state as ProfileLoaded).user : null;
    final result = await _updateProfile(UpdateProfileParams(name: event.name));
    result.fold(
      (failure) => emit(ProfileError(failure, currentUser: current)),
      (user) => emit(ProfileLoaded(user)),
    );
  }

  Future<void> _onChangePassword(
    ProfileChangePassword event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state is ProfileLoaded ? (state as ProfileLoaded).user : null;
    final result = await _changePassword(
      ChangePasswordParams(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
        newPasswordConfirmation: event.newPasswordConfirmation,
      ),
    );
    result.fold(
      (failure) => emit(ProfileError(failure, currentUser: current)),
      (_) => emit(const PasswordChanged()),
    );
  }
}
