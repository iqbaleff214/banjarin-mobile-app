import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/ai_request.dart';
import '../bloc/ai_request_bloc.dart';
import '../bloc/ai_request_event.dart';
import '../bloc/ai_request_state.dart';
import '../widgets/admin_guard.dart';
import '../widgets/ai_parsed_output_view.dart';

class AdminAIRequestDetailPage extends StatelessWidget {
  final String requestId;

  const AdminAIRequestDetailPage({super.key, required this.requestId});

  AIRequest? _findRequest(AIRequestState state) {
    final requests = switch (state) {
      AIRequestLoaded(requests: final r) => r,
      Reviewing(currentRequests: final r) => r,
      Reviewed(requests: final r) => r,
      _ => <AIRequest>[],
    };
    return requests.where((r) => r.id == requestId).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: BlocListener<AIRequestBloc, AIRequestState>(
        listener: (context, state) {
          if (state is Reviewed && state.reviewedId == requestId) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Berhasil ditinjau.')),
            );
          } else if (state is AIRequestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.failure.message)),
            );
          }
        },
        child: BlocBuilder<AIRequestBloc, AIRequestState>(
          builder: (context, state) {
            final request = _findRequest(state);
            final isReviewing = state is Reviewing;

            return Scaffold(
              appBar: AppBar(title: const Text('Detail Permintaan AI')),
              body: request == null
                  ? const Center(child: Text('Permintaan tidak ditemukan.'))
                  : _DetailBody(
                      request: request,
                      isReviewing: isReviewing,
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final AIRequest request;
  final bool isReviewing;

  const _DetailBody({required this.request, required this.isReviewing});

  bool get _canApproveReject =>
      request.type != AIRequestType.quality_check &&
      request.reviewStatus == AIReviewStatus.unreviewed;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info section
          _InfoRow('Tipe', request.type.label),
          _InfoRow('Status Job', request.status.name),
          _InfoRow('Status Review', request.reviewStatus.name),
          _InfoRow('Model', request.model),
          if (request.targetWordId != null)
            _InfoRow('Target Kata', request.targetWordId!),
          _InfoRow(
            'Dibuat',
            '${request.createdAt.day}/${request.createdAt.month}/${request.createdAt.year}',
          ),
          const SizedBox(height: 20),
          const Divider(),
          // Parsed output
          Text(
            'Output AI',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          AIParsedOutputView(
            type: request.type,
            parsedOutput: request.parsedOutput,
          ),
          const SizedBox(height: 24),
          // Approve/Reject buttons — hidden for quality_check
          if (request.type != AIRequestType.quality_check) ...[
            const Divider(),
            // Approve button — disabled when not unreviewed
            ElevatedButton(
              key: const Key('approve_button'),
              onPressed: _canApproveReject && !isReviewing
                  ? () => _confirmApprove(context)
                  : null,
              child: const Text('Setujui & Gabungkan'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              key: const Key('reject_button'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(
                  color: _canApproveReject ? AppColors.error : Colors.grey,
                ),
              ),
              onPressed: _canApproveReject && !isReviewing
                  ? () => _confirmReject(context)
                  : null,
              child: const Text('Tolak'),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmApprove(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Setujui Output AI'),
        content: const Text(
            'Output AI akan digabungkan ke kamus. Yakin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AIRequestBloc>().add(ApproveAIRequestEvent(
                    requestId: request.id,
                    type: request.type,
                    reviewStatus: request.reviewStatus,
                  ));
            },
            child: const Text('Setujui'),
          ),
        ],
      ),
    );
  }

  void _confirmReject(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Output AI'),
        content: const Text('Output AI akan ditolak. Yakin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AIRequestBloc>().add(
                    RejectAIRequestEvent(request.id),
                  );
            },
            child: Text(
              'Tolak',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
