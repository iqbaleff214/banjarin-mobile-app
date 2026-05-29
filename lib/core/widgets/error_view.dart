import 'package:flutter/material.dart';

import '../error/failures.dart';
import '../theme/app_colors.dart';

class ErrorView extends StatelessWidget {
  final Failure failure;
  final VoidCallback? onRetry;

  const ErrorView({super.key, required this.failure, this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (failure is RateLimitedFailure) {
      return _RateLimitedView(
        failure: failure as RateLimitedFailure,
      );
    }
    if (failure is AIUnavailableFailure) {
      return _AIUnavailableView();
    }
    if (failure is NotFoundFailure) {
      return _NotFoundView(onRetry: onRetry);
    }
    return _GenericErrorView(failure: failure, onRetry: onRetry);
  }
}

class _GenericErrorView extends StatelessWidget {
  final Failure failure;
  final VoidCallback? onRetry;

  const _GenericErrorView({required this.failure, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              failure.message,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: const Text('Coba Lagi'),
            ),
        ],
      ),
    );
  }
}

class _NotFoundView extends StatelessWidget {
  final VoidCallback? onRetry;
  const _NotFoundView({this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          const Text('Konten tidak ditemukan'),
          if (onRetry != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ],
      ),
    );
  }
}

class _RateLimitedView extends StatelessWidget {
  final RateLimitedFailure failure;
  const _RateLimitedView({required this.failure});

  @override
  Widget build(BuildContext context) {
    final minutes = failure.retryAfterSeconds ~/ 60;
    final timeStr = minutes > 0 ? '$minutes menit' : '${failure.retryAfterSeconds} detik';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Coba lagi dalam $timeStr.',
              key: const Key('rate_limit_message'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AIUnavailableView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.cloud_off, color: AppColors.warning),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Layanan AI sedang gangguan. Coba nanti.',
              key: Key('ai_unavailable_message'),
            ),
          ),
        ],
      ),
    );
  }
}
