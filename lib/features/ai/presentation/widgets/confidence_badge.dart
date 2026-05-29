import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/confidence_level.dart';

class ConfidenceBadge extends StatelessWidget {
  final ConfidenceLevel confidence;

  const ConfidenceBadge({super.key, required this.confidence});

  Color get _color => switch (confidence) {
        ConfidenceLevel.high => AppColors.confidenceHigh,
        ConfidenceLevel.medium => AppColors.confidenceMedium,
        ConfidenceLevel.low => AppColors.confidenceLow,
      };

  String get _label => switch (confidence) {
        ConfidenceLevel.high => 'Tinggi',
        ConfidenceLevel.medium => 'Sedang',
        ConfidenceLevel.low => 'Rendah',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: _color),
          const SizedBox(width: 4),
          Text(
            _label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}
