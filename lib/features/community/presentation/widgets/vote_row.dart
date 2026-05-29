import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/vote.dart';
import '../bloc/vote_bloc.dart';
import '../bloc/vote_event.dart';
import '../bloc/vote_state.dart';

class VoteRow extends StatelessWidget {
  final String targetId;
  final VoteTargetType targetType;
  final bool isAuthenticated;
  final bool showCounts;

  const VoteRow({
    super.key,
    required this.targetId,
    required this.targetType,
    required this.isAuthenticated,
    this.showCounts = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VoteBloc, VoteState>(
      builder: (context, state) {
        final (currentVote, upvotes, downvotes) = _extract(state);
        final isVoting = state is Voting;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _VoteButton(
              icon: Icons.arrow_upward,
              count: upvotes,
              isActive: currentVote == VoteValue.up,
              activeColor: AppColors.success,
              isLoading: isVoting,
              showCount: showCounts,
              onTap: () => context.read<VoteBloc>().add(CastVoteEvent(
                    targetId: targetId,
                    targetType: targetType,
                    value: VoteValue.up,
                    isAuthenticated: isAuthenticated,
                  )),
            ),
            const SizedBox(width: 8),
            _VoteButton(
              icon: Icons.arrow_downward,
              count: downvotes,
              isActive: currentVote == VoteValue.down,
              activeColor: AppColors.error,
              isLoading: isVoting,
              showCount: showCounts,
              onTap: () => context.read<VoteBloc>().add(CastVoteEvent(
                    targetId: targetId,
                    targetType: targetType,
                    value: VoteValue.down,
                    isAuthenticated: isAuthenticated,
                  )),
            ),
          ],
        );
      },
    );
  }

  (VoteValue?, int, int) _extract(VoteState s) => switch (s) {
        VoteInitial(:final upvotes, :final downvotes) => (null, upvotes, downvotes),
        VoteUpdated(:final currentVote, :final upvotes, :final downvotes) =>
          (currentVote, upvotes, downvotes),
        Voting(:final currentVote, :final upvotes, :final downvotes) =>
          (currentVote, upvotes, downvotes),
        VoteError(:final currentVote, :final upvotes, :final downvotes) =>
          (currentVote, upvotes, downvotes),
      };
}

class _VoteButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool isActive;
  final Color activeColor;
  final bool isLoading;
  final bool showCount;
  final VoidCallback onTap;

  const _VoteButton({
    required this.icon,
    required this.count,
    required this.isActive,
    required this.activeColor,
    required this.isLoading,
    required this.showCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : Colors.grey;
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            if (showCount) ...[
              const SizedBox(width: 2),
              Text(
                '$count',
                style: TextStyle(fontSize: 12, color: color),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
