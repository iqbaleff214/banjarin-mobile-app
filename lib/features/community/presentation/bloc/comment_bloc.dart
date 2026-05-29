import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/delete_comment.dart';
import '../../domain/usecases/edit_comment.dart';
import '../../domain/usecases/flag_comment.dart';
import '../../domain/usecases/get_comments.dart';
import '../../domain/usecases/post_comment.dart';
import 'comment_event.dart';
import 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final GetComments _getComments;
  final PostComment _postComment;
  final EditComment _editComment;
  final DeleteComment _deleteComment;
  final FlagComment _flagComment;
  static const _perPage = 20;

  CommentBloc({
    required GetComments getComments,
    required PostComment postComment,
    required EditComment editComment,
    required DeleteComment deleteComment,
    required FlagComment flagComment,
  })  : _getComments = getComments,
        _postComment = postComment,
        _editComment = editComment,
        _deleteComment = deleteComment,
        _flagComment = flagComment,
        super(const CommentInitial()) {
    on<LoadComments>(_onLoadComments);
    on<LoadMoreComments>(_onLoadMore);
    on<PostCommentEvent>(_onPostComment);
    on<EditCommentEvent>(_onEditComment);
    on<DeleteCommentEvent>(_onDeleteComment);
    on<FlagCommentEvent>(_onFlagComment);
  }

  CommentsLoaded? get _currentLoaded =>
      state is CommentsLoaded ? state as CommentsLoaded : null;

  Future<void> _onLoadComments(
    LoadComments event,
    Emitter<CommentState> emit,
  ) async {
    emit(const CommentsLoading());
    final result = await _getComments(
      GetCommentsParams(wordId: event.wordId),
    );
    result.fold(
      (failure) => emit(CommentError(failure)),
      (paginated) => emit(CommentsLoaded(
        comments: paginated.items,
        hasMore: paginated.hasMore,
        currentPage: paginated.page,
        wordId: event.wordId,
      )),
    );
  }

  Future<void> _onLoadMore(
    LoadMoreComments event,
    Emitter<CommentState> emit,
  ) async {
    final current = _currentLoaded;
    if (current == null || !current.hasMore) return;

    final result = await _getComments(GetCommentsParams(
      wordId: current.wordId,
      page: current.currentPage + 1,
      perPage: _perPage,
    ));
    result.fold(
      (failure) => emit(CommentError(failure, currentComments: current.comments)),
      (paginated) => emit(CommentsLoaded(
        comments: [...current.comments, ...paginated.items],
        hasMore: paginated.hasMore,
        currentPage: paginated.page,
        wordId: current.wordId,
      )),
    );
  }

  Future<void> _onPostComment(
    PostCommentEvent event,
    Emitter<CommentState> emit,
  ) async {
    final current = _currentLoaded;
    final currentComments = current?.comments ?? [];
    emit(CommentPosting(currentComments));

    final result = await _postComment(PostCommentParams(
      wordId: event.wordId,
      body: event.body,
      isAuthenticated: event.isAuthenticated,
    ));

    result.fold(
      (failure) => emit(CommentError(failure, currentComments: currentComments)),
      (comment) => emit(CommentAdded(
        comments: [comment, ...currentComments],
        hasMore: current?.hasMore ?? false,
        currentPage: current?.currentPage ?? 1,
        wordId: event.wordId,
      )),
    );
  }

  Future<void> _onEditComment(
    EditCommentEvent event,
    Emitter<CommentState> emit,
  ) async {
    final current = _currentLoaded;
    if (current == null) return;

    emit(CommentEditing(
      currentComments: current.comments,
      commentId: event.commentId,
    ));

    final result = await _editComment(EditCommentParams(
      commentId: event.commentId,
      body: event.body,
    ));

    result.fold(
      (failure) =>
          emit(CommentError(failure, currentComments: current.comments)),
      (updated) {
        final comments = current.comments
            .map((c) => c.id == updated.id ? updated : c)
            .toList();
        emit(CommentUpdated(
          comments: comments,
          hasMore: current.hasMore,
          currentPage: current.currentPage,
          wordId: current.wordId,
        ));
      },
    );
  }

  Future<void> _onDeleteComment(
    DeleteCommentEvent event,
    Emitter<CommentState> emit,
  ) async {
    final current = _currentLoaded;
    if (current == null) return;

    final result = await _deleteComment(
      DeleteCommentParams(commentId: event.commentId),
    );

    result.fold(
      (failure) =>
          emit(CommentError(failure, currentComments: current.comments)),
      (_) => emit(CommentDeleted(
        comments: current.comments.where((c) => c.id != event.commentId).toList(),
        hasMore: current.hasMore,
        currentPage: current.currentPage,
        wordId: current.wordId,
      )),
    );
  }

  Future<void> _onFlagComment(
    FlagCommentEvent event,
    Emitter<CommentState> emit,
  ) async {
    final current = _currentLoaded;
    if (current == null) return;

    final result = await _flagComment(
      FlagCommentParams(commentId: event.commentId),
    );

    result.fold(
      (failure) =>
          emit(CommentError(failure, currentComments: current.comments)),
      (flagged) {
        final comments = current.comments
            .map((c) => c.id == flagged.id ? flagged : c)
            .toList();
        emit(CommentsLoaded(
          comments: comments,
          hasMore: current.hasMore,
          currentPage: current.currentPage,
          wordId: current.wordId,
        ));
      },
    );
  }
}
