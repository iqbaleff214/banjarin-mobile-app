import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/word_summary.dart';

class RelatedWordChip extends StatelessWidget {
  final WordSummary word;
  final VoidCallback? onTap;

  const RelatedWordChip({super.key, required this.word, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(
        word.banjar,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
      onPressed: onTap,
      backgroundColor: AppColors.primary.withValues(alpha: 0.08),
      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
