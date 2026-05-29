import 'package:equatable/equatable.dart';

sealed class CommentEvent extends Equatable {
  const CommentEvent();
}

final class LoadComments extends CommentEvent {
  final String wordId;
  const LoadComments(this.wordId);
  @override List<Object?> get props => [wordId];
}

final class LoadMoreComments extends CommentEvent {
  const LoadMoreComments();
  @override List<Object?> get props => [];
}

final class PostCommentEvent extends CommentEvent {
  final String wordId;
  final String body;
  final bool isAuthenticated;

  const PostCommentEvent({
    required this.wordId,
    required this.body,
    required this.isAuthenticated,
  });

  @override
  List<Object?> get props => [wordId, body, isAuthenticated];
}

final class EditCommentEvent extends CommentEvent {
  final String commentId;
  final String body;

  const EditCommentEvent({required this.commentId, required this.body});

  @override
  List<Object?> get props => [commentId, body];
}

final class DeleteCommentEvent extends CommentEvent {
  final String commentId;

  const DeleteCommentEvent(this.commentId);

  @override
  List<Object?> get props => [commentId];
}

final class FlagCommentEvent extends CommentEvent {
  final String commentId;

  const FlagCommentEvent(this.commentId);

  @override
  List<Object?> get props => [commentId];
}
