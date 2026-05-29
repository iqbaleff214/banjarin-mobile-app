import 'package:banjarin/core/error/failures.dart';
import 'package:banjarin/core/usecase/paginated_result.dart';
import 'package:banjarin/features/community/domain/entities/bookmark.dart';
import 'package:banjarin/features/community/domain/entities/comment.dart';
import 'package:banjarin/features/community/domain/entities/vote.dart';
import 'package:banjarin/features/community/domain/repositories/bookmark_repository.dart';
import 'package:banjarin/features/community/domain/repositories/comment_repository.dart';
import 'package:banjarin/features/community/domain/repositories/vote_repository.dart';
import 'package:banjarin/features/community/domain/usecases/add_bookmark.dart';
import 'package:banjarin/features/community/domain/usecases/cast_vote.dart';
import 'package:banjarin/features/community/domain/usecases/delete_comment.dart';
import 'package:banjarin/features/community/domain/usecases/edit_comment.dart';
import 'package:banjarin/features/community/domain/usecases/flag_comment.dart';
import 'package:banjarin/features/community/domain/usecases/get_bookmarks.dart';
import 'package:banjarin/features/community/domain/usecases/post_comment.dart';
import 'package:banjarin/features/community/domain/usecases/remove_bookmark.dart';
import 'package:banjarin/features/community/domain/usecases/remove_vote.dart';
import 'package:banjarin/features/dictionary/domain/entities/content_source.dart';
import 'package:banjarin/features/dictionary/domain/entities/word_class.dart';
import 'package:banjarin/features/dictionary/domain/entities/word_summary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockVoteRepository extends Mock implements VoteRepository {}
class MockBookmarkRepository extends Mock implements BookmarkRepository {}
class MockCommentRepository extends Mock implements CommentRepository {}

