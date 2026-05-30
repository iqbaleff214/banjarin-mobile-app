import '../../domain/entities/vote.dart';

class VoteModel {
  final String id;
  final String userId;
  final VoteTargetType targetType;
  final String targetId;
  final VoteValue value;
  final DateTime createdAt;

  const VoteModel({
    required this.id,
    required this.userId,
    required this.targetType,
    required this.targetId,
    required this.value,
    required this.createdAt,
  });

  factory VoteModel.fromJson(Map<String, dynamic> json) {
    return VoteModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      targetType: VoteTargetType.fromString(json['target_type'] as String),
      targetId: json['target_id'] as String,
      value: VoteValue.fromString(json['value'] as String),
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Vote toEntity() => Vote(
        id: id,
        userId: userId,
        targetType: targetType,
        targetId: targetId,
        value: value,
        createdAt: createdAt,
      );
}
