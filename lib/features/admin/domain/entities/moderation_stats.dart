import 'package:equatable/equatable.dart';

class ModerationStats extends Equatable {
  final int pendingContributions;
  final int flaggedComments;
  final int approvedThisWeek;
  final int rejectedThisWeek;

  const ModerationStats({
    required this.pendingContributions,
    required this.flaggedComments,
    required this.approvedThisWeek,
    required this.rejectedThisWeek,
  });

  @override
  List<Object?> get props => [
        pendingContributions,
        flaggedComments,
        approvedThisWeek,
        rejectedThisWeek,
      ];
}
