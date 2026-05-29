import 'package:equatable/equatable.dart';

enum CommentTargetType {
  word,
  contribution;

  static CommentTargetType fromString(String v) =>
      v == 'contribution' ? CommentTargetType.contribution : CommentTargetType.word;
}

class Comment extends Equatable {
  final String id;
  final String userId;
  final String? authorName;
  final CommentTargetType targetType;
  final String targetId;
  final String body;
  final bool isFlagged;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Comment({
    required this.id,
    required this.userId,
    this.authorName,
    required this.targetType,
    required this.targetId,
    required this.body,
    required this.isFlagged,
    required this.createdAt,
    required this.updatedAt,
  });

  Comment copyWith({
    String? body,
    bool? isFlagged,
    DateTime? updatedAt,
  }) {
    return Comment(
      id: id,
      userId: userId,
      authorName: authorName,
      targetType: targetType,
      targetId: targetId,
      body: body ?? this.body,
      isFlagged: isFlagged ?? this.isFlagged,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, userId, authorName, targetType, targetId, body, isFlagged,
        createdAt, updatedAt,
      ];
}