void main() {
  late MockVoteRepository mockVoteRepo;
  late MockBookmarkRepository mockBookmarkRepo;
  late MockCommentRepository mockCommentRepo;

  final tVote = Vote(
    id: '1', userId: 'u1',
    targetType: VoteTargetType.word, targetId: 'w1',
    value: VoteValue.up, createdAt: DateTime(2024),
  );

  final tWordSummary = WordSummary(
    id: 'w1', banjar: 'abah', dialect: 'hulu',
    wordClass: WordClass.n, homonymNumber: 1, isRoot: true,
    primaryMeaning: 'ayah', source: ContentSource.seeded,
    createdAt: DateTime(2024),
  );

  final tBookmark = Bookmark(
    id: 'b1', wordId: 'w1', word: tWordSummary, createdAt: DateTime(2024),
  );

  final tComment = Comment(
    id: 'c1', userId: 'u1', targetType: CommentTargetType.word,
    targetId: 'w1', body: 'Great word!', isFlagged: false,
    createdAt: DateTime(2024), updatedAt: DateTime(2024),
  );

  setUp(() {
    mockVoteRepo = MockVoteRepository();
    mockBookmarkRepo = MockBookmarkRepository();
    mockCommentRepo = MockCommentRepository();

    registerFallbackValue(VoteTargetType.word);
    registerFallbackValue(VoteValue.up);
    registerFallbackValue(CommentTargetType.word);
  });

  // -------------------------------------------------------------------------
  // Vote
  // -------------------------------------------------------------------------
  group('CastVote', () {
    late CastVote castVote;
    setUp(() => castVote = CastVote(mockVoteRepo));

    test('when user is authenticated delegates to repository', () async {
      when(() => mockVoteRepo.castVote(
            targetId: any(named: 'targetId'),
            targetType: any(named: 'targetType'),
            value: any(named: 'value'),
          )).thenAnswer((_) async => Right(tVote));

      final result = await castVote(const CastVoteParams(
        targetId: 'w1',
        targetType: VoteTargetType.word,
        value: VoteValue.up,
        isAuthenticated: true,
      ));

      expect(result.isRight(), isTrue);
    });

    test('when user is unauthenticated returns UnauthorizedFailure', () async {
      final result = await castVote(const CastVoteParams(
        targetId: 'w1',
        targetType: VoteTargetType.word,
        value: VoteValue.up,
        isAuthenticated: false,
      ));

      expect(result.fold((f) => f, (_) => null), isA<UnauthorizedFailure>());
    });
  });

  group('RemoveVote', () {
    late RemoveVote removeVote;
    setUp(() => removeVote = RemoveVote(mockVoteRepo));

    test('delegates to repository with targetType and targetId', () async {
      when(() => mockVoteRepo.removeVote(
            targetId: any(named: 'targetId'),
            targetType: any(named: 'targetType'),
          )).thenAnswer((_) async => const Right(null));

      final result = await removeVote(const RemoveVoteParams(
        targetId: 'w1',
        targetType: VoteTargetType.word,
        isAuthenticated: true,
      ));

      expect(result.isRight(), isTrue);
    });

    test('when unauthenticated returns UnauthorizedFailure', () async {
      final result = await removeVote(const RemoveVoteParams(
        targetId: 'w1',
        targetType: VoteTargetType.word,
        isAuthenticated: false,
      ));

      expect(result.fold((f) => f, (_) => null), isA<UnauthorizedFailure>());
    });
  });

  // -------------------------------------------------------------------------
  // Bookmark
  // -------------------------------------------------------------------------
  group('AddBookmark', () {
    late AddBookmark addBookmark;
    setUp(() => addBookmark = AddBookmark(mockBookmarkRepo));

    test('when word not bookmarked delegates to repository', () async {
      when(() => mockBookmarkRepo.addBookmark(wordId: any(named: 'wordId')))
          .thenAnswer((_) async => Right(tBookmark));

      final result = await addBookmark(const AddBookmarkParams(wordId: 'w1'));
      expect(result.isRight(), isTrue);
    });

    test('when repository returns ConflictFailure propagates it', () async {
      when(() => mockBookmarkRepo.addBookmark(wordId: any(named: 'wordId')))
          .thenAnswer((_) async => const Left(ConflictFailure()));

      final result = await addBookmark(const AddBookmarkParams(wordId: 'w1'));
      expect(result.fold((f) => f, (_) => null), isA<ConflictFailure>());
    });
  });

  group('RemoveBookmark', () {
    late RemoveBookmark removeBookmark;
    setUp(() => removeBookmark = RemoveBookmark(mockBookmarkRepo));

    test('delegates to repository with wordId', () async {
      when(() => mockBookmarkRepo.removeBookmark(wordId: any(named: 'wordId')))
          .thenAnswer((_) async => const Right(null));

      final result = await removeBookmark(const RemoveBookmarkParams(wordId: 'w1'));
      expect(result.isRight(), isTrue);
    });
  });

  group('GetBookmarks', () {
    late GetBookmarks getBookmarks;
    setUp(() => getBookmarks = GetBookmarks(mockBookmarkRepo));

    test('delegates to repository with pagination params', () async {
      when(() => mockBookmarkRepo.getBookmarks(
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          )).thenAnswer((_) async => Right(PaginatedResult(
            items: [tBookmark], page: 1, perPage: 20, total: 1,
          )));

      final result = await getBookmarks(const GetBookmarksParams(page: 2));
      expect(result.isRight(), isTrue);
      verify(() => mockBookmarkRepo.getBookmarks(page: 2, perPage: 20)).called(1);
    });
  });

  // -------------------------------------------------------------------------
  // Comment
  // -------------------------------------------------------------------------
  group('PostComment', () {
    late PostComment postComment;
    setUp(() => postComment = PostComment(mockCommentRepo));

    test('when body is empty returns ValidationFailure', () async {
      final result = await postComment(const PostCommentParams(
        wordId: 'w1', body: '', isAuthenticated: true,
      ));
      expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
    });

    test('when body exceeds 1000 chars returns ValidationFailure', () async {
      final result = await postComment(PostCommentParams(
        wordId: 'w1', body: 'x' * 1001, isAuthenticated: true,
      ));
      expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
    });

    test('when unauthenticated returns UnauthorizedFailure', () async {
      final result = await postComment(const PostCommentParams(
        wordId: 'w1', body: 'hello', isAuthenticated: false,
      ));
      expect(result.fold((f) => f, (_) => null), isA<UnauthorizedFailure>());
    });

    test('when valid delegates to repository', () async {
      when(() => mockCommentRepo.postComment(
            wordId: any(named: 'wordId'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => Right(tComment));

      final result = await postComment(const PostCommentParams(
        wordId: 'w1', body: 'Great word!', isAuthenticated: true,
      ));
      expect(result.isRight(), isTrue);
    });
  });

  group('EditComment', () {
    late EditComment editComment;
    setUp(() => editComment = EditComment(mockCommentRepo));

    test('when body exceeds 1000 chars returns ValidationFailure', () async {
      final result = await editComment(EditCommentParams(
        commentId: 'c1', body: 'x' * 1001,
      ));
      expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
    });
  });

  group('DeleteComment', () {
    late DeleteComment deleteComment;
    setUp(() => deleteComment = DeleteComment(mockCommentRepo));

    test('delegates to repository with comment id', () async {
      when(() => mockCommentRepo.deleteComment(commentId: any(named: 'commentId')))
          .thenAnswer((_) async => const Right(null));

      final result = await deleteComment(const DeleteCommentParams(commentId: 'c1'));
      expect(result.isRight(), isTrue);
    });
  });

  group('FlagComment', () {
    late FlagComment flagComment;
    setUp(() => flagComment = FlagComment(mockCommentRepo));

    test('delegates to repository', () async {
      when(() => mockCommentRepo.flagComment(commentId: any(named: 'commentId')))
          .thenAnswer((_) async => Right(tComment.copyWith(isFlagged: true)));

      final result = await flagComment(const FlagCommentParams(commentId: 'c1'));
      expect(result.isRight(), isTrue);
    });
  });
}
