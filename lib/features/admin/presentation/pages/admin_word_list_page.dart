import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../dictionary/domain/entities/word.dart';
import '../../../dictionary/domain/entities/word_class.dart';
import '../../../dictionary/presentation/widgets/source_badge.dart';
import '../../../dictionary/presentation/widgets/word_class_chip.dart';
import '../bloc/admin_word_bloc.dart';
import '../bloc/admin_word_event.dart';
import '../bloc/admin_word_state.dart';
import '../widgets/admin_guard.dart';

class AdminWordListPage extends StatefulWidget {
  const AdminWordListPage({super.key});

  @override
  State<AdminWordListPage> createState() => _AdminWordListPageState();
}

class _AdminWordListPageState extends State<AdminWordListPage> {
  final _searchCtrl = TextEditingController();
  WordClass? _filterClass;
  WordStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    context.read<AdminWordBloc>().add(const LoadAdminWords());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _reload() {
    context.read<AdminWordBloc>().add(LoadAdminWords(
          query: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
          wordClass: _filterClass,
          status: _filterStatus,
        ));
  }

  void _confirmDelete(BuildContext context, String wordId, String banjar) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        key: const Key('delete_dialog'),
        title: const Text('Hapus Kata'),
        content: Text('Hapus "$banjar"? Kata akan disembunyikan (soft-delete).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminWordBloc>().add(DeleteWordEvent(wordId));
            },
            child: const Text('Hapus',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manajemen Kata'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Tambah Kata',
              onPressed: () => context.push(Routes.adminWordCreate),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Cari kata Banjar...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchCtrl.clear();
                            _reload();
                          },
                        )
                      : null,
                ),
                onSubmitted: (_) => _reload(),
                onChanged: (_) => setState(() {}),
              ),
            ),
            BlocBuilder<AdminWordBloc, AdminWordState>(
              builder: (context, state) {
                return switch (state) {
                  AdminWordLoading() => const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  AdminWordError(failure: final f) => Expanded(
                      child: Center(child: Text(f.message)),
                    ),
                  AdminWordLoaded(words: final words) ||
                  AdminWordDeleted(words: final words) =>
                    Expanded(
                      child: words.isEmpty
                          ? const Center(child: Text('Tidak ada kata ditemukan.'))
                          : ListView.builder(
                              itemCount: words.length,
                              itemBuilder: (ctx, i) {
                                final word = words[i];
                                return ListTile(
                                  title: Text(
                                    word.banjar,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700),
                                  ),
                                  subtitle: Text(word.primaryMeaning,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  leading: WordClassChip(wordClass: word.wordClass),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SourceBadge(source: word.source),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined),
                                        tooltip: 'Edit',
                                        onPressed: () => context.push(
                                          Routes.adminWordEditPath(word.id),
                                        ),
                                      ),
                                      IconButton(
                                        key: Key('delete_${word.id}'),
                                        icon: const Icon(Icons.delete_outline,
                                            color: AppColors.error),
                                        tooltip: 'Hapus',
                                        onPressed: () => _confirmDelete(
                                          context,
                                          word.id,
                                          word.banjar,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  _ => const Expanded(child: SizedBox.shrink()),
                };
              },
            ),
          ],
        ),
      ),
    );
  }
}
