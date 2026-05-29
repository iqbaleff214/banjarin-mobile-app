import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../domain/entities/ai_request.dart';
import '../bloc/ai_request_bloc.dart';
import '../bloc/ai_request_event.dart';
import '../bloc/ai_request_state.dart';
import '../widgets/admin_guard.dart';
import '../widgets/ai_request_card.dart';

class AdminAIRequestsPage extends StatefulWidget {
  const AdminAIRequestsPage({super.key});

  @override
  State<AdminAIRequestsPage> createState() => _AdminAIRequestsPageState();
}

class _AdminAIRequestsPageState extends State<AdminAIRequestsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  static const _tabs = [
    (label: 'Semua', reviewStatus: null as AIReviewStatus?),
    (label: 'Menunggu Review', reviewStatus: AIReviewStatus.unreviewed),
    (label: 'Disetujui', reviewStatus: AIReviewStatus.approved),
    (label: 'Ditolak', reviewStatus: AIReviewStatus.rejected),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    context.read<AIRequestBloc>().add(const LoadAIRequests());
    _tabCtrl.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabCtrl.indexIsChanging) return;
    context.read<AIRequestBloc>().add(LoadAIRequests(
          filterReviewStatus: _tabs[_tabCtrl.index].reviewStatus,
        ));
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
          title: const Text('Permintaan AI'),
          bottom: TabBar(
            controller: _tabCtrl,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
          ),
        ),
        body: BlocBuilder<AIRequestBloc, AIRequestState>(
          builder: (context, state) {
            final requests = switch (state) {
              AIRequestLoaded(requests: final r) => r,
              Reviewing(currentRequests: final r) => r,
              Reviewed(requests: final r) => r,
              _ => <AIRequest>[],
            };

            if (state is AIRequestLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is AIRequestError) {
              return Center(child: Text(state.failure.message));
            }
            if (requests.isEmpty) {
              return const Center(child: Text('Tidak ada permintaan AI.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: requests.length,
              itemBuilder: (ctx, i) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AIRequestCard(
                  request: requests[i],
                  onTap: () => context.push(
                    Routes.adminAiRequestDetailPath(requests[i].id),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
