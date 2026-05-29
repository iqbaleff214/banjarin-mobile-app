import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _localConfirmError;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(_onTextChanged);
    _emailCtrl.addListener(_onTextChanged);
    _passwordCtrl.addListener(_onTextChanged);
    _confirmCtrl.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() => _localConfirmError = null);

  @override
  void dispose() {
    _nameCtrl.removeListener(_onTextChanged);
    _emailCtrl.removeListener(_onTextChanged);
    _passwordCtrl.removeListener(_onTextChanged);
    _confirmCtrl.removeListener(_onTextChanged);
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _nameCtrl.text.trim().isNotEmpty &&
      _emailCtrl.text.trim().isNotEmpty &&
      _passwordCtrl.text.isNotEmpty &&
      _confirmCtrl.text.isNotEmpty;

  void _submit(BuildContext context) {
    if (_passwordCtrl.text != _confirmCtrl.text) {
      setState(() => _localConfirmError = 'Kata sandi tidak cocok');
      return;
    }
    context.read<AuthBloc>().add(AuthRegister(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          passwordConfirmation: _confirmCtrl.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          context.go(
            '${Routes.verifyEmail}?email=${Uri.encodeComponent(state.email)}',
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final failure = state is AuthError ? state.failure : null;

        final nameError = failure is ValidationFailure
            ? failure.fieldErrors['name']?.firstOrNull
            : null;
        final emailError = failure is ValidationFailure
            ? failure.fieldErrors['email']?.firstOrNull
            : null;
        final passwordError = failure is ValidationFailure
            ? failure.fieldErrors['password']?.firstOrNull
            : null;
        final confirmError = _localConfirmError ??
            (failure is ValidationFailure
                ? failure.fieldErrors['password_confirmation']?.firstOrNull
                : null);
        final generalError = failure != null && failure is! ValidationFailure
            ? failure.message
            : null;

        return Scaffold(
          appBar: AppBar(title: const Text('Daftar')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Buat Akun',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bergabung dan mulai berkontribusi.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  AuthTextField(
                    key: const Key('name_field'),
                    controller: _nameCtrl,
                    label: 'Nama Lengkap',
                    textInputAction: TextInputAction.next,
                    errorText: nameError,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    key: const Key('email_field'),
                    controller: _emailCtrl,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    errorText: emailError,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  PasswordField(
                    key: const Key('password_field'),
                    controller: _passwordCtrl,
                    label: 'Kata Sandi',
                    textInputAction: TextInputAction.next,
                    errorText: passwordError,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  PasswordField(
                    key: const Key('confirm_field'),
                    controller: _confirmCtrl,
                    label: 'Konfirmasi Kata Sandi',
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
                    key: const Key('register_button'),
                    onPressed: _canSubmit && !isLoading ? () => _submit(context) : null,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Daftar'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sudah punya akun?',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('Masuk'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
