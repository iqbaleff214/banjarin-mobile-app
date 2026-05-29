import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
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
                  _KomentarTab(),
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
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Komentar tersedia di Phase 3.'),
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
