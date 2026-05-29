import 'package:banjarin/core/router/routes.dart';
import 'package:banjarin/core/theme/app_theme.dart';
import 'package:banjarin/features/admin/presentation/widgets/admin_guard.dart';
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

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

User makeUser({UserRole role = UserRole.user}) => User(
      id: '1', name: 'Ahmad', email: 'a@b.com',
      role: role, isActive: true, createdAt: DateTime(2024),
    );

Widget buildApp({required AuthBloc authBloc, required Widget page}) {
  return BlocProvider<AuthBloc>.value(
    value: authBloc,
    child: MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: GoRouter(
        initialLocation: '/test',
        routes: [
          GoRoute(path: '/test', builder: (_, _) => page),
          GoRoute(path: Routes.home, builder: (_, _) => const SizedBox.shrink()),
        ],
      ),
    ),
  );
}

void main() {
  late MockAuthBloc mockBloc;

  setUp(() => mockBloc = MockAuthBloc());

  group('AdminGuard', () {
    testWidgets('shows child when user role is admin', (tester) async {
      when(() => mockBloc.state)
          .thenReturn(Authenticated(makeUser(role: UserRole.admin)));

      await tester.pumpWidget(buildApp(
        authBloc: mockBloc,
        page: const AdminGuard(
          child: Scaffold(body: Text('Admin Content')),
        ),
      ));
      await tester.pump();

      expect(find.text('Admin Content'), findsOneWidget);
    });

    testWidgets('shows 403 screen when user role is user', (tester) async {
      when(() => mockBloc.state)
          .thenReturn(Authenticated(makeUser(role: UserRole.user)));

      await tester.pumpWidget(buildApp(
        authBloc: mockBloc,
        page: const AdminGuard(
          child: Scaffold(body: Text('Admin Content')),
        ),
      ));
      await tester.pump();

      // 403 screen shows, not admin content
      expect(find.text('Admin Content'), findsNothing);
      expect(find.text('403'), findsOneWidget);
    });

    testWidgets('shows 403 when unauthenticated', (tester) async {
      when(() => mockBloc.state).thenReturn(const Unauthenticated());

      await tester.pumpWidget(buildApp(
        authBloc: mockBloc,
        page: const AdminGuard(
          child: Scaffold(body: Text('Admin Content')),
        ),
      ));
      await tester.pump();

      expect(find.text('403'), findsOneWidget);
    });
  });
}
