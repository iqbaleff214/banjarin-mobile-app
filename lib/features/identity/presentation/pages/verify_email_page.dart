import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../domain/usecases/verify_email.dart';

class VerifyEmailPage extends StatefulWidget {
  final String email;
  final String? token;
  final VerifyEmail? verifyEmailUseCase;

  const VerifyEmailPage({
    super.key,
    required this.email,
    this.token,
    this.verifyEmailUseCase,
  });

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  @override
  void initState() {
    super.initState();
    if (widget.token != null && widget.token!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _verifyToken());
    }
  }

  Future<void> _verifyToken() async {
    final useCase = widget.verifyEmailUseCase;
    if (useCase == null) return;
    final result = await useCase(VerifyEmailParams(token: widget.token!));
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (_) => context.go(Routes.home),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.token != null && widget.token!.isNotEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.mark_email_unread_outlined,
                size: 72,
                color: Color(0xFF0D7377),
              ),
              const SizedBox(height: 24),
              Text(
                'Verifikasi Email',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Kami telah mengirim tautan verifikasi ke',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (widget.email.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  widget.email,
                  key: const Key('email_display'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Periksa kotak masuk atau folder spam-mu.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                key: const Key('open_email_button'),
                onPressed: () {
                  // url_launcher will be wired in Phase 8 polish
                },
                icon: const Icon(Icons.email_outlined),
                label: const Text('Buka Aplikasi Email'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go(Routes.login),
                child: const Text('Kembali ke Masuk'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
