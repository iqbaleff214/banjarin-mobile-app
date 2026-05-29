import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) {
          return _GuestView();
        }
        return BlocProvider<ProfileBloc>(
          create: (_) => context.read<ProfileBloc>()..add(const LoadProfile()),
          child: _AuthenticatedView(isAdmin: authState.user.isAdmin),
        );
      },
    );
  }
}

class _GuestView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.person_outline, size: 72, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'Masuk untuk akses penuh',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                key: const Key('guest_login_button'),
                onPressed: () => context.push(Routes.login),
                child: const Text('Masuk'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                key: const Key('guest_register_button'),
                onPressed: () => context.push(Routes.register),
                child: const Text('Daftar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthenticatedView extends StatelessWidget {
  final bool isAdmin;

  const _AuthenticatedView({required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Profil')),
          body: switch (state) {
            ProfileLoading() => const Center(child: CircularProgressIndicator()),
            ProfileError(failure: final f, currentUser: null) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(f.message),
                    TextButton(
                      onPressed: () => context.read<ProfileBloc>().add(const LoadProfile()),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            ProfileLoaded(user: final user) || ProfileError(currentUser: final user?) => _ProfileContent(
                user: user,
                isAdmin: isAdmin,
              ),
            _ => const SizedBox.shrink(),
          },
        );
      },
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final dynamic user;
  final bool isAdmin;

  const _ProfileContent({required this.user, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final initial = (user.name as String).isNotEmpty
        ? (user.name as String)[0].toUpperCase()
        : '?';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Avatar
        Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary,
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Name
        Center(
          child: Text(
            user.name as String,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        // Email
        Center(
          child: Text(
            user.email as String,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 8),
        // Role badge
        Center(
          child: Chip(
            label: Text(
              isAdmin ? 'Admin' : 'Pengguna',
              style: const TextStyle(fontSize: 12),
            ),
            backgroundColor: isAdmin
                ? AppColors.ai.withValues(alpha: 0.15)
                : AppColors.community.withValues(alpha: 0.15),
          ),
        ),
        // Email unverified banner
        if (!(user.emailVerified as bool)) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Verifikasi emailmu untuk berkontribusi.',
              key: Key('unverified_banner'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
        const SizedBox(height: 24),
        const Divider(),
        // Menu items
        ListTile(
          leading: const Icon(Icons.edit_outlined),
          title: const Text('Edit Profil'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(Routes.editProfile),
        ),
        ListTile(
          leading: const Icon(Icons.lock_outline),
          title: const Text('Ubah Kata Sandi'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(Routes.changePassword),
        ),
        ListTile(
          leading: const Icon(Icons.volunteer_activism_outlined),
          title: const Text('Kontribusiku'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(Routes.myContributions),
        ),
        if (isAdmin) ...[
          ListTile(
            key: const Key('admin_panel_tile'),
            leading: const Icon(Icons.admin_panel_settings_outlined),
            title: const Text('Panel Admin'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.adminPanel),
          ),
        ],
        const Divider(),
        ListTile(
          key: const Key('logout_tile'),
          leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
          title: Text(
            'Keluar',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          onTap: () => _confirmLogout(context),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<AuthBloc>().add(const AuthLogout());
              context.go(Routes.home);
            },
            child: Text(
              'Keluar',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
