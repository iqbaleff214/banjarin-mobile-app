import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../community/domain/entities/vote.dart';
import '../../../community/presentation/bloc/bookmark_bloc.dart';
import '../../../community/presentation/bloc/bookmark_event.dart';
import '../../../community/presentation/bloc/bookmark_state.dart';
import '../../../community/presentation/bloc/comment_bloc.dart';
import '../../../community/presentation/bloc/comment_event.dart';
import '../../../community/presentation/bloc/comment_state.dart';
import '../../../community/presentation/widgets/comment_input.dart';
import '../../../community/presentation/widgets/comment_tile.dart';
import '../../../community/presentation/widgets/vote_row.dart';
import '../../../identity/presentation/bloc/auth_bloc.dart';
import '../../../identity/presentation/bloc/auth_state.dart';
import '../../domain/entities/definition.dart';
import '../../domain/entities/example.dart';
import '../../domain/entities/word.dart';
import '../../domain/entities/word_summary.dart';
import '../bloc/word_detail_bloc.dart';
import '../bloc/word_detail_event.dart';
import '../bloc/word_detail_state.dart';
import '../widgets/definition_tile.dart';
import '../widgets/example_tile.dart';
import '../widgets/related_word_chip.dart';
import '../widgets/source_badge.dart';
import '../widgets/word_class_chip.dart';

class WordDetailPage extends StatefulWidget {
  final String wordId;

  const WordDetailPage({super.key, required this.wordId});

  @override
  State<WordDetailPage> createState() => _WordDetailPageState();
}

class _WordDetailPageState extends State<WordDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    context.read<WordDetailBloc>().add(LoadWordDetail(widget.wordId));
    context.read<BookmarkBloc>().add(CheckBookmarkStatus(widget.wordId));
    context.read<CommentBloc>().add(LoadComments(widget.wordId));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WordDetailBloc, WordDetailState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: switch (state) {
              WordDetailLoaded(word: final w) => _WordHeaderTitle(word: w),
              _ => const Text('Memuat...'),
            },
            bottom: TabBar(
              controller: _tabCtrl,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: const [
                Tab(text: 'Definisi'),
                Tab(text: 'Contoh'),
                Tab(text: 'Kata Terkait'),
                Tab(text: 'Komentar'),
              ],
            ),
          ),
          floatingActionButton: state is WordDetailLoaded
              ? _ContributeFAB(word: state.word, context: context)
              : null,
          body: switch (state) {
            WordDetailLoading() || WordDetailInitial() => const Center(
                child: CircularProgressIndicator(),
              ),
            WordDetailError(failure: final f) => _ErrorView(
                message: f.message,
                onRetry: () => context
                    .read<WordDetailBloc>()
                    .add(LoadWordDetail(widget.wordId)),
              ),
            WordDetailLoaded(
              word: final word,
              definitions: final defs,
              examples: final exs,
              relatedWords: final related,
            ) =>
              TabBarView(
                controller: _tabCtrl,
                children: [
                  _DefinisiTab(definitions: defs, word: word),
                  _ContohTab(examples: exs),
                  _KataTerkaitTab(relatedWords: related),
                  _KomentarTab(wordId: widget.wordId),
                ],
              ),
          },
        );
      },
    );
  }
}

class _WordHeaderTitle extends StatelessWidget {
  final Word word;

  const _WordHeaderTitle({required this.word});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isAuth = authState is Authenticated;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              key: const Key('word_title'),
              word.banjar,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            if (word.isHomonym)
              Text(
                '${word.homonymNumber}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const Spacer(),
            // Bookmark icon
            BlocBuilder<BookmarkBloc, BookmarkState>(
              builder: (context, state) {
                final isBookmarked = state is BookmarkLoaded
                    ? (state.isBookmarked ?? false)
                    : false;
                return IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                    color: isBookmarked ? AppColors.primary : null,
                  ),
                  tooltip: isBookmarked ? 'Hapus simpanan' : 'Simpan',
                  onPressed: () {
                    if (!isAuth) {
                      context.go(Routes.login);
                      return;
                    }
                    context.read<BookmarkBloc>().add(ToggleBookmark(
                          wordId: word.id,
                          isCurrentlyBookmarked: isBookmarked,
                        ));
                  },
                );
              },
            ),
          ],
        ),
        if (word.banjarSyllabified != null)
          Text(
            key: const Key('syllabified_form'),
            word.banjarSyllabified!,
            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
        Row(
          children: [
            WordClassChip(wordClass: word.wordClass),
            const SizedBox(width: 4),
            SourceBadge(source: word.source),
            const Spacer(),
            // Word-level vote
            VoteRow(
              targetId: word.id,
              targetType: VoteTargetType.word,
              isAuthenticated: isAuth,
            ),
          ],
        ),
      ],
    );
  }
}

