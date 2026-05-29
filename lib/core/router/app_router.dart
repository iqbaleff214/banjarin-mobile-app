import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/community/presentation/bloc/comment_bloc.dart';
import '../../features/community/presentation/bloc/vote_bloc.dart';
import '../../features/ai/presentation/pages/terjemah_page.dart';
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

GoRouter createRouter() {
  return GoRouter(
    initialLocation: Routes.home,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: Routes.onboarding,
        builder: (_, _) => const _PlaceholderPage('Onboarding'),
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
        builder: (_, _) => const _PlaceholderPage('Kontribusiku'),
      ),
      GoRoute(
        path: Routes.contributionDetail,
        builder: (context, state) => _PlaceholderPage(
          'Kontribusi: ${state.pathParameters['id']}',
        ),
      ),

      // Admin panel (nested)
      GoRoute(
        path: Routes.adminPanel,
        builder: (_, _) => const _PlaceholderPage('Panel Admin'),
        routes: [
          GoRoute(
            path: 'words',
            builder: (_, _) => const _PlaceholderPage('Manajemen Kata'),
          ),
          GoRoute(
            path: 'words/create',
            builder: (_, _) => const _PlaceholderPage('Tambah Kata'),
          ),
          GoRoute(
            path: 'words/:id/edit',
            builder: (context, state) => _PlaceholderPage(
              'Edit Kata: ${state.pathParameters['id']}',
            ),
          ),
          GoRoute(
            path: 'moderasi/antrian',
            builder: (_, _) => const _PlaceholderPage('Antrian Moderasi'),
          ),
          GoRoute(
            path: 'moderasi/kontribusi/:id',
            builder: (context, state) => _PlaceholderPage(
              'Review: ${state.pathParameters['id']}',
            ),
          ),
          GoRoute(
            path: 'moderasi/komentar',
            builder: (_, _) => const _PlaceholderPage('Komentar Ditandai'),
          ),
          GoRoute(
            path: 'pengguna',
            builder: (_, _) => const _PlaceholderPage('Manajemen Pengguna'),
          ),
          GoRoute(
            path: 'pengguna/:id',
            builder: (context, state) => _PlaceholderPage(
              'Pengguna: ${state.pathParameters['id']}',
            ),
          ),
          GoRoute(
            path: 'ai/permintaan',
            builder: (_, _) => const _PlaceholderPage('Permintaan AI'),
          ),
          GoRoute(
            path: 'ai/permintaan/:id',
            builder: (context, state) => _PlaceholderPage(
              'Permintaan AI: ${state.pathParameters['id']}',
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
