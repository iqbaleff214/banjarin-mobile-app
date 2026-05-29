import '../../domain/entities/comment.dart';

class CommentModel {
  final String id;
  final String userId;
  final String? authorName;
  final CommentTargetType targetType;
  final String targetId;
  final String body;
  final bool isFlagged;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CommentModel({
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

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      authorName: json['author_name'] as String?,
      targetType: CommentTargetType.fromString(
        json['target_type'] as String? ?? 'word',
      ),
      targetId: json['target_id'] as String,
      body: json['body'] as String,
      isFlagged: json['is_flagged'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Comment toEntity() => Comment(
        id: id,
        userId: userId,
        authorName: authorName,
        targetType: targetType,
        targetId: targetId,
        body: body,
        isFlagged: isFlagged,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