class _DefinisiTab extends StatelessWidget {
  final List<Definition> definitions;
  final Word word;

  const _DefinisiTab({required this.definitions, required this.word});

  @override
  Widget build(BuildContext context) {
    if (definitions.isEmpty) {
      return const Center(child: Text('Belum ada definisi.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: definitions.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) => DefinitionTile(
        index: i + 1,
        definition: definitions[i],
      ),
    );
  }
}

class _ContohTab extends StatelessWidget {
  final List<Example> examples;

  const _ContohTab({required this.examples});

  @override
  Widget build(BuildContext context) {
    if (examples.isEmpty) {
      return const Center(child: Text('Belum ada contoh kalimat.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: examples.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) => ExampleTile(example: examples[i]),
    );
  }
}

class _KataTerkaitTab extends StatelessWidget {
  final List<WordSummary> relatedWords;

  const _KataTerkaitTab({required this.relatedWords});

  @override
  Widget build(BuildContext context) {
    if (relatedWords.isEmpty) {
      return const Center(child: Text('Tidak ada kata terkait.'));
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: relatedWords
            .map((w) => RelatedWordChip(
                  word: w,
                  onTap: () => context.push(Routes.wordDetailPath(w.id)),
                ))
            .toList(),
      ),
    );
  }
}

class _KomentarTab extends StatelessWidget {
  final String wordId;

  const _KomentarTab({required this.wordId});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isAuth = authState is Authenticated;
    final userId = switch (authState) {
      Authenticated(:final user) => user.id,
      _ => null,
    };

    return Column(
      children: [
        Expanded(
          child: BlocBuilder<CommentBloc, CommentState>(
            builder: (context, state) {
              return switch (state) {
                CommentsLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                CommentError(failure: final f, currentComments: null) => Center(
                    child: Text(f.message),
                  ),
                CommentsLoaded(comments: final comments) ||
                CommentAdded(comments: final comments) ||
                CommentUpdated(comments: final comments) ||
                CommentDeleted(comments: final comments) ||
                CommentPosting(currentComments: final comments) ||
                CommentEditing(currentComments: final comments) ||
                CommentError(currentComments: final comments?) =>
                  comments.isEmpty
                      ? const Center(
                          child: Text('Belum ada komentar. Jadilah yang pertama!'),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: comments.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (_, i) => CommentTile(
                            comment: comments[i],
                            currentUserId: userId,
                          ),
                        ),
                _ => const SizedBox.shrink(),
              };
            },
          ),
        ),
        CommentInput(wordId: wordId, isAuthenticated: isAuth),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Contribute FAB
// ---------------------------------------------------------------------------

class _ContributeFAB extends StatelessWidget {
  final Word word;
  final BuildContext context;

  const _ContributeFAB({required this.word, required this.context});

  @override
  Widget build(BuildContext outerContext) {
    final authState = outerContext.watch<AuthBloc>().state;
    final isAuth = authState is Authenticated;
    if (!isAuth) return const SizedBox.shrink();

    return FloatingActionButton(
      key: const Key('contribute_fab'),
      onPressed: () => _showBottomSheet(outerContext),
      tooltip: 'Kontribusi',
      child: const Icon(Icons.add),
    );
  }

  void _showBottomSheet(BuildContext ctx) {
    showModalBottomSheet<void>(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Kontribusi untuk "${word.banjar}"',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _OptionTile(
                icon: Icons.add_box_outlined,
                label: 'Kontribusikan kata baru',
                onTap: () {
                  Navigator.pop(ctx);
                  ctx.push(Routes.contributionNewWord);
                },
              ),
              _OptionTile(
                icon: Icons.menu_book_outlined,
                label: 'Tambah definisi',
                onTap: () {
                  Navigator.pop(ctx);
                  ctx.push(
                    '${Routes.contributionNewDefinition}'
                    '?wordId=${word.id}&wordBanjar=${Uri.encodeComponent(word.banjar)}',
                  );
                },
              ),
              _OptionTile(
                icon: Icons.format_quote_outlined,
                label: 'Tambah contoh kalimat',
                onTap: () {
                  Navigator.pop(ctx);
                  ctx.push(
                    '${Routes.contributionNewExample}'
                    '?wordId=${word.id}&wordBanjar=${Uri.encodeComponent(word.banjar)}',
                  );
                },
              ),
              _OptionTile(
                icon: Icons.edit_outlined,
                label: 'Usulkan perbaikan kata',
                onTap: () {
                  Navigator.pop(ctx);
                  ctx.push(
                    '${Routes.contributionEditWord}'
                    '?wordId=${word.id}&wordBanjar=${Uri.encodeComponent(word.banjar)}',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      onTap: onTap,
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }
}
