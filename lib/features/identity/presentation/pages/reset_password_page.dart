import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../domain/usecases/reset_password.dart';
import '../widgets/password_field.dart';

class ResetPasswordPage extends StatefulWidget {
  final String token;
  final ResetPassword? resetPasswordUseCase;

  const ResetPasswordPage({
    super.key,
    required this.token,
    this.resetPasswordUseCase,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _error;
  bool _loading = false;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _passwordCtrl.addListener(_onTextChanged);
    _confirmCtrl.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() => _error = null);

  @override
  void dispose() {
    _passwordCtrl.removeListener(_onTextChanged);
    _confirmCtrl.removeListener(_onTextChanged);
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _passwordCtrl.text.isNotEmpty && _confirmCtrl.text.isNotEmpty;

  Future<void> _submit() async {
    if (_passwordCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Kata sandi tidak cocok');
      return;
    }
    setState(() => _loading = true);
    try {
      final useCase = widget.resetPasswordUseCase;
      if (useCase == null) return;
      final result = await useCase(ResetPasswordParams(
        token: widget.token,
        password: _passwordCtrl.text,
        passwordConfirmation: _confirmCtrl.text,
      ));
      if (!mounted) return;
      result.fold(
        (failure) => setState(() {
          _loading = false;
          _error = failure.message;
        }),
        (_) => setState(() {
          _loading = false;
          _success = true;
        }),
      );
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reset Kata Sandi')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.check_circle_outline, size: 64, color: Color(0xFF27AE60)),
                const SizedBox(height: 16),
                Text(
                  'Kata sandi berhasil direset.',
                  key: const Key('success_message'),
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go(Routes.login),
                  child: const Text('Masuk Sekarang'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Kata Sandi')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Masukkan kata sandi baru untuk akunmu.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              PasswordField(
                key: const Key('password_field'),
                controller: _passwordCtrl,
                label: 'Kata Sandi Baru',
                textInputAction: TextInputAction.next,
                enabled: !_loading,
              ),
              const SizedBox(height: 16),
              PasswordField(
                key: const Key('confirm_field'),
                controller: _confirmCtrl,
                label: 'Konfirmasi Kata Sandi',
                textInputAction: TextInputAction.done,
                errorText: _error,
                enabled: !_loading,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                key: const Key('submit_button'),
                onPressed: _canSubmit && !_loading ? _submit : null,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Reset Kata Sandi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
