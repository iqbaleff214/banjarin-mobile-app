import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/translation_result.dart';
import 'confidence_badge.dart';

class TranslationResultCard extends StatelessWidget {
  final TranslationResult result;

  const TranslationResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Original text
            Text(
              'Teks Asli',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              result.original,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
            const Divider(height: 24),
            // Translation (large)
            Text(
              'Terjemahan',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              result.translation,
              key: const Key('translation_text'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 12),
            // Badges row
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                // Dialect badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Banjar ${result.dialect.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                ConfidenceBadge(confidence: result.confidence),
              ],
            ),
            // Lexical notes
            if (result.notes != null && result.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                result.notes!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
              ),
            ],
            const SizedBox(height: 12),
            // Actions row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Model attribution (very small, muted)
                Expanded(
                  child: Text(
                    result.model,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Copy button
                TextButton.icon(
                  key: const Key('copy_button'),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Salin'),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: result.translation));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Terjemahan disalin'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
