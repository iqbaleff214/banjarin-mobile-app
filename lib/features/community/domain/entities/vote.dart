import 'package:equatable/equatable.dart';

enum VoteTargetType {
  word,
  definition;

  static VoteTargetType fromString(String v) =>
      v == 'definition' ? VoteTargetType.definition : VoteTargetType.word;
}

enum VoteValue {
  up,
  down;

  static VoteValue fromString(String v) =>
      v == 'down' ? VoteValue.down : VoteValue.up;
}

class Vote extends Equatable {
  final String id;
  final String userId;
  final VoteTargetType targetType;
  final String targetId;
  final VoteValue value;
  final DateTime createdAt;

  const Vote({
    required this.id,
    required this.userId,
    required this.targetType,
    required this.targetId,
    required this.value,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, targetType, targetId, value, createdAt];
}
