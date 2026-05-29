import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/content_source.dart';

class SourceBadge extends StatelessWidget {
  final ContentSource source;

  const SourceBadge({super.key, required this.source});

  @override
  Widget build(BuildContext context) {
    return switch (source) {
      ContentSource.ai_generated => _Badge(
          label: 'AI',
          color: AppColors.ai,
          background: AppColors.aiBackground,
        ),
      ContentSource.contributed => _Badge(
          label: 'Komunitas',
          color: AppColors.community,
          background: AppColors.communityBackground,
        ),
      ContentSource.seeded => const SizedBox.shrink(),
    };
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const _Badge({
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
