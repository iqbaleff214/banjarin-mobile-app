import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';

import '../../domain/entities/word_summary.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../widgets/word_card.dart';
import '../widgets/word_skeleton.dart';

class CariPage extends StatefulWidget {
  const CariPage({super.key});

  @override
  State<CariPage> createState() => _CariPageState();
}

class _CariPageState extends State<CariPage> {
  final _ctrl = TextEditingController();
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    // Recent searches loaded in Phase 8 from local cache
    // For now, show empty list
    if (mounted) setState(() => _recentSearches = []);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          key: const Key('search_field'),
          controller: _ctrl,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Cari kata Banjar atau arti Indonesia...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (q) =>
              context.read<SearchBloc>().add(QueryChanged(q)),
          onSubmitted: (q) =>
              context.read<SearchBloc>().add(QueryChanged(q)),
        ),
        actions: [
          if (_ctrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _ctrl.clear();
                context.read<SearchBloc>().add(const QueryChanged(''));
                setState(() {});
              },
            ),
        ],
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          return switch (state) {
            SearchInitial() || SearchEmpty() => _RecentSearchesView(
                key: const Key('recent_searches'),
                searches: _recentSearches,
                onTap: (q) {
                  _ctrl.text = q;
                  context.read<SearchBloc>().add(QueryChanged(q));
                },
                onClear: () => setState(() => _recentSearches = []),
              ),
            SearchLoading() => ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: 6,
                itemBuilder: (_, _) => const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: WordSkeleton(),
                ),
              ),
            SearchResults(
              query: final q,
              words: final words,
              hasMore: final hasMore,
            ) =>
              _ResultsList(
                key: const Key('search_results'),
                query: q,
                words: words,
                hasMore: hasMore,
                onLoadMore: () =>
                    context.read<SearchBloc>().add(const LoadMoreSearchResults()),
              ),
            SearchError(failure: final f) => Center(child: Text(f.message)),
          };
        },
      ),
    );
  }
}

class _RecentSearchesView extends StatelessWidget {
  final List<String> searches;
  final ValueChanged<String> onTap;
  final VoidCallback onClear;

  const _RecentSearchesView({
    super.key,
    required this.searches,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (searches.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search, size: 64, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              'Ketik untuk mencari kata Banjar',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
          child: Row(
            children: [
              Text(
                'Pencarian Terakhir',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const Spacer(),
              TextButton(onPressed: onClear, child: const Text('Hapus')),
            ],
          ),
        ),
        ...searches.map((q) => ListTile(
              leading: const Icon(Icons.history, size: 18),
              title: Text(q),
              onTap: () => onTap(q),
            )),
      ],
    );
  }
}

class _ResultsList extends StatelessWidget {
  final String query;
  final List<WordSummary> words;
  final bool hasMore;
  final VoidCallback onLoadMore;

  const _ResultsList({
    super.key,
    required this.query,
    required this.words,
    required this.hasMore,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 8),
            Text('Tidak ada hasil untuk "$query"'),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n is ScrollEndNotification &&
            n.metrics.extentAfter < 200 &&
            hasMore) {
          onLoadMore();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: words.length,
        itemBuilder: (context, i) {
          final word = words[i];
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
