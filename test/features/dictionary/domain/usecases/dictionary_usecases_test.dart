import 'package:banjarin/core/error/failures.dart';
import 'package:banjarin/core/usecase/paginated_result.dart';
import 'package:banjarin/features/dictionary/domain/entities/content_source.dart';
import 'package:banjarin/features/dictionary/domain/entities/definition.dart';
import 'package:banjarin/features/dictionary/domain/entities/example.dart';
import 'package:banjarin/features/dictionary/domain/entities/word.dart';
import 'package:banjarin/features/dictionary/domain/entities/word_class.dart';
import 'package:banjarin/features/dictionary/domain/entities/word_summary.dart';
import 'package:banjarin/features/dictionary/domain/repositories/word_repository.dart';
import 'package:banjarin/features/dictionary/domain/usecases/get_definitions.dart';
import 'package:banjarin/features/dictionary/domain/usecases/get_examples.dart';
import 'package:banjarin/features/dictionary/domain/usecases/get_related_words.dart';
import 'package:banjarin/features/dictionary/domain/usecases/get_word_detail.dart';
import 'package:banjarin/features/dictionary/domain/usecases/get_word_list.dart';
import 'package:banjarin/features/dictionary/domain/usecases/search_words.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockWordRepository extends Mock implements WordRepository {}

void main() {
  late MockWordRepository mockRepo;

  final tWordSummary = WordSummary(
    id: '1',
    banjar: 'abah',
    dialect: 'hulu',
    wordClass: WordClass.n,
    homonymNumber: 1,
    isRoot: true,
    primaryMeaning: 'ayah',
    source: ContentSource.seeded,
    createdAt: DateTime(2024),
  );

  final tPaginated = PaginatedResult(
    items: [tWordSummary],
    page: 1,
    perPage: 20,
    total: 1,
  );

  final tWord = Word(
    id: '1',
    banjar: 'abah',
    dialect: 'hulu',
    wordClass: WordClass.n,
    homonymNumber: 1,
    isRoot: true,
    definitions: [],
    examples: [],
    relatedWordIds: [],
    status: WordStatus.active,
    source: ContentSource.seeded,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  setUp(() {
    mockRepo = MockWordRepository();
    registerFallbackValue(const WordListParams());
    registerFallbackValue(const SearchParams(query: ''));
    registerFallbackValue(const WordIdParams(wordId: ''));
  });

  // -------------------------------------------------------------------------
  // GetWordList
  // -------------------------------------------------------------------------
  group('GetWordList', () {
    late GetWordList getWordList;
    setUp(() => getWordList = GetWordList(mockRepo));

    test('delegates to repository with correct params', () async {
      when(() => mockRepo.getWordList(any()))
          .thenAnswer((_) async => Right(tPaginated));

      final result = await getWordList(const WordListParams());
      expect(result.isRight(), isTrue);
    });

    test('with word class filter passes filter to repository', () async {
      when(() => mockRepo.getWordList(any()))
          .thenAnswer((_) async => Right(tPaginated));

      await getWordList(const WordListParams(wordClass: WordClass.n));

      final captured = verify(() => mockRepo.getWordList(captureAny())).captured;
      final params = captured.first as WordListParams;
      expect(params.wordClass, WordClass.n);
    });
  });

  // -------------------------------------------------------------------------
  // SearchWords
  // -------------------------------------------------------------------------
  group('SearchWords', () {
    late SearchWords searchWords;
    setUp(() => searchWords = SearchWords(mockRepo));

    test('when query is empty returns ValidationFailure', () async {
      final result = await searchWords(const SearchParams(query: ''));
      expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
    });

    test('when query is whitespace returns ValidationFailure', () async {
      final result = await searchWords(const SearchParams(query: '  '));
      expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
    });

    test('when query is valid delegates to repository', () async {
      when(() => mockRepo.searchWords(any()))
          .thenAnswer((_) async => Right(tPaginated));

      final result = await searchWords(const SearchParams(query: 'abah'));
      expect(result.isRight(), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // GetWordDetail
  // -------------------------------------------------------------------------
  group('GetWordDetail', () {
    late GetWordDetail getWordDetail;
    setUp(() => getWordDetail = GetWordDetail(mockRepo));

    test('delegates to repository with word id', () async {
      when(() => mockRepo.getWordDetail(any()))
          .thenAnswer((_) async => Right(tWord));

      final result = await getWordDetail(const WordIdParams(wordId: '1'));
      expect(result.isRight(), isTrue);
    });

    test('when repository returns NotFoundFailure propagates it', () async {
      when(() => mockRepo.getWordDetail(any()))
          .thenAnswer((_) async => const Left(NotFoundFailure()));

      final result = await getWordDetail(const WordIdParams(wordId: 'bad'));
      expect(result.fold((f) => f, (_) => null), isA<NotFoundFailure>());
    });
  });

  // -------------------------------------------------------------------------
  // GetDefinitions
  // -------------------------------------------------------------------------
  group('GetDefinitions', () {
    late GetDefinitions getDefinitions;
    setUp(() => getDefinitions = GetDefinitions(mockRepo));

    test('delegates to repository with word id', () async {
      when(() => mockRepo.getDefinitions(any()))
          .thenAnswer((_) async => const Right(<Definition>[]));

      final result = await getDefinitions(const WordIdParams(wordId: '1'));
      expect(result.isRight(), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // GetExamples
  // -------------------------------------------------------------------------
  group('GetExamples', () {
    late GetExamples getExamples;
    setUp(() => getExamples = GetExamples(mockRepo));

    test('delegates to repository with word id', () async {
      when(() => mockRepo.getExamples(any()))
          .thenAnswer((_) async => const Right(<Example>[]));

      final result = await getExamples(const WordIdParams(wordId: '1'));
      expect(result.isRight(), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // GetRelatedWords
  // -------------------------------------------------------------------------
  group('GetRelatedWords', () {
    late GetRelatedWords getRelatedWords;
    setUp(() => getRelatedWords = GetRelatedWords(mockRepo));

    test('delegates to repository with word id', () async {
      when(() => mockRepo.getRelatedWords(any()))
          .thenAnswer((_) async => const Right(<WordSummary>[]));

      final result = await getRelatedWords(const WordIdParams(wordId: '1'));
      expect(result.isRight(), isTrue);
    });
  });
}
