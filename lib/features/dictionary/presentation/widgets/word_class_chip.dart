import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/word_class.dart';

class WordClassChip extends StatelessWidget {
  final WordClass wordClass;

  const WordClassChip({super.key, required this.wordClass});

  Color get _color => switch (wordClass) {
        WordClass.n => AppColors.wcNomina,
        WordClass.v => AppColors.wcVerba,
        WordClass.a => AppColors.wcAdjektiva,
        WordClass.adv => AppColors.wcAdverbia,
        WordClass.p => AppColors.wcPartikel,
        WordClass.pb => AppColors.wcPribahasa,
        WordClass.ki => AppColors.wcKiasan,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Text(
        wordClass.name,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
