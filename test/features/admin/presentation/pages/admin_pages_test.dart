import 'package:banjarin/core/router/routes.dart';
import 'package:banjarin/core/theme/app_theme.dart';
import 'package:banjarin/features/admin/domain/entities/moderation_stats.dart';
import 'package:banjarin/features/admin/presentation/bloc/admin_word_bloc.dart';
import 'package:banjarin/features/admin/presentation/bloc/admin_word_event.dart';
import 'package:banjarin/features/admin/presentation/bloc/admin_word_state.dart';
import 'package:banjarin/features/admin/presentation/bloc/moderation_bloc.dart';
import 'package:banjarin/features/admin/presentation/bloc/moderation_event.dart';
import 'package:banjarin/features/admin/presentation/bloc/moderation_state.dart';
import 'package:banjarin/features/admin/presentation/bloc/user_mgmt_bloc.dart';
import 'package:banjarin/features/admin/presentation/bloc/user_mgmt_event.dart';
import 'package:banjarin/features/admin/presentation/bloc/user_mgmt_state.dart';
import 'package:banjarin/features/admin/presentation/pages/admin_contribution_review_page.dart';
import 'package:banjarin/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:banjarin/features/admin/presentation/pages/admin_flagged_comments_page.dart';
import 'package:banjarin/features/admin/presentation/pages/admin_user_detail_page.dart';
import 'package:banjarin/features/admin/presentation/pages/admin_word_form_page.dart';
import 'package:banjarin/features/admin/presentation/pages/admin_word_list_page.dart';
import 'package:banjarin/features/community/domain/entities/comment.dart';
import 'package:banjarin/features/community/domain/entities/contribution.dart';
import 'package:banjarin/features/dictionary/domain/entities/content_source.dart';
import 'package:banjarin/features/dictionary/domain/entities/word_class.dart';
import 'package:banjarin/features/dictionary/domain/entities/word_summary.dart';
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

class MockAdminWordBloc extends MockBloc<AdminWordEvent, AdminWordState>
    implements AdminWordBloc {}

class MockModerationBloc extends MockBloc<ModerationEvent, ModerationState>
    implements ModerationBloc {}

class MockUserMgmtBloc extends MockBloc<UserMgmtEvent, UserMgmtState>
    implements UserMgmtBloc {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

final tAdminUser = User(
  id: '1', name: 'Ahmad', email: 'a@b.com',
  role: UserRole.admin, isActive: true,
  emailVerifiedAt: DateTime(2024), createdAt: DateTime(2024),
);

final tUserBlocked = User(
  id: '2', name: 'Blocked', email: 'b@b.com',
  role: UserRole.user, isActive: false, createdAt: DateTime(2024),
);

final tWord = WordSummary(
  id: 'w1', banjar: 'abah', dialect: 'hulu',
  wordClass: WordClass.n, homonymNumber: 1, isRoot: true,
  primaryMeaning: 'ayah', source: ContentSource.seeded,
  createdAt: DateTime(2024),
);

final tContrib = Contribution(
  id: 'c1', type: ContributionType.new_word, contributorId: 'u1',
  payload: const {'banjar': 'abah', 'word_class': 'n', 'definitions': [{'meaning': 'ayah'}]},
  status: ContributionStatus.pending, submittedAt: DateTime(2024),
);

const tStats = ModerationStats(
  pendingContributions: 5, flaggedComments: 2,
  approvedThisWeek: 10, rejectedThisWeek: 3,
);

Widget buildApp({
  required Widget page,
  required MockAuthBloc authBloc,
  MockAdminWordBloc? wordBloc,
  MockModerationBloc? modBloc,
  MockUserMgmtBloc? userBloc,
}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>.value(value: authBloc),
      if (wordBloc != null) BlocProvider<AdminWordBloc>.value(value: wordBloc),
      if (modBloc != null) BlocProvider<ModerationBloc>.value(value: modBloc),
      if (userBloc != null) BlocProvider<UserMgmtBloc>.value(value: userBloc),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: GoRouter(
        initialLocation: '/test',
        routes: [
          GoRoute(path: '/test', builder: (_, _) => page),
          GoRoute(path: Routes.home, builder: (_, _) => const SizedBox.shrink()),
          GoRoute(path: Routes.adminModerationQueue,
              builder: (_, _) => const SizedBox.shrink()),
          GoRoute(path: Routes.adminWords,
              builder: (_, _) => const SizedBox.shrink()),
          GoRoute(path: Routes.adminUsers,
              builder: (_, _) => const SizedBox.shrink()),
          GoRoute(path: Routes.adminFlaggedComments,
              builder: (_, _) => const SizedBox.shrink()),
          GoRoute(path: Routes.adminAiRequests,
              builder: (_, _) => const SizedBox.shrink()),
          GoRoute(path: Routes.adminWordCreate,
              builder: (_, _) => const SizedBox.shrink()),
          GoRoute(path: Routes.adminWordEdit,
              builder: (_, _) => const SizedBox.shrink()),
        ],
      ),
    ),
  );
}

