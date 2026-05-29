import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../identity/presentation/bloc/auth_bloc.dart';
import '../../../identity/presentation/bloc/auth_state.dart';
import '../bloc/translate_bloc.dart';
import '../bloc/translate_event.dart';
import '../bloc/translate_state.dart';
import '../widgets/translation_result_card.dart';

class TerjemahPage extends StatefulWidget {
  const TerjemahPage({super.key});

  @override
  State<TerjemahPage> createState() => _TerjemahPageState();
}

class _TerjemahPageState extends State<TerjemahPage> {
  final _textCtrl = TextEditingController();
  final _contextCtrl = TextEditingController();
  bool _showContextField = false;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _textCtrl.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() => _charCount = _textCtrl.text.length);

  @override
  void dispose() {
    _textCtrl.removeListener(_onTextChanged);
    _textCtrl.dispose();
    _contextCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit => _charCount > 0;

  void _submit(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final isAuth = authState is Authenticated;

    if (!isAuth) {
      context.push(Routes.login);
      return;
    }

    context.read<TranslateBloc>().add(Translate(
          text: _textCtrl.text.trim(),
          context: _contextCtrl.text.trim().isEmpty
              ? null
              : _contextCtrl.text.trim(),
          isAuthenticated: true,
        ));
  }

  @override
  Widget build(BuildContext context) {
    // Redirect guest to login
    final authState = context.watch<AuthBloc>().state;
    if (authState is! Authenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Terjemah')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Masuk untuk menggunakan fitur terjemah.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.push(Routes.login),
                child: const Text('Masuk'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terjemah'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: 'Bersihkan',
            onPressed: () {
              _textCtrl.clear();
              _contextCtrl.clear();
              context.read<TranslateBloc>().add(const ClearTranslation());
            },
          ),
        ],
      ),
      body: BlocBuilder<TranslateBloc, TranslateState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Text input
                TextField(
                  key: const Key('text_input'),
                  controller: _textCtrl,
                  maxLines: 5,
                  maxLength: 1000,
                  textInputAction: TextInputAction.done,
                  enabled: state is! Translating,
                  decoration: InputDecoration(
                    hintText: 'Masukkan teks Bahasa Banjar Hulu...',
                    counterText: '$_charCount/1000',
                    counterStyle: TextStyle(
                      color: _charCount > 900
                          ? AppColors.error
                          : Colors.grey,
                    ),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 8),
                // Context field (expandable)
                Row(
                  children: [
                    TextButton.icon(
                      icon: Icon(
                        _showContextField
                            ? Icons.expand_less
                            : Icons.expand_more,
                        size: 18,
                      ),
                      label: const Text('Konteks (opsional)'),
                      onPressed: () =>
                          setState(() => _showContextField = !_showContextField),
                    ),
                  ],
                ),
                if (_showContextField) ...[
                  TextField(
                    key: const Key('context_input'),
                    controller: _contextCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: percakapan informal, surat resmi...',
                    ),
                    enabled: state is! Translating,
                  ),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 8),
                // Submit button
                ElevatedButton(
                  key: const Key('translate_button'),
                  onPressed: _canSubmit && state is! Translating
                      ? () => _submit(context)
                      : null,
                  child: state is Translating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Terjemahkan'),
                ),
                const SizedBox(height: 24),
                // State-based content
                switch (state) {
                  TranslateSuccess(result: final r) =>
                    TranslationResultCard(key: const Key('result_card'), result: r),
                  TranslateError(failure: final f)
                      when f is! AIUnavailableFailure =>
                    _ErrorCard(message: f.message),
                  TranslateError() => const _AIUnavailableCard(),
                  RateLimited(retryAfterSeconds: final s) =>
                    _RateLimitCard(retryAfterSeconds: s),
                  Translating() => const Center(
                      key: Key('loading_indicator'),
                      child: CircularProgressIndicator(),
                    ),
                  _ => const SizedBox.shrink(),
                },
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper widgets
// ---------------------------------------------------------------------------

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.error.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AIUnavailableCard extends StatelessWidget {
  const _AIUnavailableCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.warning.withValues(alpha: 0.1),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.cloud_off, color: AppColors.warning),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Layanan AI sedang gangguan. Coba beberapa saat lagi.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RateLimitCard extends StatefulWidget {
  final int retryAfterSeconds;

  const _RateLimitCard({required this.retryAfterSeconds});

  @override
  State<_RateLimitCard> createState() => _RateLimitCardState();
}

class _RateLimitCardState extends State<_RateLimitCard> {
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

    return Card(
      key: const Key('rate_limit_card'),
      color: AppColors.warning.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.timer_outlined, color: AppColors.warning),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Batas permintaan tercapai. Coba lagi dalam $timeStr.',
                key: const Key('rate_limit_text'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

