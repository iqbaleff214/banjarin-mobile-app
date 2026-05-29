import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/contribution.dart';

class ContributionCard extends StatelessWidget {
  final Contribution contribution;
  final VoidCallback? onWithdraw;
  final VoidCallback? onTap;

  const ContributionCard({
    super.key,
    required this.contribution,
    this.onWithdraw,
    this.onTap,
  });

  Color get _statusColor => switch (contribution.status) {
        ContributionStatus.pending => AppColors.warning,
        ContributionStatus.approved => AppColors.success,
        ContributionStatus.rejected => AppColors.error,
        ContributionStatus.withdrawn => Colors.grey,
      };

  String get _statusLabel => switch (contribution.status) {
        ContributionStatus.pending => 'Menunggu',
        ContributionStatus.approved => 'Disetujui',
        ContributionStatus.rejected => 'Ditolak',
        ContributionStatus.withdrawn => 'Dicabut',
      };

  Color get _typeColor => switch (contribution.type) {
        ContributionType.new_word => AppColors.primary,
        ContributionType.new_definition => AppColors.community,
        ContributionType.new_example => AppColors.wcAdjektiva,
        ContributionType.edit_word => AppColors.wcAdverbia,
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Type badge
                  _Badge(
                    label: contribution.type.label,
                    color: _typeColor,
                  ),
                  const SizedBox(width: 6),
                  // Status badge
                  _Badge(
                    label: _statusLabel,
                    color: _statusColor,
                  ),
                  const Spacer(),
                  // Cabut button (pending only)
                  if (contribution.status == ContributionStatus.pending &&
                      onWithdraw != null)
                    TextButton(
                      key: const Key('withdraw_button'),
                      onPressed: onWithdraw,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(60, 32),
                      ),
                      child: const Text('Cabut'),
                    ),
                ],
              ),
              if (contribution.targetWordId != null) ...[
                const SizedBox(height: 6),
                Text(
                  'Untuk: ${contribution.payload['banjar'] ?? contribution.targetWordId}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                _formatDate(contribution.submittedAt),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey, fontSize: 11),
              ),
              // Reviewer note for rejected
              if (contribution.status == ContributionStatus.rejected &&
                  contribution.reviewerNote != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline,
                          size: 14, color: AppColors.error),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          key: const Key('reviewer_note'),
                          contribution.reviewerNote!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
