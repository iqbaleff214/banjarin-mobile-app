import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/definition.dart';
import 'source_badge.dart';

class DefinitionTile extends StatelessWidget {
  final int index;
  final Definition definition;
  final bool showVotes;

  const DefinitionTile({
    super.key,
    required this.index,
    required this.definition,
    this.showVotes = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$index.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  definition.meaning,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    SourceBadge(source: definition.source),
                    if (showVotes || !definition.source.isSeeded) ...[
                      const Spacer(),
                      _VoteCount(
                        upvotes: definition.upvotes,
                        downvotes: definition.downvotes,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VoteCount extends StatelessWidget {
  final int upvotes;
  final int downvotes;

  const _VoteCount({required this.upvotes, required this.downvotes});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.arrow_upward, size: 12, color: AppColors.success),
        Text('$upvotes', style: const TextStyle(fontSize: 11)),
        const SizedBox(width: 4),
        const Icon(Icons.arrow_downward, size: 12, color: AppColors.error),
        Text('$downvotes', style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
