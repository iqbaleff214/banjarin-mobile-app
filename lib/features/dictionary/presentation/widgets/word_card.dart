import 'package:flutter/material.dart';

import '../../domain/entities/word_summary.dart';
import 'source_badge.dart';
import 'word_class_chip.dart';

class WordCard extends StatelessWidget {
  final WordSummary word;
  final VoidCallback? onTap;

  const WordCard({super.key, required this.word, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WordTitle(word: word),
                    const SizedBox(height: 4),
                    Text(
                      word.primaryMeaning,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        WordClassChip(wordClass: word.wordClass),
                        SourceBadge(source: word.source),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _WordTitle extends StatelessWidget {
  final WordSummary word;

  const _WordTitle({required this.word});

  @override
  Widget build(BuildContext context) {
    final title = word.banjar;
    final baseStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        );

    if (!word.isHomonym) {
      return Text(title, style: baseStyle);
    }

    return RichText(
      text: TextSpan(
        text: title,
        style: baseStyle,
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.top,
            child: Text(
              '${word.homonymNumber}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
