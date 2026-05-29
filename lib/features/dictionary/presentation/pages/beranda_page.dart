import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../identity/presentation/bloc/auth_bloc.dart';
import '../../../identity/presentation/bloc/auth_state.dart';

import '../../domain/entities/sort_words.dart';
import '../../domain/entities/word_class.dart';
import '../bloc/word_list_bloc.dart';
import '../bloc/word_list_event.dart';
import '../bloc/word_list_state.dart';
import '../widgets/word_card.dart';
import '../widgets/word_skeleton.dart';

class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WordListBloc, WordListState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Text(
                  'Banjarin',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Cari',
                onPressed: () => context.go(Routes.search),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<WordListBloc>().add(const RefreshWords());
              // wait for loading to finish
              await Future.delayed(const Duration(milliseconds: 300));
            },
            child: Column(
              children: [
                _FilterBar(state: state),
                _SortBar(state: state),
                Expanded(child: _WordList(state: state)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterBar extends StatelessWidget {
  final WordListState state;

  const _FilterBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final classes = [null, ...WordClass.values];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: classes.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final wc = classes[i];
          final selected = state.filterWordClass == wc;
          return FilterChip(
            key: wc == null ? const Key('filter_all') : Key('filter_${wc.name}'),
            label: Text(wc == null ? 'Semua' : wc.label),
            selected: selected,
            onSelected: (_) => context.read<WordListBloc>().add(
                  FilterChanged(wordClass: wc),
                ),
          );
        },
      ),
    );
  }
}

class _SortBar extends StatelessWidget {
  final WordListState state;

  const _SortBar({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Text('Urutkan:', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: 8),
          ...SortWords.values.map((s) {
            final label = switch (s) {
              SortWords.alphabetical => 'Abjad',
              SortWords.most_voted => 'Terpopuler',
              SortWords.recently_added => 'Terbaru',
            };
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: ChoiceChip(
                label: Text(label, style: const TextStyle(fontSize: 11)),
                selected: state.sort == s,
                onSelected: (_) =>
                    context.read<WordListBloc>().add(SortChanged(s)),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _WordList extends StatelessWidget {
  final WordListState state;

  const _WordList({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.words.isEmpty) {
      return ListView.builder(
        key: const Key('skeleton_list'),
        padding: const EdgeInsets.all(12),
        itemCount: 8,
        itemBuilder: (_, _) => const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: WordSkeleton(),
        ),
      );
    }

    if (!state.isLoading && state.words.isEmpty && state.error == null) {
      return _EmptyState();
    }

    if (state.error != null && state.words.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.error!.message),
            TextButton(
              onPressed: () =>
                  context.read<WordListBloc>().add(const LoadWords()),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 200 &&
            state.hasMore &&
            !state.isLoadingMore) {
          context.read<WordListBloc>().add(const LoadMoreWords());
        }
        return false;
      },
      child: ListView.builder(
        key: const Key('word_list'),
        padding: const EdgeInsets.all(12),
        itemCount: state.words.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (i == state.words.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final word = state.words[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: WordCard(
              word: word,
              onTap: () => context.push(Routes.wordDetailPath(word.id)),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isAuth = context.watch<AuthBloc>().state is Authenticated;
    return EmptyState(
      icon: Icons.search_off,
      message: 'Tidak ada kata ditemukan',
      ctaText: isAuth ? 'Kontribusikan kata ini' : 'Masuk untuk berkontribusi',
      onCta: isAuth
          ? () => context.push(Routes.contributionNewWord)
          : () => context.push(Routes.login),
    );
  }
}
