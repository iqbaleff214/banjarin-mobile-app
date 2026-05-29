import 'package:banjarin/core/theme/app_theme.dart';
import 'package:banjarin/features/admin/domain/entities/ai_request.dart';
import 'package:banjarin/features/admin/presentation/bloc/ai_request_bloc.dart';
import 'package:banjarin/features/admin/presentation/bloc/ai_request_event.dart';
import 'package:banjarin/features/admin/presentation/bloc/ai_request_state.dart';
import 'package:banjarin/features/admin/presentation/pages/admin_ai_request_detail_page.dart';
import 'package:banjarin/features/admin/presentation/widgets/ai_parsed_output_view.dart';
import 'package:banjarin/features/admin/presentation/widgets/ai_request_card.dart';
import 'package:banjarin/features/identity/presentation/bloc/auth_bloc.dart';
import 'package:banjarin/features/identity/presentation/bloc/auth_event.dart';
import 'package:banjarin/features/identity/presentation/bloc/auth_state.dart';
import 'package:banjarin/features/identity/domain/entities/user.dart';
import 'package:banjarin/features/identity/domain/entities/user_role.dart';
import 'package:banjarin/features/admin/presentation/bloc/moderation_bloc.dart';
import 'package:banjarin/features/admin/presentation/bloc/moderation_event.dart';
import 'package:banjarin/features/admin/presentation/bloc/moderation_state.dart';
import 'package:banjarin/core/router/routes.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockAIRequestBloc extends MockBloc<AIRequestEvent, AIRequestState>
    implements AIRequestBloc {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockModerationBloc extends MockBloc<ModerationEvent, ModerationState>
    implements ModerationBloc {}

final tAdminUser = User(
  id: '1', name: 'Admin', email: 'a@b.com',
  role: UserRole.admin, isActive: true,
  emailVerifiedAt: DateTime(2024), createdAt: DateTime(2024),
);

AIRequest makeRequest({
  AIRequestType type = AIRequestType.enrich_definition,
  AIRequestStatus status = AIRequestStatus.pending,
  AIReviewStatus reviewStatus = AIReviewStatus.unreviewed,
  Map<String, dynamic>? parsedOutput,
}) =>
    AIRequest(
      id: 'r1',
      type: type,
      model: 'test',
      status: status,
      reviewStatus: reviewStatus,
      parsedOutput: parsedOutput,
      createdAt: DateTime(2024),
    );

Widget buildApp({
  required Widget page,
  required MockAIRequestBloc aiBloc,
  required MockAuthBloc authBloc,
  MockModerationBloc? modBloc,
}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<AIRequestBloc>.value(value: aiBloc),
      BlocProvider<AuthBloc>.value(value: authBloc),
      if (modBloc != null) BlocProvider<ModerationBloc>.value(value: modBloc),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: GoRouter(
        initialLocation: '/test',
        routes: [
          GoRoute(path: '/test', builder: (_, _) => page),
          GoRoute(path: Routes.home, builder: (_, _) => const SizedBox.shrink()),
          GoRoute(path: Routes.adminAiRequests, builder: (_, _) => const SizedBox.shrink()),
        ],
      ),
    ),
  );
}

void main() {
  late MockAIRequestBloc mockAI;
  late MockAuthBloc mockAuth;

  setUp(() {
    mockAI = MockAIRequestBloc();
    mockAuth = MockAuthBloc();
    when(() => mockAuth.state).thenReturn(Authenticated(tAdminUser));
  });

  // -------------------------------------------------------------------------
  // AIRequestCard
  // -------------------------------------------------------------------------
  group('AIRequestCard', () {
    testWidgets('renders correct type badge for enrich_definition',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AIRequestCard(request: makeRequest()),
        ),
      ));
      expect(
        find.byKey(const Key('type_badge_enrich_definition')),
        findsOneWidget,
      );
    });

    testWidgets('renders failed state with error indicator', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AIRequestCard(
            request: makeRequest(status: AIRequestStatus.failed),
          ),
        ),
      ));
      expect(find.byKey(const Key('failed_indicator')), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // AIParsedOutputView
  // -------------------------------------------------------------------------
  group('AIParsedOutputView', () {
    testWidgets('renders definition list for enrich_definition type',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AIParsedOutputView(
            key: const Key('definition_output'),
            type: AIRequestType.enrich_definition,
            parsedOutput: {
              'definitions': [
                {'meaning': 'ayah'},
                {'meaning': 'bapak'},
              ]
            },
          ),
        ),
      ));
      expect(find.text('ayah'), findsOneWidget);
      expect(find.text('bapak'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // AdminAIRequestDetailPage
  // -------------------------------------------------------------------------
  group('AdminAIRequestDetailPage', () {
    testWidgets('hides approve/reject for quality_check type', (tester) async {
      when(() => mockAI.state).thenReturn(AIRequestLoaded(
        requests: [makeRequest(type: AIRequestType.quality_check)],
        hasMore: false,
        currentPage: 1,
      ));

      await tester.pumpWidget(buildApp(
        aiBloc: mockAI,
        authBloc: mockAuth,
        page: const AdminAIRequestDetailPage(requestId: 'r1'),
      ));
      await tester.pump();

      expect(find.byKey(const Key('approve_button')), findsNothing);
      expect(find.byKey(const Key('reject_button')), findsNothing);
    });

    testWidgets('disables approve button when reviewStatus is approved',
        (tester) async {
      when(() => mockAI.state).thenReturn(AIRequestLoaded(
        requests: [makeRequest(reviewStatus: AIReviewStatus.approved)],
        hasMore: false,
        currentPage: 1,
      ));

      await tester.pumpWidget(buildApp(
        aiBloc: mockAI,
        authBloc: mockAuth,
        page: const AdminAIRequestDetailPage(requestId: 'r1'),
      ));
      await tester.pump();

      final btn = tester.widget<ElevatedButton>(
        find.byKey(const Key('approve_button')),
      );
      expect(btn.onPressed, isNull);
    });
  });
}
