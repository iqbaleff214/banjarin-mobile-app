import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/moderation_bloc.dart';
import '../bloc/moderation_event.dart';
import '../bloc/moderation_state.dart';
import '../widgets/admin_guard.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<ModerationBloc>().add(const LoadModerationStats());
  }

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: Scaffold(
        appBar: AppBar(title: const Text('Panel Admin')),
        body: BlocBuilder<ModerationBloc, ModerationState>(
          builder: (context, state) {
            final stats = state is ModerationLoaded ? state.stats : null;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Stat cards
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        key: const Key('stat_pending'),
                        label: 'Kontribusi Menunggu',
                        value: stats?.pendingContributions ?? 0,
                        color: AppColors.warning,
                        icon: Icons.pending_actions,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        key: const Key('stat_flagged'),
                        label: 'Komentar Ditandai',
                        value: stats?.flaggedComments ?? 0,
                        color: AppColors.error,
                        icon: Icons.flag,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        key: const Key('stat_approved'),
                        label: 'Disetujui Minggu Ini',
                        value: stats?.approvedThisWeek ?? 0,
                        color: AppColors.success,
                        icon: Icons.check_circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        key: const Key('stat_rejected'),
                        label: 'Ditolak Minggu Ini',
                        value: stats?.rejectedThisWeek ?? 0,
                        color: Colors.grey,
                        icon: Icons.cancel,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Quick links
                const Divider(),
                _QuickLink(
                  icon: Icons.queue,
                  label: 'Antrian Moderasi',
                  onTap: () => context.push(Routes.adminModerationQueue),
                ),
                _QuickLink(
                  icon: Icons.flag_outlined,
                  label: 'Komentar Ditandai',
                  onTap: () => context.push(Routes.adminFlaggedComments),
                ),
                _QuickLink(
                  icon: Icons.book_outlined,
                  label: 'Manajemen Kata',
                  onTap: () => context.push(Routes.adminWords),
                ),
                _QuickLink(
                  icon: Icons.people_outline,
                  label: 'Manajemen Pengguna',
                  onTap: () => context.push(Routes.adminUsers),
                ),
                _QuickLink(
                  icon: Icons.auto_awesome,
                  label: 'Permintaan AI',
                  onTap: () => context.push(Routes.adminAiRequests),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
