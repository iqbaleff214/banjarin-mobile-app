import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../identity/domain/entities/user_role.dart';
import '../bloc/user_mgmt_bloc.dart';
import '../bloc/user_mgmt_event.dart';
import '../bloc/user_mgmt_state.dart';
import '../widgets/admin_guard.dart';

class AdminUserListPage extends StatefulWidget {
  const AdminUserListPage({super.key});

  @override
  State<AdminUserListPage> createState() => _AdminUserListPageState();
}

class _AdminUserListPageState extends State<AdminUserListPage> {
  final _searchCtrl = TextEditingController();
  UserRole? _filterRole;
  bool? _filterActive;

  @override
  void initState() {
    super.initState();
    context.read<UserMgmtBloc>().add(const LoadAdminUsers());
  }

  void _reload() {
    context.read<UserMgmtBloc>().add(LoadAdminUsers(
          query: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
          role: _filterRole,
          isActive: _filterActive,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: Scaffold(
        appBar: AppBar(title: const Text('Manajemen Pengguna')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  hintText: 'Cari nama atau email...',
                  prefixIcon: Icon(Icons.search),
                ),
                onSubmitted: (_) => _reload(),
              ),
            ),
            Expanded(
              child: BlocBuilder<UserMgmtBloc, UserMgmtState>(
                builder: (context, state) {
                  final users = switch (state) {
                    UserMgmtLoaded(users: final u) => u,
                    Banned(users: final u) => u,
                    RoleChanged(users: final u) => u,
                    Banning(currentUsers: final u) => u,
                    ChangingRole(currentUsers: final u) => u,
                    _ => [],
                  };

                  if (state is UserMgmtLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (users.isEmpty) {
                    return const Center(child: Text('Tidak ada pengguna.'));
                  }

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (ctx, i) {
                      final u = users[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: u.isAdmin
                              ? AppColors.ai
                              : AppColors.primary,
                          child: Text(
                            u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(u.name),
                        subtitle: Text(u.email),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!u.isActive)
                              const Chip(
                                label: Text('Banned',
                                    style: TextStyle(fontSize: 10)),
                                backgroundColor: Color(0x20EB5757),
                              ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () => context.push(
                          Routes.adminUserDetailPath(u.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
