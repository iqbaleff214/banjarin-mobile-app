import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../dictionary/presentation/widgets/word_card.dart';
import '../../../dictionary/presentation/widgets/word_skeleton.dart';
import '../bloc/bookmark_bloc.dart';
import '../bloc/bookmark_event.dart';
import '../bloc/bookmark_state.dart';

class SimpananPage extends StatefulWidget {
  const SimpananPage({super.key});

  @override
  State<SimpananPage> createState() => _SimpananPageState();
}

class _SimpananPageState extends State<SimpananPage> {
  @override
  void initState() {
    super.initState();
    context.read<BookmarkBloc>().add(const LoadBookmarks());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simpanan')),
      body: BlocBuilder<BookmarkBloc, BookmarkState>(
        builder: (context, state) {
          return switch (state) {
            BookmarkLoading() => ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: 6,
                itemBuilder: (_, _) => const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: WordSkeleton(),
                ),
              ),
            BookmarkError(failure: final f) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(f.message),
                    TextButton(
                      onPressed: () =>
                          context.read<BookmarkBloc>().add(const LoadBookmarks()),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            BookmarkLoaded(bookmarks: final bookmarks, hasMore: final hasMore) ||
            Bookmarked(bookmarks: final bookmarks, hasMore: final hasMore) ||
            Unbookmarked(bookmarks: final bookmarks, hasMore: final hasMore) =>
              bookmarks.isEmpty
                  ? _EmptyState()
                  : NotificationListener<ScrollNotification>(
                      onNotification: (n) {
                        if (n is ScrollEndNotification &&
                            n.metrics.extentAfter < 200 &&
                            hasMore) {
                          context
                              .read<BookmarkBloc>()
                              .add(const LoadMoreBookmarks());
                        }
                        return false;
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: bookmarks.length,
                        itemBuilder: (context, i) {
                          final bookmark = bookmarks[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Dismissible(
                              key: Key('bookmark_${bookmark.id}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 16),
                                color: Theme.of(context).colorScheme.error,
                                child: const Icon(
                                  Icons.bookmark_remove,
                                  color: Colors.white,
                                ),
                              ),
                              onDismissed: (_) {
                                context.read<BookmarkBloc>().add(
                                      ToggleBookmark(
                                        wordId: bookmark.wordId,
                                        isCurrentlyBookmarked: true,
                                      ),
                                    );
                              },
                              child: WordCard(
                                word: bookmark.word,
                                onTap: () => context.push(
                                  Routes.wordDetailPath(bookmark.wordId),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bookmark_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            'Belum ada simpanan',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Simpan kata favoritmu dari halaman detail.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
