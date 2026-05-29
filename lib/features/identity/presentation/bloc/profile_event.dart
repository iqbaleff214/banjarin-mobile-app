import 'package:equatable/equatable.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();
}

final class LoadProfile extends ProfileEvent {
  const LoadProfile();

  @override
  List<Object?> get props => [];
}

final class UpdateProfileName extends ProfileEvent {
  final String name;

  const UpdateProfileName(this.name);

  @override
  List<Object?> get props => [name];
}

final class ProfileChangePassword extends ProfileEvent {
  final String currentPassword;
  final String newPassword;
  final String newPasswordConfirmation;

  const ProfileChangePassword({
    required this.currentPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword, newPasswordConfirmation];
}
