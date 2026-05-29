import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../domain/entities/contribution.dart';
import '../bloc/contribution_bloc.dart';
import '../bloc/contribution_event.dart';
import '../bloc/contribution_state.dart';
import '../widgets/contribution_card.dart';

class MyContributionsPage extends StatefulWidget {
  const MyContributionsPage({super.key});

  @override
  State<MyContributionsPage> createState() => _MyContributionsPageState();
}

class _MyContributionsPageState extends State<MyContributionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  static const _tabs = [
    (label: 'Semua', status: null as ContributionStatus?),
    (label: 'Menunggu', status: ContributionStatus.pending),
    (label: 'Disetujui', status: ContributionStatus.approved),
    (label: 'Ditolak', status: ContributionStatus.rejected),
    (label: 'Dicabut', status: ContributionStatus.withdrawn),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    context
        .read<ContributionBloc>()
        .add(const LoadContributions());
    _tabCtrl.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabCtrl.indexIsChanging) return;
    context.read<ContributionBloc>().add(
          LoadContributions(filterStatus: _tabs[_tabCtrl.index].status),
        );
  }

  @override
  void dispose() {
    _tabCtrl.removeListener(_onTabChanged);
    _tabCtrl.dispose();
    super.dispose();
  }

  void _confirmWithdraw(BuildContext context, Contribution contribution) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cabut Kontribusi'),
        content: const Text('Yakin ingin mencabut kontribusi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ContributionBloc>().add(
                    WithdrawContributionEvent(
                      contributionId: contribution.id,
                      currentStatus: contribution.status,
                    ),
                  );
            },
            child: const Text('Cabut'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontribusiku'),
        bottom: TabBar(
          key: const Key('contribution_tabs'),
          controller: _tabCtrl,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
        ),
      ),
      body: BlocBuilder<ContributionBloc, ContributionState>(
        builder: (context, state) {
          return switch (state) {
            ContributionLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            ContributionError(failure: final f) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(f.message),
                    TextButton(
                      onPressed: () => context.read<ContributionBloc>().add(
                            const LoadContributions(),
                          ),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            ContributionLoaded(contributions: final items) ||
            ContributionWithdrawn(contributions: final items) =>
              items.isEmpty
                  ? const Center(child: Text('Belum ada kontribusi.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: items.length,
                      itemBuilder: (ctx, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ContributionCard(
                          contribution: items[i],
                          onTap: () => context.push(
                            Routes.contributionDetailPath(items[i].id),
                          ),
                          onWithdraw: items[i].status ==
                                  ContributionStatus.pending
                              ? () => _confirmWithdraw(context, items[i])
                              : null,
                        ),
                      ),
                    ),
            ContributionWithdrawing(currentContributions: final items) =>
              ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                itemBuilder: (ctx, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ContributionCard(contribution: items[i]),
                ),
              ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}
