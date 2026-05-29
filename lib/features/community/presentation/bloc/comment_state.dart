import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/comment.dart';

sealed class CommentState extends Equatable {
  const CommentState();
}

final class CommentInitial extends CommentState {
  const CommentInitial();
  @override List<Object?> get props => [];
}

final class CommentsLoading extends CommentState {
  const CommentsLoading();
  @override List<Object?> get props => [];
}

final class CommentsLoaded extends CommentState {
  final List<Comment> comments;
  final bool hasMore;
  final int currentPage;
  final String wordId;

  const CommentsLoaded({
    required this.comments,
    required this.hasMore,
    required this.currentPage,
    required this.wordId,
  });

  @override
  List<Object?> get props => [comments, hasMore, currentPage, wordId];
}

final class CommentPosting extends CommentState {
  final List<Comment> currentComments;

  const CommentPosting(this.currentComments);

  @override
  List<Object?> get props => [currentComments];
}

final class CommentAdded extends CommentsLoaded {
  const CommentAdded({
    required super.comments,
    required super.hasMore,
    required super.currentPage,
    required super.wordId,
  });
}

final class CommentEditing extends CommentState {
  final List<Comment> currentComments;
  final String commentId;

  const CommentEditing({
    required this.currentComments,
    required this.commentId,
  });

  @override
  List<Object?> get props => [currentComments, commentId];
}

final class CommentUpdated extends CommentsLoaded {
  const CommentUpdated({
    required super.comments,
    required super.hasMore,
    required super.currentPage,
    required super.wordId,
  });
}

final class CommentDeleted extends CommentsLoaded {
  const CommentDeleted({
    required super.comments,
    required super.hasMore,
    required super.currentPage,
    required super.wordId,
  });
}

final class CommentError extends CommentState {
  final Failure failure;
  final List<Comment>? currentComments;

  const CommentError(this.failure, {this.currentComments});

  @override
  List<Object?> get props => [failure, currentComments];
}
