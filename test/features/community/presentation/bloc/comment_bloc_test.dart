import 'package:banjarin/core/error/failures.dart';
import 'package:banjarin/core/usecase/paginated_result.dart';
import 'package:banjarin/features/community/domain/entities/comment.dart';
import 'package:banjarin/features/community/domain/usecases/delete_comment.dart';
import 'package:banjarin/features/community/domain/usecases/edit_comment.dart';
import 'package:banjarin/features/community/domain/usecases/flag_comment.dart';
import 'package:banjarin/features/community/domain/usecases/get_comments.dart';
import 'package:banjarin/features/community/domain/usecases/post_comment.dart';
import 'package:banjarin/features/community/presentation/bloc/comment_bloc.dart';
import 'package:banjarin/features/community/presentation/bloc/comment_event.dart';
import 'package:banjarin/features/community/presentation/bloc/comment_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockGetComments extends Mock implements GetComments {}
class MockPostComment extends Mock implements PostComment {}
class MockEditComment extends Mock implements EditComment {}
class MockDeleteComment extends Mock implements DeleteComment {}
class MockFlagComment extends Mock implements FlagComment {}

void main() {
  late MockGetComments mockGet;
  late MockPostComment mockPost;
  late MockEditComment mockEdit;
  late MockDeleteComment mockDelete;
  late MockFlagComment mockFlag;

  final tComment = Comment(
    id: 'c1', userId: 'u1', targetType: CommentTargetType.word,
    targetId: 'w1', body: 'Great!', isFlagged: false,
    createdAt: DateTime(2024), updatedAt: DateTime(2024),
  );

  setUp(() {
    mockGet = MockGetComments();
    mockPost = MockPostComment();
    mockEdit = MockEditComment();
    mockDelete = MockDeleteComment();
    mockFlag = MockFlagComment();

    registerFallbackValue(const GetCommentsParams(wordId: ''));
    registerFallbackValue(const PostCommentParams(wordId: '', body: '', isAuthenticated: true));
    registerFallbackValue(const EditCommentParams(commentId: '', body: ''));
    registerFallbackValue(const DeleteCommentParams(commentId: ''));
    registerFallbackValue(const FlagCommentParams(commentId: ''));
  });

  CommentBloc makeBloc() => CommentBloc(
        getComments: mockGet,
        postComment: mockPost,
        editComment: mockEdit,
        deleteComment: mockDelete,
        flagComment: mockFlag,
      );

  group('CommentBloc', () {
    blocTest<CommentBloc, CommentState>(
      'LoadComments emits [Loading, Loaded] with list',
      build: () {
        when(() => mockGet(any())).thenAnswer((_) async => Right(PaginatedResult(
          items: [tComment], page: 1, perPage: 20, total: 1,
        )));
        return makeBloc();
      },
      act: (bloc) => bloc.add(const LoadComments('w1')),
      expect: () => [isA<CommentsLoading>(), isA<CommentsLoaded>()],
      verify: (bloc) {
        expect((bloc.state as CommentsLoaded).comments.first.body, 'Great!');
      },
    );

    blocTest<CommentBloc, CommentState>(
      'PostComment emits [Posting, CommentAdded] and prepends to list',
      build: () {
        when(() => mockPost(any())).thenAnswer((_) async => Right(tComment));
        return makeBloc();
      },
      seed: () => CommentsLoaded(
        comments: const [], hasMore: false, currentPage: 1, wordId: 'w1',
      ),
      act: (bloc) => bloc.add(const PostCommentEvent(
        wordId: 'w1', body: 'Great!', isAuthenticated: true,
      )),
      expect: () => [isA<CommentPosting>(), isA<CommentAdded>()],
      verify: (bloc) {
        expect((bloc.state as CommentAdded).comments.first.id, 'c1');
      },
    );

    blocTest<CommentBloc, CommentState>(
      'PostComment when unauthenticated emits CommentError',
      build: () {
        when(() => mockPost(any()))
            .thenAnswer((_) async => const Left(UnauthorizedFailure()));
        return makeBloc();
      },
      seed: () => CommentsLoaded(
        comments: const [], hasMore: false, currentPage: 1, wordId: 'w1',
      ),
      act: (bloc) => bloc.add(const PostCommentEvent(
        wordId: 'w1', body: 'Hi', isAuthenticated: false,
      )),
      expect: () => [isA<CommentPosting>(), isA<CommentError>()],
      verify: (bloc) {
        expect(
          (bloc.state as CommentError).failure,
          isA<UnauthorizedFailure>(),
        );
      },
    );

    blocTest<CommentBloc, CommentState>(
      'EditComment emits [Editing, CommentUpdated]',
      build: () {
        final updated = tComment.copyWith(body: 'Updated!');
        when(() => mockEdit(any())).thenAnswer((_) async => Right(updated));
        return makeBloc();
      },
      seed: () => CommentsLoaded(
        comments: [tComment], hasMore: false, currentPage: 1, wordId: 'w1',
      ),
      act: (bloc) => bloc.add(const EditCommentEvent(
        commentId: 'c1', body: 'Updated!',
      )),
      expect: () => [isA<CommentEditing>(), isA<CommentUpdated>()],
    );

    blocTest<CommentBloc, CommentState>(
      'DeleteComment removes comment from state',
      build: () {
        when(() => mockDelete(any())).thenAnswer((_) async => const Right(null));
        return makeBloc();
      },
      seed: () => CommentsLoaded(
        comments: [tComment], hasMore: false, currentPage: 1, wordId: 'w1',
      ),
      act: (bloc) => bloc.add(const DeleteCommentEvent('c1')),
      expect: () => [isA<CommentDeleted>()],
      verify: (bloc) {
        expect((bloc.state as CommentDeleted).comments, isEmpty);
      },
    );

    blocTest<CommentBloc, CommentState>(
      'FlagComment on ConflictFailure emits CommentError with ConflictFailure',
      build: () {
        when(() => mockFlag(any()))
            .thenAnswer((_) async => const Left(ConflictFailure()));
        return makeBloc();
      },
      seed: () => CommentsLoaded(
        comments: [tComment], hasMore: false, currentPage: 1, wordId: 'w1',
      ),
      act: (bloc) => bloc.add(const FlagCommentEvent('c1')),
      expect: () => [isA<CommentError>()],
      verify: (bloc) {
        expect(
          (bloc.state as CommentError).failure,
          isA<ConflictFailure>(),
        );
      },
    );
  });
}
