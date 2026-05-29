import 'dart:async';

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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(_onTextChanged);
    _passwordCtrl.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    _emailCtrl.removeListener(_onTextChanged);
    _passwordCtrl.removeListener(_onTextChanged);
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _emailCtrl.text.trim().isNotEmpty && _passwordCtrl.text.isNotEmpty;

  void _submit(BuildContext context) {
    context.read<AuthBloc>().add(AuthLogin(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.go(Routes.home);
        } else if (state is RegisterSuccess) {
          context.go(
            '${Routes.verifyEmail}?email=${Uri.encodeComponent(state.email)}',
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final failure = state is AuthError ? state.failure : null;

        final emailError = failure is ValidationFailure
            ? failure.fieldErrors['email']?.firstOrNull
            : null;
        final passwordError = failure is ValidationFailure
            ? failure.fieldErrors['password']?.firstOrNull
            : null;
        final rateLimitFailure =
            failure is RateLimitedFailure ? failure : null;
        final generalError = failure != null &&
                failure is! ValidationFailure &&
                failure is! RateLimitedFailure
            ? failure.message
            : null;

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    'Banjarin',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Kamus Bahasa Banjar',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
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
                    textInputAction: TextInputAction.done,
                    errorText: passwordError,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push(Routes.forgotPassword),
                      child: const Text('Lupa kata sandi?'),
                    ),
                  ),
                  if (generalError != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      generalError,
                      key: const Key('general_error'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (rateLimitFailure != null) ...[
                    const SizedBox(height: 4),
                    _RateLimitCountdown(
                      key: const Key('rate_limit_countdown'),
                      retryAfterSeconds: rateLimitFailure.retryAfterSeconds,
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    key: const Key('login_button'),
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
                        : const Text('Masuk'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun?',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => context.push(Routes.register),
                        child: const Text('Daftar'),
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

class _RateLimitCountdown extends StatefulWidget {
  final int retryAfterSeconds;

  const _RateLimitCountdown({
    super.key,
    required this.retryAfterSeconds,
  });

  @override
  State<_RateLimitCountdown> createState() => _RateLimitCountdownState();
}

class _RateLimitCountdownState extends State<_RateLimitCountdown> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.retryAfterSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining > 0) {
        setState(() => _remaining--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remaining ~/ 60;
    final seconds = _remaining % 60;
    final timeStr = minutes > 0
        ? '$minutes menit ${seconds.toString().padLeft(2, '0')} detik'
        : '$_remaining detik';

    return Text(
      'Terlalu banyak percobaan. Coba lagi dalam $timeStr.',
      style: TextStyle(
        color: Theme.of(context).colorScheme.error,
        fontSize: 13,
      ),
      textAlign: TextAlign.center,
    );
  }
}
