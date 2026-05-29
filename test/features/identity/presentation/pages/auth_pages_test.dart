import 'package:banjarin/core/error/failures.dart';
import 'package:banjarin/core/router/routes.dart';
import 'package:banjarin/core/theme/app_theme.dart';
import 'package:banjarin/features/identity/presentation/bloc/auth_bloc.dart';
import 'package:banjarin/features/identity/presentation/bloc/auth_event.dart';
import 'package:banjarin/features/identity/presentation/bloc/auth_state.dart';
import 'package:banjarin/features/identity/presentation/pages/forgot_password_page.dart';
import 'package:banjarin/features/identity/presentation/pages/login_page.dart';
import 'package:banjarin/features/identity/presentation/pages/register_page.dart';
import 'package:banjarin/features/identity/presentation/pages/verify_email_page.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

// Minimal router that handles all routes LoginPage might navigate to
GoRouter _makeRouter(Widget home) {
  return GoRouter(
    initialLocation: '/test',
    routes: [
      GoRoute(path: '/test', builder: (_, _) => home),
      GoRoute(path: Routes.home, builder: (_, _) => const SizedBox.shrink()),
      GoRoute(path: Routes.login, builder: (_, _) => const SizedBox.shrink()),
      GoRoute(path: Routes.register, builder: (_, _) => const SizedBox.shrink()),
      GoRoute(path: Routes.forgotPassword, builder: (_, _) => const SizedBox.shrink()),
      GoRoute(path: Routes.verifyEmail, builder: (_, _) => const SizedBox.shrink()),
    ],
  );
}

Widget buildTestApp({required AuthBloc bloc, required Widget page}) {
  return BlocProvider<AuthBloc>.value(
    value: bloc,
    child: MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: _makeRouter(page),
    ),
  );
}

void main() {
  late MockAuthBloc mockBloc;

  setUp(() {
    mockBloc = MockAuthBloc();
    registerFallbackValue(const AuthLogin(email: '', password: ''));
    registerFallbackValue(const AuthRegister(
      name: '',
      email: '',
      password: '',
      passwordConfirmation: '',
    ));
  });

  // -------------------------------------------------------------------------
  // LoginPage
  // -------------------------------------------------------------------------
  group('LoginPage', () {
    testWidgets('renders email and password fields', (tester) async {
      when(() => mockBloc.state).thenReturn(const Unauthenticated());

      await tester.pumpWidget(buildTestApp(
        bloc: mockBloc,
        page: const LoginPage(),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
    });

    testWidgets('submit button is disabled when fields are empty', (tester) async {
      when(() => mockBloc.state).thenReturn(const Unauthenticated());

      await tester.pumpWidget(buildTestApp(
        bloc: mockBloc,
        page: const LoginPage(),
      ));
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(
        find.byKey(const Key('login_button')),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('submit button is enabled when both fields have text',
        (tester) async {
      when(() => mockBloc.state).thenReturn(const Unauthenticated());

      await tester.pumpWidget(buildTestApp(
        bloc: mockBloc,
        page: const LoginPage(),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('email_field')), 'a@b.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'pass');
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.byKey(const Key('login_button')),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets(
        'shows inline validation errors when AuthBloc emits AuthError with ValidationFailure',
        (tester) async {
      whenListen(
        mockBloc,
        Stream.fromIterable([
          const AuthLoading(),
          AuthError(ValidationFailure(
            fieldErrors: {
              'email': ['Format email tidak valid.'],
            },
          )),
        ]),
        initialState: const Unauthenticated(),
      );

      await tester.pumpWidget(buildTestApp(
        bloc: mockBloc,
        page: const LoginPage(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Format email tidak valid.'), findsOneWidget);
    });

    testWidgets(
        'shows rate limit countdown when AuthBloc emits AuthError with RateLimitedFailure',
        (tester) async {
      whenListen(
        mockBloc,
        Stream.fromIterable([
          const AuthLoading(),
          const AuthError(RateLimitedFailure(retryAfterSeconds: 60)),
        ]),
        initialState: const Unauthenticated(),
      );

      await tester.pumpWidget(buildTestApp(
        bloc: mockBloc,
        page: const LoginPage(),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('rate_limit_countdown')), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // RegisterPage
  // -------------------------------------------------------------------------
  group('RegisterPage', () {
    testWidgets('renders all four fields', (tester) async {
      when(() => mockBloc.state).thenReturn(const Unauthenticated());

      await tester.pumpWidget(buildTestApp(
        bloc: mockBloc,
        page: const RegisterPage(),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('name_field')), findsOneWidget);
      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.byKey(const Key('confirm_field')), findsOneWidget);
    });

    testWidgets('shows password mismatch error on mismatched confirmation',
        (tester) async {
      when(() => mockBloc.state).thenReturn(const Unauthenticated());

      await tester.pumpWidget(buildTestApp(
        bloc: mockBloc,
        page: const RegisterPage(),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('name_field')), 'Ahmad');
      await tester.enterText(find.byKey(const Key('email_field')), 'a@b.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'pass1234');
      await tester.enterText(find.byKey(const Key('confirm_field')), 'different');
      await tester.pump();

      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pump();

      expect(find.text('Kata sandi tidak cocok'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // ForgotPasswordPage
  // -------------------------------------------------------------------------
  group('ForgotPasswordPage', () {
    testWidgets('always shows success message after submit', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ForgotPasswordPage()),
      );

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.tap(find.byKey(const Key('submit_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('success_message')), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // VerifyEmailPage
  // -------------------------------------------------------------------------
  group('VerifyEmailPage', () {
    testWidgets('displays the registered email address', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: VerifyEmailPage(email: 'ahmad@test.com'),
        ),
      );

      expect(find.byKey(const Key('email_display')), findsOneWidget);
      expect(find.text('ahmad@test.com'), findsOneWidget);
    });

    testWidgets('shows notice screen when no token provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: VerifyEmailPage(email: 'test@example.com'),
        ),
      );

      expect(find.byKey(const Key('open_email_button')), findsOneWidget);
    });
  });
}
