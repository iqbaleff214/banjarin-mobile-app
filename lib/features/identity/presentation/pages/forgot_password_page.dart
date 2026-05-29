import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/usecases/forgot_password.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  final ForgotPassword? forgotPasswordUseCase;

  const ForgotPasswordPage({super.key, this.forgotPasswordUseCase});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailCtrl = TextEditingController();
  bool _submitted = false;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final useCase = widget.forgotPasswordUseCase;
      if (useCase != null) {
        await useCase(ForgotPasswordParams(email: _emailCtrl.text.trim()));
      }
    } catch (_) {
      // Always show success (privacy-safe)
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _submitted = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lupa Kata Sandi')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _submitted
              ? _SuccessView(email: _emailCtrl.text.trim())
              : _FormView(
                  emailCtrl: _emailCtrl,
                  loading: _loading,
                  onSubmit: _submit,
                ),
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  final TextEditingController emailCtrl;
  final bool loading;
  final VoidCallback onSubmit;

  const _FormView({
    required this.emailCtrl,
    required this.loading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Masukkan email yang terdaftar. Kami akan mengirimkan tautan untuk mereset kata sandimu.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        AuthTextField(
          key: const Key('email_field'),
          controller: emailCtrl,
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          enabled: !loading,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          key: const Key('submit_button'),
          onPressed: loading ? null : onSubmit,
          child: loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Kirim Tautan Reset'),
        ),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String email;

  const _SuccessView({required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.mark_email_read_outlined, size: 64, color: AppColors.success),
        const SizedBox(height: 16),
        Text(
          'Tautan Reset Dikirim',
          key: const Key('success_title'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Jika akun ditemukan, tautan reset telah dikirim ke alamat email yang terdaftar.',
          key: const Key('success_message'),
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
