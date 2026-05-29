import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand primary — deep teal
  static const primary = Color(0xFF0D7377);
  static const primaryLight = Color(0xFF14BDBD);
  static const primaryDark = Color(0xFF095255);

  // AI-generated content — amber
  static const ai = Color(0xFFF2994A);
  static const aiBackground = Color(0x1FF2994A); // amber at ~12%

  // Community-contributed content — blue
  static const community = Color(0xFF2F80ED);
  static const communityBackground = Color(0x1F2F80ED); // blue at ~12%

  // Semantic
  static const success = Color(0xFF27AE60);
  static const error = Color(0xFFEB5757);
  static const warning = Color(0xFFF2C94C);

  // Word class badge colors
  static const wcNomina = Color(0xFF64748B);    // slate  — n
  static const wcVerba = Color(0xFF2563EB);     // blue   — v
  static const wcAdjektiva = Color(0xFF16A34A); // green  — a
  static const wcAdverbia = Color(0xFF9333EA);  // purple — adv
  static const wcPartikel = Color(0xFFEA580C);  // orange — p
  static const wcPribahasa = Color(0xFFDC2626); // red    — pb
  static const wcKiasan = Color(0xFF0D7377);    // teal   — ki

  // Confidence badge colors
  static const confidenceHigh = Color(0xFF27AE60);
  static const confidenceMedium = Color(0xFFF2C94C);
  static const confidenceLow = Color(0xFFEB5757);

  // Backgrounds
  static const backgroundLight = Color(0xFFFAFAFA);
  static const backgroundDark = Color(0xFF121212);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF1E1E1E);
  static const cardDark = Color(0xFF2A2A2A);

  // Semi-transparent overlays (pre-computed to avoid withOpacity deprecation)
  static const primaryIndicatorLight =
      Color(0x1F0D7377); // primary at ~12%
  static const primaryIndicatorDark =
      Color(0x2614BDBD); // primaryLight at ~15%
  static const inputFillLight = Color(0x0A000000); // black at ~4%
  static const inputFillDark = Color(0x0FFFFFFF);  // white at ~6%
  static const cardBorderLight = Color(0x14000000); // black at ~8%
  static const cardBorderDark = Color(0x1AFFFFFF);  // white at ~10%
}
