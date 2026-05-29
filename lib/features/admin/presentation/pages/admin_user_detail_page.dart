import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../identity/domain/entities/user.dart';
import '../../../identity/domain/entities/user_role.dart';
import '../bloc/user_mgmt_bloc.dart';
import '../bloc/user_mgmt_event.dart';
import '../bloc/user_mgmt_state.dart';
import '../widgets/admin_guard.dart';

class AdminUserDetailPage extends StatefulWidget {
  final String userId;

  const AdminUserDetailPage({super.key, required this.userId});

  @override
  State<AdminUserDetailPage> createState() => _AdminUserDetailPageState();
}

class _AdminUserDetailPageState extends State<AdminUserDetailPage> {
  final _banReasonCtrl = TextEditingController();

  @override
  void dispose() {
    _banReasonCtrl.dispose();
    super.dispose();
  }

  User? _findUser(UserMgmtState state) {
    final users = switch (state) {
      UserMgmtLoaded(users: final u) => u,
      Banned(users: final u) => u,
      RoleChanged(users: final u) => u,
      Banning(currentUsers: final u) => u,
      ChangingRole(currentUsers: final u) => u,
      _ => <User>[],
    };
    return users.where((u) => u.id == widget.userId).firstOrNull;
  }

  void _showBanDialog(BuildContext context) {
    _banReasonCtrl.clear();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ban Pengguna'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Masukkan alasan ban:'),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (context, setD) => TextField(
                controller: _banReasonCtrl,
                onChanged: (_) => setD(() {}),
                decoration: const InputDecoration(hintText: 'Alasan...'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          StatefulBuilder(
            builder: (context, setD) => TextButton(
              key: const Key('confirm_ban_button'),
              onPressed: _banReasonCtrl.text.trim().isEmpty
                  ? null
                  : () {
                      Navigator.pop(ctx);
                      context.read<UserMgmtBloc>().add(BanUserEvent(
                            userId: widget.userId,
                            reason: _banReasonCtrl.text.trim(),
                          ));
                    },
              child: const Text('Ban',
                  style: TextStyle(color: AppColors.error)),
            ),
          ),
        ],
      ),
    );
  }

  void _showUnbanDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unban Pengguna'),
        content: const Text('Yakin ingin mencabut ban pengguna ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<UserMgmtBloc>().add(UnbanUserEvent(widget.userId));
            },
            child: const Text('Unban'),
          ),
        ],
      ),
    );
  }

  void _showRoleDialog(BuildContext context, User user) {
    final newRole =
        user.role == UserRole.admin ? UserRole.user : UserRole.admin;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah Role'),
        content: Text(
          'Ubah role "${user.name}" menjadi ${newRole.name.toUpperCase()}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            key: const Key('confirm_role_button'),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<UserMgmtBloc>().add(ChangeUserRoleEvent(
                    userId: widget.userId,
                    newRole: newRole,
                  ));
            },
            child: const Text('Ubah'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: BlocListener<UserMgmtBloc, UserMgmtState>(
        listener: (context, state) {
          if (state is Banned || state is RoleChanged) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Berhasil diperbarui.')),
            );
          }
        },
        child: BlocBuilder<UserMgmtBloc, UserMgmtState>(
          builder: (context, state) {
            final user = _findUser(state);
            if (user == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Detail Pengguna')),
                body: const Center(child: Text('Pengguna tidak ditemukan.')),
              );
            }

            return Scaffold(
              appBar: AppBar(
                title: Text(user.name),
                actions: [
                  if (context.canPop())
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => context.pop(),
                    ),
                ],
              ),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Avatar
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor:
                          user.isAdmin ? AppColors.ai : AppColors.primary,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(user.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  Center(child: Text(user.email)),
                  const SizedBox(height: 8),
                  Center(
                    child: Chip(
                      label: Text(user.role.name.toUpperCase()),
                      backgroundColor: user.isAdmin
                          ? AppColors.ai.withValues(alpha: 0.15)
                          : AppColors.community.withValues(alpha: 0.15),
                    ),
                  ),
                  if (!user.isActive) ...[
                    const SizedBox(height: 8),
                    const Center(
                      child: Chip(
                        label: Text('BANNED',
                            style: TextStyle(color: AppColors.error)),
                        backgroundColor: Color(0x20EB5757),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Divider(),
                  // Ban / Unban
                  if (user.isActive)
                    ListTile(
                      key: const Key('ban_button'),
                      leading: const Icon(Icons.block, color: AppColors.error),
                      title: const Text('Ban Pengguna',
                          style: TextStyle(color: AppColors.error)),
                      onTap: () => _showBanDialog(context),
                    )
                  else
                    ListTile(
                      key: const Key('unban_button'),
                      leading: const Icon(Icons.check_circle_outline,
                          color: AppColors.success),
                      title: const Text('Unban Pengguna'),
                      onTap: () => _showUnbanDialog(context),
                    ),
                  // Change role
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings_outlined),
                    title: Text(
                      user.isAdmin
                          ? 'Ubah ke Role User'
                          : 'Ubah ke Role Admin',
                    ),
                    onTap: () => _showRoleDialog(context, user),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
