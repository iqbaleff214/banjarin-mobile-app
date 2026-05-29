import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static const banjarWord = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const banjarWordMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const syllabified = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
  );

  static const definition = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const example = TextStyle(
    fontSize: 14,
    fontStyle: FontStyle.italic,
    height: 1.5,
  );

  static const badgeLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  static const primaryMeaning = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    overflow: TextOverflow.ellipsis,
  );
}
