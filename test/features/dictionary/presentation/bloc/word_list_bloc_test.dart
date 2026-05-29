import 'package:banjarin/core/error/failures.dart';
import 'package:banjarin/core/usecase/paginated_result.dart';
import 'package:banjarin/features/dictionary/domain/entities/content_source.dart';
import 'package:banjarin/features/dictionary/domain/entities/word_class.dart';
import 'package:banjarin/features/dictionary/domain/entities/word_summary.dart';
import 'package:banjarin/features/dictionary/domain/repositories/word_repository.dart';
import 'package:banjarin/features/dictionary/domain/usecases/get_word_list.dart';
import 'package:banjarin/features/dictionary/domain/usecases/search_words.dart';
import 'package:banjarin/features/dictionary/presentation/bloc/search_bloc.dart';
import 'package:banjarin/features/dictionary/presentation/bloc/search_event.dart';
import 'package:banjarin/features/dictionary/presentation/bloc/search_state.dart';
import 'package:banjarin/features/dictionary/presentation/bloc/word_list_bloc.dart';
import 'package:banjarin/features/dictionary/presentation/bloc/word_list_event.dart';
import 'package:banjarin/features/dictionary/presentation/bloc/word_list_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockGetWordList extends Mock implements GetWordList {}

class MockSearchWords extends Mock implements SearchWords {}

void main() {
  late MockGetWordList mockGetWordList;
  late MockSearchWords mockSearchWords;

  final tWord = WordSummary(
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

  PaginatedResult<WordSummary> makePaginated({
    List<WordSummary>? items,
    int total = 1,
    int page = 1,
  }) =>
      PaginatedResult(
        items: items ?? [tWord],
        page: page,
        perPage: 20,
        total: total,
      );

  setUp(() {
    mockGetWordList = MockGetWordList();
    mockSearchWords = MockSearchWords();
    registerFallbackValue(const WordListParams());
    registerFallbackValue(const SearchParams(query: ''));
  });

  // -------------------------------------------------------------------------
  // WordListBloc
  // -------------------------------------------------------------------------
  group('WordListBloc', () {
    WordListBloc makeBloc() => WordListBloc(getWordList: mockGetWordList);

    blocTest<WordListBloc, WordListState>(
      'LoadWords emits state with isLoading then words loaded',
      build: () {
        when(() => mockGetWordList(any()))
            .thenAnswer((_) async => Right(makePaginated()));
        return makeBloc();
      },
      act: (bloc) => bloc.add(const LoadWords()),
      expect: () => [
        isA<WordListState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<WordListState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.words.length, 'words.length', 1),
      ],
    );

    blocTest<WordListBloc, WordListState>(
      'LoadMoreWords appends results and increments page',
      build: () {
        when(() => mockGetWordList(any())).thenAnswer((_) async => Right(
              makePaginated(total: 40, page: 2),
            ));
        return makeBloc();
      },
      seed: () => WordListState(
        words: [tWord],
        currentPage: 1,
        hasMore: true,
      ),
      act: (bloc) => bloc.add(const LoadMoreWords()),
      expect: () => [
        isA<WordListState>().having((s) => s.isLoadingMore, 'isLoadingMore', isTrue),
        isA<WordListState>()
            .having((s) => s.words.length, 'words.length', 2)
            .having((s) => s.currentPage, 'page', 2),
      ],
    );

    blocTest<WordListBloc, WordListState>(
      'LoadMoreWords does nothing when hasMore is false',
      build: () => makeBloc(),
      seed: () => const WordListState(hasMore: false),
      act: (bloc) => bloc.add(const LoadMoreWords()),
      expect: () => [],
    );

    blocTest<WordListBloc, WordListState>(
      'FilterChanged resets to page 1 and reloads',
      build: () {
        when(() => mockGetWordList(any()))
            .thenAnswer((_) async => Right(makePaginated()));
        return makeBloc();
      },
      seed: () => WordListState(words: [tWord], currentPage: 3),
      act: (bloc) => bloc.add(const FilterChanged(wordClass: WordClass.n)),
      expect: () => [
        isA<WordListState>()
            .having((s) => s.isLoading, 'loading', isTrue)
            .having((s) => s.filterWordClass, 'filter', WordClass.n)
            .having((s) => s.currentPage, 'page', 0),
        isA<WordListState>()
            .having((s) => s.currentPage, 'page', 1)
            .having((s) => s.filterWordClass, 'filter', WordClass.n),
      ],
    );

    blocTest<WordListBloc, WordListState>(
      'on NetworkFailure emits state with error',
      build: () {
        when(() => mockGetWordList(any()))
            .thenAnswer((_) async => const Left(NetworkFailure()));
        return makeBloc();
      },
      act: (bloc) => bloc.add(const LoadWords()),
      expect: () => [
        isA<WordListState>().having((s) => s.isLoading, 'loading', isTrue),
        isA<WordListState>()
            .having((s) => s.error, 'error', isA<NetworkFailure>()),
      ],
    );
  });

  // -------------------------------------------------------------------------
  // SearchBloc
  // -------------------------------------------------------------------------
  group('SearchBloc', () {
    SearchBloc makeBloc() => SearchBloc(searchWords: mockSearchWords);

    blocTest<SearchBloc, SearchState>(
      'QueryChanged with empty query emits SearchEmpty',
      build: () => makeBloc(),
      act: (bloc) => bloc.add(const QueryChanged('')),
      wait: const Duration(milliseconds: 450),
      expect: () => [isA<SearchEmpty>()],
    );

    blocTest<SearchBloc, SearchState>(
      'QueryChanged with valid query emits [SearchLoading, SearchResults] after debounce',
      build: () {
        when(() => mockSearchWords(any())).thenAnswer((_) async => Right(
              PaginatedResult(
                items: [tWord],
                page: 1,
                perPage: 20,
                total: 1,
              ),
            ));
        return makeBloc();
      },
      act: (bloc) => bloc.add(const QueryChanged('abah')),
      wait: const Duration(milliseconds: 450),
      expect: () => [isA<SearchLoading>(), isA<SearchResults>()],
      verify: (bloc) {
        expect((bloc.state as SearchResults).words.first.banjar, 'abah');
      },
    );
  });
}
