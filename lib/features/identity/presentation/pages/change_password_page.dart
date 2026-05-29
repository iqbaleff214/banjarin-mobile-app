import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/password_field.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _currentCtrl.text.isNotEmpty &&
      _newCtrl.text.isNotEmpty &&
      _confirmCtrl.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is PasswordChanged) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kata sandi berhasil diubah.')),
          );
          context.pop();
        }
      },
      builder: (context, state) {
        final isLoading = state is ProfileLoading;
        final failure = state is ProfileError ? state.failure : null;

        final currentError = failure is ValidationFailure
            ? failure.fieldErrors['current_password']?.firstOrNull
            : null;
        final newError = failure is ValidationFailure
            ? failure.fieldErrors['password']?.firstOrNull
            : null;
        final confirmError = failure is ValidationFailure
            ? failure.fieldErrors['password_confirmation']?.firstOrNull
            : null;
        final generalError = failure != null && failure is! ValidationFailure
            ? failure.message
            : null;

        return Scaffold(
          appBar: AppBar(title: const Text('Ubah Kata Sandi')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PasswordField(
                  key: const Key('current_password_field'),
                  controller: _currentCtrl,
                  label: 'Kata Sandi Saat Ini',
                  textInputAction: TextInputAction.next,
                  errorText: currentError,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                PasswordField(
                  key: const Key('new_password_field'),
                  controller: _newCtrl,
                  label: 'Kata Sandi Baru',
                  textInputAction: TextInputAction.next,
                  errorText: newError,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                PasswordField(
                  key: const Key('confirm_password_field'),
                  controller: _confirmCtrl,
                  label: 'Konfirmasi Kata Sandi Baru',
                  textInputAction: TextInputAction.done,
                  errorText: confirmError,
                  enabled: !isLoading,
                ),
                if (generalError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    generalError,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  key: const Key('save_button'),
                  onPressed: _canSubmit && !isLoading
                      ? () => context.read<ProfileBloc>().add(
                            ProfileChangePassword(
                              currentPassword: _currentCtrl.text,
                              newPassword: _newCtrl.text,
                              newPasswordConfirmation: _confirmCtrl.text,
                            ),
                          )
                      : null,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Ubah Kata Sandi'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
