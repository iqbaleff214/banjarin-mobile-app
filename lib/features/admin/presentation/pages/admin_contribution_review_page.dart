import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../community/domain/entities/contribution.dart';
import '../../domain/entities/ai_request.dart';
import '../bloc/ai_request_bloc.dart';
import '../bloc/ai_request_event.dart';
import '../bloc/ai_request_state.dart';
import '../bloc/moderation_bloc.dart';
import '../bloc/moderation_event.dart';
import '../bloc/moderation_state.dart';
import '../widgets/admin_guard.dart';

class AdminContributionReviewPage extends StatefulWidget {
  final String contributionId;

  const AdminContributionReviewPage({super.key, required this.contributionId});

  @override
  State<AdminContributionReviewPage> createState() =>
      _AdminContributionReviewPageState();
}

class _AdminContributionReviewPageState
    extends State<AdminContributionReviewPage> {
  final _rejectNoteCtrl = TextEditingController();

  @override
  void dispose() {
    _rejectNoteCtrl.dispose();
    super.dispose();
  }

  Contribution? _findContribution(ModerationState state) {
    final queue = switch (state) {
      ModerationLoaded(queue: final q) => q,
      ModerationApproving(currentQueue: final q) => q,
      ModerationRejecting(currentQueue: final q) => q,
      _ => <Contribution>[],
    };
    return queue.where((c) => c.id == widget.contributionId).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: BlocListener<ModerationBloc, ModerationState>(
        listener: (context, state) {
          if (state is ModerationApproved &&
              state.approvedId == widget.contributionId) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kontribusi disetujui.')),
            );
            context.pop();
          } else if (state is ModerationRejected &&
              state.rejectedId == widget.contributionId) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kontribusi ditolak.')),
            );
            context.pop();
          } else if (state is ModerationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.failure.message)),
            );
          }
        },
        child: BlocBuilder<ModerationBloc, ModerationState>(
          builder: (context, state) {
            final contribution = _findContribution(state);
            final isProcessing =
                state is ModerationApproving || state is ModerationRejecting;

            return Scaffold(
              appBar: AppBar(title: const Text('Review Kontribusi')),
              body: contribution == null
                  ? const Center(child: Text('Kontribusi tidak ditemukan.'))
                  : _ReviewBody(
                      contribution: contribution,
                      rejectNoteCtrl: _rejectNoteCtrl,
                      isProcessing: isProcessing,
                      contributionId: widget.contributionId,
                      onApprove: () => context.read<ModerationBloc>().add(
                            ApproveContributionEvent(
                              contributionId: widget.contributionId,
                            ),
                          ),
                      onReject: () {
                        if (_rejectNoteCtrl.text.trim().isEmpty) return;
                        context.read<ModerationBloc>().add(
                              RejectContributionEvent(
                                contributionId: widget.contributionId,
                                note: _rejectNoteCtrl.text.trim(),
                              ),
                            );
                      },
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _ReviewBody extends StatelessWidget {
  final Contribution contribution;
  final TextEditingController rejectNoteCtrl;
  final bool isProcessing;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final String contributionId;

  const _ReviewBody({
    required this.contribution,
    required this.rejectNoteCtrl,
    required this.isProcessing,
    required this.onApprove,
    required this.onReject,
    required this.contributionId,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Type + info
          _InfoRow('Tipe', contribution.type.label),
          _InfoRow('Kontributor', contribution.contributorId),
          if (contribution.targetWordId != null)
            _InfoRow('Target Kata', contribution.targetWordId!),
          const SizedBox(height: 16),
          // Payload
          Text('Isi Kontribusi',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('${contribution.payload}'),
          ),
          const SizedBox(height: 24),
          // Approve
          ElevatedButton(
            onPressed: isProcessing ? null : onApprove,
            child: const Text('Setujui'),
          ),
          const SizedBox(height: 12),
          // Reject note
          TextField(
            key: const Key('reject_note_field'),
            controller: rejectNoteCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Catatan Penolakan (wajib)',
              hintText: 'Jelaskan alasan penolakan...',
            ),
          ),
          const SizedBox(height: 8),
          // Tolak button — disabled when note is empty
          ListenableBuilder(
            listenable: rejectNoteCtrl,
            builder: (context, _) {
              final noteEmpty = rejectNoteCtrl.text.trim().isEmpty;
              return OutlinedButton(
                key: const Key('reject_button'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(
                    color: noteEmpty ? Colors.grey : AppColors.error,
                  ),
                ),
                onPressed: (noteEmpty || isProcessing) ? null : onReject,
                child: const Text('Tolak'),
              );
            },
          ),
          const SizedBox(height: 16),
          // AI Quality Check button
          _QualityCheckButton(contributionId: contributionId),
        ],
      ),
    );
  }
}

class _QualityCheckButton extends StatelessWidget {
  final String contributionId;
  const _QualityCheckButton({required this.contributionId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AIRequestBloc, AIRequestState>(
      listener: (context, state) {
        if (state is Triggered) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Quality check dikirim.'),
              action: SnackBarAction(
                label: 'Lihat',
                onPressed: () => context.push(Routes.adminAiRequests),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return OutlinedButton.icon(
          key: const Key('quality_check_button'),
          icon: const Icon(Icons.fact_check_outlined, size: 16),
          label: const Text('Quality Check AI'),
          onPressed: state is Triggering
              ? null
              : () => context.read<AIRequestBloc>().add(TriggerAIEvent(
                    type: AIRequestType.quality_check,
                    contributionId: contributionId,
                  )),
        );
      },
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value),
        ],
      ),
    );
  }
}
