import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/contribution.dart';
import '../bloc/contribution_bloc.dart';
import '../bloc/contribution_event.dart';
import '../bloc/contribution_state.dart';

class ContributionDetailPage extends StatefulWidget {
  final String contributionId;

  const ContributionDetailPage({super.key, required this.contributionId});

  @override
  State<ContributionDetailPage> createState() =>
      _ContributionDetailPageState();
}

class _ContributionDetailPageState extends State<ContributionDetailPage> {
  Contribution? _contribution;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Get detail from ContributionBloc if already loaded, otherwise use inline
    final state = context.read<ContributionBloc>().state;
    if (state is ContributionLoaded) {
      final found = state.contributions
          .where((c) => c.id == widget.contributionId)
          .toList();
      if (found.isNotEmpty) {
        if (mounted) {
          setState(() {
            _contribution = found.first;
            _loading = false;
          });
        }
        return;
      }
    }
    // Fallback — trigger get detail (re-using LoadContributions is not ideal;
    // for Phase 5 we show from existing list or navigate back if not found)
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Kontribusi')),
      body: BlocBuilder<ContributionBloc, ContributionState>(
        builder: (context, state) {
          final contribution = _contribution ??
              (state is ContributionLoaded
                  ? state.contributions
                      .where((c) => c.id == widget.contributionId)
                      .firstOrNull
                  : null);

          if (_loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (contribution == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Kontribusi tidak ditemukan.'),
                  TextButton(
                    onPressed: () => context.read<ContributionBloc>().add(
                          const LoadContributions(),
                        ),
                    child: const Text('Muat Ulang'),
                  ),
                ],
              ),
            );
          }

          return _ContributionDetailView(contribution: contribution);
        },
      ),
    );
  }
}

class _ContributionDetailView extends StatelessWidget {
  final Contribution contribution;

  const _ContributionDetailView({required this.contribution});

  String get _statusLabel => switch (contribution.status) {
        ContributionStatus.pending => 'Menunggu',
        ContributionStatus.approved => 'Disetujui',
        ContributionStatus.rejected => 'Ditolak',
        ContributionStatus.withdrawn => 'Dicabut',
      };

  Color get _statusColor => switch (contribution.status) {
        ContributionStatus.pending => AppColors.warning,
        ContributionStatus.approved => AppColors.success,
        ContributionStatus.rejected => AppColors.error,
        ContributionStatus.withdrawn => Colors.grey,
      };

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Type + Status row
        Row(
          children: [
            _Chip(label: contribution.type.label, color: AppColors.primary),
            const SizedBox(width: 8),
            _Chip(label: _statusLabel, color: _statusColor),
          ],
        ),
        const SizedBox(height: 16),
        // Submitted date
        Text(
          'Dikirim pada ${_fmt(contribution.submittedAt)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
        if (contribution.reviewedAt != null)
          Text(
            'Ditinjau pada ${_fmt(contribution.reviewedAt!)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        const SizedBox(height: 20),
        const Divider(),
        // Payload
        Text(
          'Isi Kontribusi',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        _PayloadView(type: contribution.type, payload: contribution.payload),
        // Reviewer note
        if (contribution.reviewerNote != null) ...[
          const SizedBox(height: 16),
          const Divider(),
          Text(
            'Catatan Reviewer',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(contribution.reviewerNote!),
          ),
        ],
      ],
    );
  }

  String _fmt(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';
}

class _PayloadView extends StatelessWidget {
  final ContributionType type;
  final Map<String, dynamic> payload;

  const _PayloadView({required this.type, required this.payload});

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      ContributionType.new_word => _NewWordPayload(payload: payload),
      ContributionType.new_definition => _SimplePayload(
          label: 'Definisi',
          value: payload['meaning'] as String? ?? '',
        ),
      ContributionType.new_example => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SimplePayload(
              label: 'Kalimat Banjar',
              value: payload['banjar_sentence'] as String? ?? '',
            ),
            const SizedBox(height: 8),
            _SimplePayload(
              label: 'Terjemahan',
              value: payload['indonesian_translation'] as String? ?? '',
            ),
          ],
        ),
      ContributionType.edit_word => _EditWordPayload(payload: payload),
    };
  }
}

class _SimplePayload extends StatelessWidget {
  final String label;
  final String value;

  const _SimplePayload({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _NewWordPayload extends StatelessWidget {
  final Map<String, dynamic> payload;

  const _NewWordPayload({required this.payload});

  @override
  Widget build(BuildContext context) {
    final defs = (payload['definitions'] as List<dynamic>?) ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SimplePayload(
            label: 'Kata', value: payload['banjar'] as String? ?? ''),
        if ((payload['banjar_syllabified'] as String?) != null) ...[
          const SizedBox(height: 8),
          _SimplePayload(
              label: 'Suku Kata',
              value: payload['banjar_syllabified'] as String),
        ],
        const SizedBox(height: 8),
        _SimplePayload(
            label: 'Kelas Kata', value: payload['word_class'] as String? ?? ''),
        const SizedBox(height: 8),
        Text('Definisi (${defs.length})',
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ...defs.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${e.key + 1}. ${(e.value as Map)['meaning'] ?? ''}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )),
      ],
    );
  }
}

class _EditWordPayload extends StatelessWidget {
  final Map<String, dynamic> payload;

  const _EditWordPayload({required this.payload});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (payload['banjar'] != null)
          _SimplePayload(label: 'Kata', value: payload['banjar'] as String),
        if (payload['word_class'] != null) ...[
          const SizedBox(height: 8),
          _SimplePayload(
              label: 'Kelas Kata', value: payload['word_class'] as String),
        ],
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
