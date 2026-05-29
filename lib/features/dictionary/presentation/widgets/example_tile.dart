import 'package:flutter/material.dart';

import '../../domain/entities/example.dart';
import 'source_badge.dart';

class ExampleTile extends StatelessWidget {
  final Example example;

  const ExampleTile({super.key, required this.example});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            example.banjarSentence,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            example.indonesianTranslation,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          SourceBadge(source: example.source),
        ],
      ),
    );
  }
}
