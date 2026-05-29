import '../../domain/entities/moderation_stats.dart';

class ModerationStatsModel {
  final int pendingContributions;
  final int flaggedComments;
  final int approvedThisWeek;
  final int rejectedThisWeek;

  const ModerationStatsModel({
    required this.pendingContributions,
    required this.flaggedComments,
    required this.approvedThisWeek,
    required this.rejectedThisWeek,
  });

  factory ModerationStatsModel.fromJson(Map<String, dynamic> json) {
    return ModerationStatsModel(
      pendingContributions: json['pending_contributions'] as int? ?? 0,
      flaggedComments: json['flagged_comments'] as int? ?? 0,
      approvedThisWeek: json['approved_this_week'] as int? ?? 0,
      rejectedThisWeek: json['rejected_this_week'] as int? ?? 0,
    );
  }

  ModerationStats toEntity() => ModerationStats(
        pendingContributions: pendingContributions,
        flaggedComments: flaggedComments,
        approvedThisWeek: approvedThisWeek,
        rejectedThisWeek: rejectedThisWeek,
      );
}