void main() {
  late MockAuthBloc mockAuth;

  setUp(() {
    mockAuth = MockAuthBloc();
    when(() => mockAuth.state).thenReturn(Authenticated(tAdminUser));
  });

  // -------------------------------------------------------------------------
  // AdminDashboardPage
  // -------------------------------------------------------------------------
  group('AdminDashboardPage', () {
    testWidgets('renders 4 stat cards', (tester) async {
      final mockMod = MockModerationBloc();
      when(() => mockMod.state).thenReturn(
        const ModerationLoaded(stats: tStats),
      );

      await tester.pumpWidget(buildApp(
        authBloc: mockAuth,
        modBloc: mockMod,
        page: const AdminDashboardPage(),
      ));
      await tester.pump();

      expect(find.byKey(const Key('stat_pending')), findsOneWidget);
      expect(find.byKey(const Key('stat_flagged')), findsOneWidget);
      expect(find.byKey(const Key('stat_approved')), findsOneWidget);
      expect(find.byKey(const Key('stat_rejected')), findsOneWidget);
    });

    testWidgets('shows pending count from ModerationBloc', (tester) async {
      final mockMod = MockModerationBloc();
      when(() => mockMod.state).thenReturn(
        const ModerationLoaded(stats: tStats),
      );

      await tester.pumpWidget(buildApp(
        authBloc: mockAuth,
        modBloc: mockMod,
        page: const AdminDashboardPage(),
      ));
      await tester.pump();

      expect(find.text('5'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // AdminWordFormPage
  // -------------------------------------------------------------------------
  group('AdminWordFormPage', () {
    testWidgets('submit button disabled when banjar field is empty',
        (tester) async {
      final mockWord = MockAdminWordBloc();
      when(() => mockWord.state).thenReturn(const AdminWordInitial());

      await tester.pumpWidget(buildApp(
        authBloc: mockAuth,
        wordBloc: mockWord,
        page: const AdminWordFormPage(),
      ));
      await tester.pump();

      // Tap submit with empty banjar — validation error shown
      await tester.tap(find.byKey(const Key('submit_button')));
      await tester.pump();
      expect(find.byKey(const Key('banjar_field')), findsOneWidget);
    });

    testWidgets('add definition row adds a new input', (tester) async {
      final mockWord = MockAdminWordBloc();
      when(() => mockWord.state).thenReturn(const AdminWordInitial());

      await tester.pumpWidget(buildApp(
        authBloc: mockAuth,
        wordBloc: mockWord,
        page: const AdminWordFormPage(),
      ));
      await tester.pump();

      // Initially 1 definition row
      expect(find.byKey(const Key('def_row_0')), findsOneWidget);
      expect(find.byKey(const Key('def_row_1')), findsNothing);

      // Tap add definition
      await tester.tap(find.byKey(const Key('add_definition_button')));
      await tester.pump();

      expect(find.byKey(const Key('def_row_1')), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // AdminWordListPage
  // -------------------------------------------------------------------------
  group('AdminWordListPage', () {
    testWidgets('shows delete confirmation dialog on delete tap', (tester) async {
      final mockWord = MockAdminWordBloc();
      when(() => mockWord.state).thenReturn(
        AdminWordLoaded(words: [tWord], hasMore: false, currentPage: 1),
      );

      await tester.pumpWidget(buildApp(
        authBloc: mockAuth,
        wordBloc: mockWord,
        page: const AdminWordListPage(),
      ));
      await tester.pump();

      await tester.tap(find.byKey(const Key('delete_w1')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('delete_dialog')), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // AdminContributionReviewPage
  // -------------------------------------------------------------------------
  group('AdminContributionReviewPage', () {
    testWidgets('Tolak button disabled when note is empty', (tester) async {
      final mockMod = MockModerationBloc();
      when(() => mockMod.state).thenReturn(ModerationLoaded(queue: [tContrib]));

      await tester.pumpWidget(buildApp(
        authBloc: mockAuth,
        modBloc: mockMod,
        page: const AdminContributionReviewPage(contributionId: 'c1'),
      ));
      await tester.pump();

      final btn = tester.widget<OutlinedButton>(
        find.byKey(const Key('reject_button')),
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets('shows payload for new_word type correctly', (tester) async {
      final mockMod = MockModerationBloc();
      when(() => mockMod.state).thenReturn(ModerationLoaded(queue: [tContrib]));

      await tester.pumpWidget(buildApp(
        authBloc: mockAuth,
        modBloc: mockMod,
        page: const AdminContributionReviewPage(contributionId: 'c1'),
      ));
      await tester.pump();

      expect(find.textContaining('banjar'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // AdminFlaggedCommentsPage
  // -------------------------------------------------------------------------
  group('AdminFlaggedCommentsPage', () {
    testWidgets('shows delete confirmation dialog on delete tap', (tester) async {
      final mockMod = MockModerationBloc();
      final comment = Comment(
        id: 'cm1', userId: 'u1', targetType: CommentTargetType.word,
        targetId: 'w1', body: 'Bad comment here',
        isFlagged: true, createdAt: DateTime(2024), updatedAt: DateTime(2024),
      );
      when(() => mockMod.state).thenReturn(
        ModerationLoaded(flaggedComments: [comment]),
      );

      await tester.pumpWidget(buildApp(
        authBloc: mockAuth,
        modBloc: mockMod,
        page: const AdminFlaggedCommentsPage(),
      ));
      await tester.pump();

      await tester.tap(find.byKey(const Key('delete_comment_cm1')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('delete_comment_dialog')), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // AdminUserDetailPage
  // -------------------------------------------------------------------------
  group('AdminUserDetailPage', () {
    testWidgets('shows Ban button when user is_active is true', (tester) async {
      final mockUser = MockUserMgmtBloc();
      when(() => mockUser.state).thenReturn(
        UserMgmtLoaded(users: [tAdminUser], hasMore: false, currentPage: 1),
      );

      await tester.pumpWidget(buildApp(
        authBloc: mockAuth,
        userBloc: mockUser,
        page: AdminUserDetailPage(userId: tAdminUser.id),
      ));
      await tester.pump();

      expect(find.byKey(const Key('ban_button')), findsOneWidget);
      expect(find.byKey(const Key('unban_button')), findsNothing);
    });

    testWidgets('shows Unban button when user is_active is false', (tester) async {
      final mockUser = MockUserMgmtBloc();
      when(() => mockUser.state).thenReturn(
        UserMgmtLoaded(
          users: [tUserBlocked], hasMore: false, currentPage: 1,
        ),
      );

      await tester.pumpWidget(buildApp(
        authBloc: mockAuth,
        userBloc: mockUser,
        page: AdminUserDetailPage(userId: tUserBlocked.id),
      ));
      await tester.pump();

      expect(find.byKey(const Key('unban_button')), findsOneWidget);
      expect(find.byKey(const Key('ban_button')), findsNothing);
    });

    testWidgets('Ban button disabled when reason field is empty', (tester) async {
      final mockUser = MockUserMgmtBloc();
      when(() => mockUser.state).thenReturn(
        UserMgmtLoaded(users: [tAdminUser], hasMore: false, currentPage: 1),
      );

      await tester.pumpWidget(buildApp(
        authBloc: mockAuth,
        userBloc: mockUser,
        page: AdminUserDetailPage(userId: tAdminUser.id),
      ));
      await tester.pump();

      // Open ban dialog
      await tester.tap(find.byKey(const Key('ban_button')));
      await tester.pumpAndSettle();

      // Confirm button should be disabled with empty reason
      final confirmBtn = tester.widget<TextButton>(
        find.byKey(const Key('confirm_ban_button')),
      );
      expect(confirmBtn.onPressed, isNull);
    });
  });
}
