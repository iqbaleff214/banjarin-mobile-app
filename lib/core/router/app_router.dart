import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
            builder: (_, _) => const _PlaceholderPage('Beranda'),
          ),
          GoRoute(
            path: Routes.search,
            builder: (_, _) => const _PlaceholderPage('Cari'),
          ),
          GoRoute(
            path: Routes.translate,
            builder: (_, _) => const _PlaceholderPage('Terjemah'),
          ),
          GoRoute(
            path: Routes.bookmarks,
            builder: (_, _) => const _PlaceholderPage('Simpanan'),
          ),
          GoRoute(
            path: Routes.profile,
            builder: (_, _) => const _PlaceholderPage('Profil'),
          ),
        ],
      ),

      // Word detail (outside shell — no bottom nav on detail)
      GoRoute(
        path: Routes.wordDetail,
        builder: (context, state) => _PlaceholderPage(
          'Kata: ${state.pathParameters['id']}',
        ),
      ),

      // Auth routes
      GoRoute(
        path: Routes.login,
        builder: (_, _) => const _PlaceholderPage('Masuk'),
      ),
      GoRoute(
        path: Routes.register,
        builder: (_, _) => const _PlaceholderPage('Daftar'),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (_, _) => const _PlaceholderPage('Lupa Kata Sandi'),
      ),
      GoRoute(
        path: Routes.resetPassword,
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return _PlaceholderPage('Reset Kata Sandi: $token');
        },
      ),

      // Deep link: email verification
      GoRoute(
        path: Routes.verifyEmail,
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return _PlaceholderPage('Verifikasi Email: $token');
        },
      ),

      // Profile sub-routes
      GoRoute(
        path: Routes.editProfile,
        builder: (_, _) => const _PlaceholderPage('Edit Profil'),
      ),
      GoRoute(
        path: Routes.changePassword,
        builder: (_, _) => const _PlaceholderPage('Ubah Kata Sandi'),
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
            builder: (_, _) =>
                const _PlaceholderPage('Manajemen Kata'),
          ),
          GoRoute(
            path: 'words/create',
            builder: (_, _) =>
                const _PlaceholderPage('Tambah Kata'),
          ),
          GoRoute(
            path: 'words/:id/edit',
            builder: (context, state) => _PlaceholderPage(
              'Edit Kata: ${state.pathParameters['id']}',
            ),
          ),
          GoRoute(
            path: 'moderasi/antrian',
            builder: (_, _) =>
                const _PlaceholderPage('Antrian Moderasi'),
          ),
          GoRoute(
            path: 'moderasi/kontribusi/:id',
            builder: (context, state) => _PlaceholderPage(
              'Review: ${state.pathParameters['id']}',
            ),
          ),
          GoRoute(
            path: 'moderasi/komentar',
            builder: (_, _) =>
                const _PlaceholderPage('Komentar Ditandai'),
          ),
          GoRoute(
            path: 'pengguna',
            builder: (_, _) =>
                const _PlaceholderPage('Manajemen Pengguna'),
          ),
          GoRoute(
            path: 'pengguna/:id',
            builder: (context, state) => _PlaceholderPage(
              'Pengguna: ${state.pathParameters['id']}',
            ),
          ),
          GoRoute(
            path: 'ai/permintaan',
            builder: (_, _) =>
                const _PlaceholderPage('Permintaan AI'),
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
