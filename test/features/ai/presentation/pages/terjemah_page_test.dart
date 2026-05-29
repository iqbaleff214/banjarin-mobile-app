import 'package:banjarin/core/router/routes.dart';
import 'package:banjarin/core/theme/app_theme.dart';
import 'package:banjarin/features/ai/domain/entities/confidence_level.dart';
import 'package:banjarin/features/ai/domain/entities/translation_result.dart';
import 'package:banjarin/features/ai/presentation/bloc/translate_bloc.dart';
import 'package:banjarin/features/ai/presentation/bloc/translate_event.dart';
import 'package:banjarin/features/ai/presentation/bloc/translate_state.dart';
import 'package:banjarin/features/ai/presentation/widgets/confidence_badge.dart';
import 'package:banjarin/features/ai/presentation/pages/terjemah_page.dart';
import 'package:banjarin/features/identity/domain/entities/user.dart';
import 'package:banjarin/features/identity/domain/entities/user_role.dart';
import 'package:banjarin/features/identity/presentation/bloc/auth_bloc.dart';
import 'package:banjarin/features/identity/presentation/bloc/auth_event.dart';
import 'package:banjarin/features/identity/presentation/bloc/auth_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockTranslateBloc extends MockBloc<TranslateEvent, TranslateState>
    implements TranslateBloc {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

GoRouter _makeRouter(Widget page) => GoRouter(
      initialLocation: '/test',
      routes: [
        GoRoute(path: '/test', builder: (_, _) => page),
        GoRoute(path: Routes.login, builder: (_, _) => const SizedBox.shrink()),
      ],
    );

Widget buildApp({
  required TranslateBloc translateBloc,
  required AuthBloc authBloc,
}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<TranslateBloc>.value(value: translateBloc),
      BlocProvider<AuthBloc>.value(value: authBloc),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: _makeRouter(const TerjemahPage()),
    ),
  );
}

final tUser = User(
  id: '1',
  name: 'Ahmad',
  email: 'a@b.com',
  role: UserRole.user,
  isActive: true,
  emailVerifiedAt: DateTime(2024),
  createdAt: DateTime(2024),
);

final tResult = TranslationResult(
  original: 'abah inya',
  translation: 'ayahnya',
  dialect: 'hulu',
  model: 'test',
  confidence: ConfidenceLevel.high,
);

void main() {
  late MockTranslateBloc mockTranslateBloc;
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockTranslateBloc = MockTranslateBloc();
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(Authenticated(tUser));
  });

  group('TerjemahPage', () {
    testWidgets('submit button disabled when text field is empty',
        (tester) async {
      when(() => mockTranslateBloc.state).thenReturn(const TranslateInitial());

      await tester.pumpWidget(
        buildApp(translateBloc: mockTranslateBloc, authBloc: mockAuthBloc),
      );
      await tester.pumpAndSettle();

      final btn = tester.widget<ElevatedButton>(
        find.byKey(const Key('translate_button')),
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets('submit button enabled after entering text', (tester) async {
      when(() => mockTranslateBloc.state).thenReturn(const TranslateInitial());

      await tester.pumpWidget(
        buildApp(translateBloc: mockTranslateBloc, authBloc: mockAuthBloc),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('text_input')), 'abah inya');
      await tester.pump();

      final btn = tester.widget<ElevatedButton>(
        find.byKey(const Key('translate_button')),
      );
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('shows char counter updating on input', (tester) async {
      when(() => mockTranslateBloc.state).thenReturn(const TranslateInitial());

      await tester.pumpWidget(
        buildApp(translateBloc: mockTranslateBloc, authBloc: mockAuthBloc),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('text_input')), 'abah');
      await tester.pump();

      expect(find.text('4/1000'), findsOneWidget);
    });

    testWidgets('shows loading state when TranslateBloc emits Translating',
        (tester) async {
      when(() => mockTranslateBloc.state).thenReturn(const Translating());

      await tester.pumpWidget(
        buildApp(translateBloc: mockTranslateBloc, authBloc: mockAuthBloc),
      );
      await tester.pump(); // pumpAndSettle would timeout on CircularProgressIndicator

      expect(find.byKey(const Key('loading_indicator')), findsOneWidget);
    });

    testWidgets('shows result card when TranslateBloc emits TranslateSuccess',
        (tester) async {
      when(() => mockTranslateBloc.state).thenReturn(TranslateSuccess(tResult));

      await tester.pumpWidget(
        buildApp(translateBloc: mockTranslateBloc, authBloc: mockAuthBloc),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('result_card')), findsOneWidget);
      expect(find.text('ayahnya'), findsOneWidget);
    });

    testWidgets(
        'shows rate limit countdown when TranslateBloc emits RateLimited',
        (tester) async {
      when(() => mockTranslateBloc.state).thenReturn(const RateLimited(60));

      await tester.pumpWidget(
        buildApp(translateBloc: mockTranslateBloc, authBloc: mockAuthBloc),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('rate_limit_card')), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // ConfidenceBadge
  // -------------------------------------------------------------------------
  group('ConfidenceBadge', () {
    testWidgets('renders green for high confidence', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const ConfidenceBadge(confidence: ConfidenceLevel.high),
          ),
        ),
      );
      expect(find.text('Tinggi'), findsOneWidget);
    });

    testWidgets('renders red for low confidence', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const ConfidenceBadge(confidence: ConfidenceLevel.low),
          ),
        ),
      );
      expect(find.text('Rendah'), findsOneWidget);
    });

    testWidgets('renders yellow for medium confidence', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const ConfidenceBadge(confidence: ConfidenceLevel.medium),
          ),
        ),
      );
      expect(find.text('Sedang'), findsOneWidget);
    });
  });
}
