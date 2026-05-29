import 'package:banjarin/core/error/failures.dart';
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
import 'package:banjarin/features/dictionary/presentation/bloc/word_detail_bloc.dart';
import 'package:banjarin/features/dictionary/presentation/bloc/word_detail_event.dart';
import 'package:banjarin/features/dictionary/presentation/bloc/word_detail_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockGetWordDetail extends Mock implements GetWordDetail {}

class MockGetDefinitions extends Mock implements GetDefinitions {}

class MockGetExamples extends Mock implements GetExamples {}

class MockGetRelatedWords extends Mock implements GetRelatedWords {}

void main() {
  late MockGetWordDetail mockGetWordDetail;
  late MockGetDefinitions mockGetDefinitions;
  late MockGetExamples mockGetExamples;
  late MockGetRelatedWords mockGetRelatedWords;

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
    mockGetWordDetail = MockGetWordDetail();
    mockGetDefinitions = MockGetDefinitions();
    mockGetExamples = MockGetExamples();
    mockGetRelatedWords = MockGetRelatedWords();
    registerFallbackValue(const WordIdParams(wordId: ''));
  });

  WordDetailBloc makeBloc() => WordDetailBloc(
        getWordDetail: mockGetWordDetail,
        getDefinitions: mockGetDefinitions,
        getExamples: mockGetExamples,
        getRelatedWords: mockGetRelatedWords,
      );

  group('WordDetailBloc', () {
    blocTest<WordDetailBloc, WordDetailState>(
      'LoadWordDetail emits [Loading, Loaded] with full word data',
      build: () {
        when(() => mockGetWordDetail(any())).thenAnswer((_) async => Right(tWord));
        when(() => mockGetDefinitions(any()))
            .thenAnswer((_) async => const Right(<Definition>[]));
        when(() => mockGetExamples(any()))
            .thenAnswer((_) async => const Right(<Example>[]));
        when(() => mockGetRelatedWords(any()))
            .thenAnswer((_) async => const Right(<WordSummary>[]));
        return makeBloc();
      },
      act: (bloc) => bloc.add(const LoadWordDetail('1')),
      expect: () => [isA<WordDetailLoading>(), isA<WordDetailLoaded>()],
      verify: (bloc) {
        final loaded = bloc.state as WordDetailLoaded;
        expect(loaded.word.banjar, 'abah');
        expect(loaded.definitions, isEmpty);
        expect(loaded.definitionsError, isNull);
      },
    );

    blocTest<WordDetailBloc, WordDetailState>(
      'LoadWordDetail on NotFoundFailure emits [Loading, Error]',
      build: () {
        when(() => mockGetWordDetail(any()))
            .thenAnswer((_) async => const Left(NotFoundFailure()));
        when(() => mockGetDefinitions(any()))
            .thenAnswer((_) async => const Right(<Definition>[]));
        when(() => mockGetExamples(any()))
            .thenAnswer((_) async => const Right(<Example>[]));
        when(() => mockGetRelatedWords(any()))
            .thenAnswer((_) async => const Right(<WordSummary>[]));
        return makeBloc();
      },
      act: (bloc) => bloc.add(const LoadWordDetail('bad')),
      expect: () => [isA<WordDetailLoading>(), isA<WordDetailError>()],
      verify: (bloc) {
        expect((bloc.state as WordDetailError).failure, isA<NotFoundFailure>());
      },
    );

    blocTest<WordDetailBloc, WordDetailState>(
      'LoadWordDetail when sub-fetch fails emits Loaded with partial data and error',
      build: () {
        when(() => mockGetWordDetail(any())).thenAnswer((_) async => Right(tWord));
        when(() => mockGetDefinitions(any()))
            .thenAnswer((_) async => const Left(NetworkFailure()));
        when(() => mockGetExamples(any()))
            .thenAnswer((_) async => const Right(<Example>[]));
        when(() => mockGetRelatedWords(any()))
            .thenAnswer((_) async => const Right(<WordSummary>[]));
        return makeBloc();
      },
      act: (bloc) => bloc.add(const LoadWordDetail('1')),
      expect: () => [isA<WordDetailLoading>(), isA<WordDetailLoaded>()],
      verify: (bloc) {
        final loaded = bloc.state as WordDetailLoaded;
        expect(loaded.definitions, isEmpty);
        expect(loaded.definitionsError, isA<NetworkFailure>());
      },
    );
  });
}
