import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../community/domain/entities/contribution.dart';
import '../bloc/moderation_bloc.dart';
import '../bloc/moderation_event.dart';
import '../bloc/moderation_state.dart';
import '../widgets/admin_guard.dart';

class AdminModerationQueuePage extends StatefulWidget {
  const AdminModerationQueuePage({super.key});

  @override
  State<AdminModerationQueuePage> createState() =>
      _AdminModerationQueuePageState();
}

class _AdminModerationQueuePageState extends State<AdminModerationQueuePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  static const _tabs = [
    (label: 'Semua', type: null as ContributionType?),
    (label: 'Kata Baru', type: ContributionType.new_word),
    (label: 'Definisi', type: ContributionType.new_definition),
    (label: 'Contoh', type: ContributionType.new_example),
    (label: 'Edit Kata', type: ContributionType.edit_word),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    context.read<ModerationBloc>().add(const LoadModerationQueue());
    _tabCtrl.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabCtrl.indexIsChanging) return;
    context.read<ModerationBloc>().add(
          LoadModerationQueue(type: _tabs[_tabCtrl.index].type),
        );
  }

  @override
  void dispose() {
    _tabCtrl.removeListener(_onTabChanged);
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Antrian Moderasi'),
          bottom: TabBar(
            controller: _tabCtrl,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
          ),
        ),
        body: BlocBuilder<ModerationBloc, ModerationState>(
          builder: (context, state) {
            final queue = switch (state) {
              ModerationLoaded(queue: final q) => q,
              ModerationApproving(currentQueue: final q) => q,
              ModerationRejecting(currentQueue: final q) => q,
              ModerationApproved(queue: final q) => q,
              ModerationRejected(queue: final q) => q,
              _ => <Contribution>[],
            };

            if (state is ModerationLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (queue.isEmpty) {
              return const Center(child: Text('Antrian kosong.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: queue.length,
              itemBuilder: (ctx, i) {
                final c = queue[i];
                return Card(
                  child: ListTile(
                    title: Text(
                      c.type.label,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kontributor: ${c.contributorId}'),
                        Text(
                          'Dikirim: ${c.submittedAt.day}/${c.submittedAt.month}/${c.submittedAt.year}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(
                      Routes.adminContributionReviewPath(c.id),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
