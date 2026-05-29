import 'package:banjarin/core/router/routes.dart';
import 'package:banjarin/core/theme/app_theme.dart';
import 'package:banjarin/features/dictionary/domain/entities/content_source.dart';
import 'package:banjarin/features/dictionary/domain/entities/word_class.dart';
import 'package:banjarin/features/dictionary/domain/entities/word_summary.dart';
import 'package:banjarin/features/dictionary/presentation/bloc/search_bloc.dart';
import 'package:banjarin/features/dictionary/presentation/bloc/search_event.dart';
import 'package:banjarin/features/dictionary/presentation/bloc/search_state.dart';
import 'package:banjarin/features/dictionary/presentation/bloc/word_list_bloc.dart';
import 'package:banjarin/features/dictionary/presentation/bloc/word_list_event.dart';
import 'package:banjarin/features/dictionary/presentation/bloc/word_list_state.dart';
import 'package:banjarin/features/identity/presentation/bloc/auth_bloc.dart';
import 'package:banjarin/features/identity/presentation/bloc/auth_event.dart';
import 'package:banjarin/features/identity/presentation/bloc/auth_state.dart';
import 'package:banjarin/features/dictionary/presentation/pages/beranda_page.dart';
import 'package:banjarin/features/dictionary/presentation/pages/cari_page.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockWordListBloc extends MockBloc<WordListEvent, WordListState>
    implements WordListBloc {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockSearchBloc extends MockBloc<SearchEvent, SearchState>
    implements SearchBloc {}

GoRouter _makeRouter(Widget home) => GoRouter(
      initialLocation: '/test',
      routes: [
        GoRoute(path: '/test', builder: (_, _) => home),
        GoRoute(path: Routes.home, builder: (_, _) => const SizedBox.shrink()),
        GoRoute(
          path: Routes.wordDetail,
          builder: (context, state) =>
              Text('word: ${state.pathParameters['id']}'),
        ),
        GoRoute(path: Routes.search, builder: (_, _) => const SizedBox.shrink()),
      ],
    );

WordSummary makeWord({String id = '1', int homonym = 1}) => WordSummary(
      id: id,
      banjar: 'abah',
      dialect: 'hulu',
      wordClass: WordClass.n,
      homonymNumber: homonym,
      isRoot: true,
      primaryMeaning: 'ayah',
      source: ContentSource.seeded,
      createdAt: DateTime(2024),
    );

void main() {
  // -------------------------------------------------------------------------
  // BerandaPage
  // -------------------------------------------------------------------------
  group('BerandaPage', () {
    late MockWordListBloc mockBloc;
    late MockAuthBloc mockAuthBloc;

    setUp(() {
      mockBloc = MockWordListBloc();
      mockAuthBloc = MockAuthBloc();
    });

    Widget buildBeranda() {
      when(() => mockAuthBloc.state).thenReturn(const Unauthenticated());
      return MultiBlocProvider(
        providers: [
          BlocProvider<WordListBloc>.value(value: mockBloc),
          BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: _makeRouter(const BerandaPage()),
        ),
      );
    }

    testWidgets('renders word cards when WordListBloc emits Loaded state',
        (tester) async {
      when(() => mockBloc.state).thenReturn(
        WordListState(words: [makeWord()], isLoading: false),
      );

      await tester.pumpWidget(buildBeranda());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('word_list')), findsOneWidget);
      expect(find.text('abah'), findsWidgets);
    });

    testWidgets('shows skeleton loaders when WordListBloc emits Loading state',
        (tester) async {
      when(() => mockBloc.state).thenReturn(
        const WordListState(isLoading: true, words: []),
      );

      await tester.pumpWidget(buildBeranda());
      await tester.pump();

      expect(find.byKey(const Key('skeleton_list')), findsOneWidget);
    });

    testWidgets('shows empty state when word list is empty', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const WordListState(isLoading: false, words: []),
      );

      await tester.pumpWidget(buildBeranda());
      await tester.pumpAndSettle();

      expect(find.text('Tidak ada kata ditemukan'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // CariPage
  // -------------------------------------------------------------------------
  group('CariPage', () {
    late MockSearchBloc mockSearchBloc;

    setUp(() => mockSearchBloc = MockSearchBloc());

    Widget buildCari() => BlocProvider<SearchBloc>.value(
          value: mockSearchBloc,
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: _makeRouter(const CariPage()),
          ),
        );

    testWidgets('shows recent searches view when state is SearchInitial',
        (tester) async {
      when(() => mockSearchBloc.state).thenReturn(const SearchInitial());

      await tester.pumpWidget(buildCari());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('recent_searches')), findsOneWidget);
    });

    testWidgets('shows search results when SearchBloc emits SearchResults',
        (tester) async {
      when(() => mockSearchBloc.state).thenReturn(SearchResults(
        query: 'abah',
        words: [makeWord()],
        hasMore: false,
        currentPage: 1,
      ));

      await tester.pumpWidget(buildCari());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('search_results')), findsOneWidget);
      expect(find.text('abah'), findsWidgets);
    });
  });
}
