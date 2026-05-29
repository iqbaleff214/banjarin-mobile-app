import 'package:flutter/material.dart';

import 'shimmer_box.dart';

/// Skeleton for a word list card
class WordCardSkeleton extends StatelessWidget {
  const WordCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(width: 120, height: 18),
            const SizedBox(height: 6),
            ShimmerBox(width: double.infinity, height: 14),
            const SizedBox(height: 8),
            Row(
              children: [
                ShimmerBox(width: 40, height: 20),
                const SizedBox(width: 6),
                ShimmerBox(width: 60, height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for word list (N items)
class WordListSkeleton extends StatelessWidget {
  final int itemCount;
  const WordListSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: itemCount,
      itemBuilder: (_, _) => const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: WordCardSkeleton(),
      ),
    );
  }
}

/// Skeleton for word detail header
class WordDetailSkeleton extends StatelessWidget {
  const WordDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 200, height: 28),
          const SizedBox(height: 8),
          ShimmerBox(width: 100, height: 16),
          const SizedBox(height: 12),
          ShimmerBox(width: double.infinity, height: 14),
          const SizedBox(height: 6),
          ShimmerBox(width: double.infinity, height: 14),
          const SizedBox(height: 6),
          ShimmerBox(width: 180, height: 14),
        ],
      ),
    );
  }
}

/// Skeleton for bookmark list
class BookmarkListSkeleton extends StatelessWidget {
  const BookmarkListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const WordListSkeleton(itemCount: 5);
  }
}

/// Skeleton for contribution list
class ContributionListSkeleton extends StatelessWidget {
  const ContributionListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 5,
      itemBuilder: (_, _) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ShimmerBox(width: 70, height: 20),
                    const SizedBox(width: 6),
                    ShimmerBox(width: 70, height: 20),
                  ],
                ),
                const SizedBox(height: 8),
                ShimmerBox(width: 150, height: 14),
                const SizedBox(height: 4),
                ShimmerBox(width: 100, height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Skeleton for admin moderation queue
class AdminQueueSkeleton extends StatelessWidget {
  const AdminQueueSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 5,
      itemBuilder: (_, _) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Card(
          child: ListTile(
            title: ShimmerBox(width: 140, height: 16),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                ShimmerBox(width: 200, height: 12),
                const SizedBox(height: 4),
                ShimmerBox(width: 120, height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
