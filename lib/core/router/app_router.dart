import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/community/presentation/bloc/comment_bloc.dart';
import '../../features/community/presentation/bloc/vote_bloc.dart';
import '../../features/admin/presentation/pages/admin_contribution_review_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_flagged_comments_page.dart';
import '../../features/admin/presentation/pages/admin_moderation_queue_page.dart';
import '../../features/admin/presentation/pages/admin_user_detail_page.dart';
import '../../features/admin/presentation/pages/admin_user_list_page.dart';
import '../../features/admin/presentation/pages/admin_word_form_page.dart';
import '../../features/admin/presentation/pages/admin_ai_request_detail_page.dart';
import '../../features/admin/presentation/pages/admin_ai_requests_page.dart';
import '../../features/admin/presentation/pages/admin_word_list_page.dart';
import '../../features/ai/presentation/pages/terjemah_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/community/presentation/pages/contribution_edit_word_page.dart';
import '../../features/community/presentation/pages/contribution_new_definition_page.dart';
import '../../features/community/presentation/pages/contribution_new_example_page.dart';
import '../../features/community/presentation/pages/contribution_new_word_page.dart';
import '../../features/community/presentation/pages/my_contributions_page.dart';
import '../../features/community/presentation/pages/simpanan_page.dart';
import '../../features/dictionary/presentation/bloc/word_detail_bloc.dart';
import '../../features/dictionary/presentation/pages/beranda_page.dart';
import '../../features/dictionary/presentation/pages/cari_page.dart';
import '../../features/dictionary/presentation/pages/word_detail_page.dart';
import '../../features/identity/domain/usecases/forgot_password.dart';
import '../../features/identity/domain/usecases/reset_password.dart';
import '../../features/identity/domain/usecases/verify_email.dart';
import '../../features/identity/presentation/pages/change_password_page.dart';
import '../../features/identity/presentation/pages/edit_profile_page.dart';
import '../../features/identity/presentation/pages/forgot_password_page.dart';
import '../../features/identity/presentation/pages/login_page.dart';
import '../../features/identity/presentation/pages/profile_page.dart';
import '../../features/identity/presentation/pages/register_page.dart';
import '../../features/identity/presentation/pages/reset_password_page.dart';
import '../../features/identity/presentation/pages/verify_email_page.dart';
import '../../injection/injection.dart';
import 'routes.dart';

// ---------------------------------------------------------------------------
// Placeholder pages — replaced by real implementations in later phases
// ---------------------------------------------------------------------------

class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}

// ---------------------------------------------------------------------------
// Router factory
// ---------------------------------------------------------------------------

