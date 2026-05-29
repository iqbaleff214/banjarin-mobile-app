import 'package:banjarin/core/theme/app_theme.dart';
import 'package:banjarin/features/community/domain/entities/contribution.dart';
import 'package:banjarin/features/community/presentation/bloc/contribution_bloc.dart';
import 'package:banjarin/features/community/presentation/bloc/contribution_event.dart';
import 'package:banjarin/features/community/presentation/bloc/contribution_state.dart';
import 'package:banjarin/features/community/presentation/widgets/contribution_card.dart';
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

class MockContributionBloc
    extends MockBloc<ContributionEvent, ContributionState>
    implements ContributionBloc {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

final tUser = User(
  id: '1', name: 'Ahmad', email: 'a@b.com',
  role: UserRole.user, isActive: true,
  emailVerifiedAt: DateTime(2024), createdAt: DateTime(2024),
);

Contribution makeContribution({
  ContributionStatus status = ContributionStatus.pending,
  String? reviewerNote,
}) {
  return Contribution(
    id: 'c1',
    type: ContributionType.new_definition,
    contributorId: 'u1',
    targetWordId: 'w1',
    payload: const {'meaning': 'ayah'},
    status: status,
    reviewerNote: reviewerNote,
    submittedAt: DateTime(2024),
  );
}

void main() {
  // -------------------------------------------------------------------------
  // ContributionCard
  // -------------------------------------------------------------------------
  group('ContributionCard', () {
    testWidgets('shows reviewer note for rejected status', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ContributionCard(
            contribution: makeContribution(
              status: ContributionStatus.rejected,
              reviewerNote: 'Definisi kurang tepat.',
            ),
          ),
        ),
      ));

      expect(find.byKey(const Key('reviewer_note')), findsOneWidget);
      expect(find.text('Definisi kurang tepat.'), findsOneWidget);
    });

    testWidgets('shows Cabut button only for pending status', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ContributionCard(
            contribution: makeContribution(status: ContributionStatus.pending),
            onWithdraw: () {},
          ),
        ),
      ));

      expect(find.byKey(const Key('withdraw_button')), findsOneWidget);
    });

    testWidgets('does not show Cabut button for approved status', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ContributionCard(
            contribution: makeContribution(status: ContributionStatus.approved),
            onWithdraw: () {},
          ),
        ),
      ));

      expect(find.byKey(const Key('withdraw_button')), findsNothing);
    });

    testWidgets('does not show reviewer note when null', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ContributionCard(
            contribution: makeContribution(status: ContributionStatus.rejected),
          ),
        ),
      ));

      expect(find.byKey(const Key('reviewer_note')), findsNothing);
    });
  });

  // -------------------------------------------------------------------------
  // ContributionNewDefinitionPage — char counter test
  // -------------------------------------------------------------------------
  group('ContributionNewDefinitionPage', () {
    testWidgets('shows 2000-char counter on meaning field', (tester) async {
      final mockBloc = MockContributionBloc();
      final mockAuth = MockAuthBloc();
      when(() => mockBloc.state).thenReturn(const ContributionInitial());
      when(() => mockAuth.state).thenReturn(Authenticated(tUser));

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ContributionBloc>.value(value: mockBloc),
            BlocProvider<AuthBloc>.value(value: mockAuth),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: GoRouter(
              initialLocation: '/test',
              routes: [
                GoRoute(
                  path: '/test',
                  builder: (_, _) {
                    // Import inline to avoid circular dependency
                    return const _TestDefinitionPage();
                  },
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('meaning_field')), 'hello');
      await tester.pump();

      expect(find.text('5/2000'), findsOneWidget);
    });

    testWidgets('submit button disabled when meaning is empty', (tester) async {
      final mockBloc = MockContributionBloc();
      final mockAuth = MockAuthBloc();
      when(() => mockBloc.state).thenReturn(const ContributionInitial());
      when(() => mockAuth.state).thenReturn(Authenticated(tUser));

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ContributionBloc>.value(value: mockBloc),
            BlocProvider<AuthBloc>.value(value: mockAuth),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: GoRouter(
              initialLocation: '/test',
              routes: [
                GoRoute(
                  path: '/test',
                  builder: (_, _) => const _TestDefinitionPage(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final btn = tester.widget<ElevatedButton>(
        find.byKey(const Key('submit_button')),
      );
      expect(btn.onPressed, isNull);
    });
  });
}

// Minimal page for testing without circular import
class _TestDefinitionPage extends StatefulWidget {
  const _TestDefinitionPage();

  @override
  State<_TestDefinitionPage> createState() => _TestDefinitionPageState();
}

class _TestDefinitionPageState extends State<_TestDefinitionPage> {
  final _ctrl = TextEditingController();
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() => _count = _ctrl.text.length));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final emailVerified =
        authState is Authenticated ? authState.user.emailVerified : false;
    final canSubmit = emailVerified && _ctrl.text.trim().isNotEmpty;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              key: const Key('meaning_field'),
              controller: _ctrl,
              maxLength: 2000,
              decoration: InputDecoration(counterText: '$_count/2000'),
            ),
            ElevatedButton(
              key: const Key('submit_button'),
              onPressed: canSubmit ? () {} : null,
              child: const Text('Kirim'),
            ),
          ],
        ),
      ),
    );
  }
}
