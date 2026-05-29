import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/ai_request.dart';

class AIRequestCard extends StatelessWidget {
  final AIRequest request;
  final VoidCallback? onTap;

  const AIRequestCard({super.key, required this.request, this.onTap});

  Color get _typeColor => switch (request.type) {
        AIRequestType.enrich_definition => AppColors.primary,
        AIRequestType.suggest_example => AppColors.wcAdjektiva,
        AIRequestType.suggest_related => AppColors.wcAdverbia,
        AIRequestType.quality_check => AppColors.ai,
      };

  Color get _statusColor => switch (request.status) {
        AIRequestStatus.pending => AppColors.warning,
        AIRequestStatus.completed => AppColors.success,
        AIRequestStatus.failed => AppColors.error,
      };

  String get _statusLabel => switch (request.status) {
        AIRequestStatus.pending => 'Menunggu',
        AIRequestStatus.completed => 'Selesai',
        AIRequestStatus.failed => 'Gagal',
      };

  Color get _reviewColor => switch (request.reviewStatus) {
        AIReviewStatus.unreviewed => Colors.grey,
        AIReviewStatus.approved => AppColors.success,
        AIReviewStatus.rejected => AppColors.error,
      };

  String get _reviewLabel => switch (request.reviewStatus) {
        AIReviewStatus.unreviewed => 'Belum Ditinjau',
        AIReviewStatus.approved => 'Disetujui',
        AIReviewStatus.rejected => 'Ditolak',
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
                    key: Key('type_badge_${request.type.name}'),
                    label: request.type.label,
                    color: _typeColor,
                  ),
                  const SizedBox(width: 6),
                  // Status badge
                  _Badge(
                    label: _statusLabel,
                    color: _statusColor,
                  ),
                  if (request.status == AIRequestStatus.failed) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.error_outline,
                      key: Key('failed_indicator'),
                      size: 16,
                      color: AppColors.error,
                    ),
                  ],
                  const Spacer(),
                  _Badge(label: _reviewLabel, color: _reviewColor),
                ],
              ),
              const SizedBox(height: 6),
              if (request.targetWordId != null)
                Text(
                  'Kata: ${request.targetWordId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              if (request.targetContributionId != null)
                Text(
                  'Kontribusi: ${request.targetContributionId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              Text(
                '${request.createdAt.day}/${request.createdAt.month}/${request.createdAt.year}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