GoRouter createRouter({String? initialLocation}) {
  return GoRouter(
    initialLocation: initialLocation ?? Routes.home,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: Routes.onboarding,
        builder: (_, _) => const OnboardingPage(),
      ),

      // Main shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          return _MainShell(
            location: state.matchedLocation,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: Routes.home,
            builder: (_, _) => const BerandaPage(),
          ),
          GoRoute(
            path: Routes.search,
            builder: (_, _) => const CariPage(),
          ),
          GoRoute(
            path: Routes.translate,
            builder: (_, _) => const TerjemahPage(),
          ),
          GoRoute(
            path: Routes.bookmarks,
            builder: (_, _) => const SimpananPage(),
          ),
          GoRoute(
            path: Routes.profile,
            builder: (_, _) => const ProfilePage(),
          ),
        ],
      ),

      // Word detail — fresh blocs scoped to this page
      GoRoute(
        path: Routes.wordDetail,
        builder: (context, state) {
          final wordId = state.pathParameters['id']!;
          return MultiBlocProvider(
            providers: [
              BlocProvider<WordDetailBloc>(
                create: (_) => sl<WordDetailBloc>(),
              ),
              BlocProvider<VoteBloc>(
                create: (_) => sl<VoteBloc>(),
              ),
              BlocProvider<CommentBloc>(
                create: (_) => sl<CommentBloc>(),
              ),
            ],
            child: WordDetailPage(wordId: wordId),
          );
        },
      ),

      // Auth routes
      GoRoute(
        path: Routes.login,
        builder: (_, _) => const LoginPage(),
      ),
      GoRoute(
        path: Routes.register,
        builder: (_, _) => const RegisterPage(),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (_, _) => ForgotPasswordPage(
          forgotPasswordUseCase: sl<ForgotPassword>(),
        ),
      ),
      GoRoute(
        path: Routes.resetPassword,
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return ResetPasswordPage(
            token: token,
            resetPasswordUseCase: sl<ResetPassword>(),
          );
        },
      ),
      GoRoute(
        path: Routes.verifyEmail,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          final token = state.uri.queryParameters['token'];
          return VerifyEmailPage(
            email: email,
            token: token,
            verifyEmailUseCase: sl<VerifyEmail>(),
          );
        },
      ),

      // Profile sub-routes
      GoRoute(
        path: Routes.editProfile,
        builder: (_, _) => const EditProfilePage(),
      ),
      GoRoute(
        path: Routes.changePassword,
        builder: (_, _) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: Routes.myContributions,
        builder: (_, _) => const MyContributionsPage(),
      ),
      GoRoute(
        path: Routes.contributionDetail,
        builder: (context, state) => _PlaceholderPage(
          'Kontribusi: ${state.pathParameters['id']}',
        ),
      ),


      // Contribution form routes
      GoRoute(
        path: Routes.contributionNewWord,
        builder: (_, _) => const ContributionNewWordPage(),
      ),
      GoRoute(
        path: Routes.contributionNewDefinition,
        builder: (context, state) {
          final wordId = state.uri.queryParameters['wordId'] ?? '';
          final banjar = state.uri.queryParameters['wordBanjar'] ?? '';
          return ContributionNewDefinitionPage(
            wordId: wordId,
            wordBanjar: Uri.decodeComponent(banjar),
          );
        },
      ),
      GoRoute(
        path: Routes.contributionNewExample,
        builder: (context, state) {
          final wordId = state.uri.queryParameters['wordId'] ?? '';
          final banjar = state.uri.queryParameters['wordBanjar'] ?? '';
          return ContributionNewExamplePage(
            wordId: wordId,
            wordBanjar: Uri.decodeComponent(banjar),
          );
        },
      ),
      GoRoute(
        path: Routes.contributionEditWord,
        builder: (context, state) {
          final wordId = state.uri.queryParameters['wordId'] ?? '';
          final banjar = state.uri.queryParameters['wordBanjar'] ?? '';
          return ContributionEditWordPage(
            wordId: wordId,
            wordBanjar: Uri.decodeComponent(banjar),
          );
        },
      ),
      // Admin panel (nested)
      GoRoute(
        path: Routes.adminPanel,
        builder: (_, _) => const AdminDashboardPage(),
        routes: [
          GoRoute(
            path: 'words',
            builder: (_, _) => const AdminWordListPage(),
          ),
          GoRoute(
            path: 'words/create',
            builder: (_, _) => const AdminWordFormPage(),
          ),
          GoRoute(
            path: 'words/:id/edit',
            builder: (_, _) => const AdminWordFormPage(),
          ),
          GoRoute(
            path: 'moderasi/antrian',
            builder: (_, _) => const AdminModerationQueuePage(),
          ),
          GoRoute(
            path: 'moderasi/kontribusi/:id',
            builder: (context, state) => AdminContributionReviewPage(
              contributionId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: 'moderasi/komentar',
            builder: (_, _) => const AdminFlaggedCommentsPage(),
          ),
          GoRoute(
            path: 'pengguna',
            builder: (_, _) => const AdminUserListPage(),
          ),
          GoRoute(
            path: 'pengguna/:id',
            builder: (context, state) => AdminUserDetailPage(
              userId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: 'ai/permintaan',
            builder: (_, _) => const AdminAIRequestsPage(),
          ),
          GoRoute(
            path: 'ai/permintaan/:id',
            builder: (context, state) => AdminAIRequestDetailPage(
              requestId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Main shell widget with bottom navigation bar
// ---------------------------------------------------------------------------

class _MainShell extends StatelessWidget {
  final String location;
  final Widget child;

  const _MainShell({
    required this.location,
    required this.child,
  });

  int get _selectedIndex {
    if (location.startsWith(Routes.search)) return 1;
    if (location.startsWith(Routes.translate)) return 2;
    if (location.startsWith(Routes.bookmarks)) return 3;
    if (location.startsWith(Routes.profile)) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go(Routes.home);
            case 1:
              context.go(Routes.search);
            case 2:
              context.go(Routes.translate);
            case 3:
              context.go(Routes.bookmarks);
            case 4:
              context.go(Routes.profile);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Cari',
          ),
          NavigationDestination(
            icon: Icon(Icons.translate_outlined),
            selectedIcon: Icon(Icons.translate),
            label: 'Terjemah',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Simpanan',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
