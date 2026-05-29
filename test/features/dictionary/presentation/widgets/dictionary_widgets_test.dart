import 'package:banjarin/core/theme/app_colors.dart';
import 'package:banjarin/core/theme/app_theme.dart';
import 'package:banjarin/features/dictionary/domain/entities/content_source.dart';
import 'package:banjarin/features/dictionary/domain/entities/word_class.dart';
import 'package:banjarin/features/dictionary/domain/entities/word_summary.dart';
import 'package:banjarin/features/dictionary/presentation/widgets/source_badge.dart';
import 'package:banjarin/features/dictionary/presentation/widgets/word_card.dart';
import 'package:banjarin/features/dictionary/presentation/widgets/word_class_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    );

WordSummary makeWord({
  WordClass wordClass = WordClass.n,
  ContentSource source = ContentSource.seeded,
  int homonymNumber = 1,
  String banjar = 'abah',
}) =>
    WordSummary(
      id: '1',
      banjar: banjar,
      dialect: 'hulu',
      wordClass: wordClass,
      homonymNumber: homonymNumber,
      isRoot: true,
      primaryMeaning: 'ayah',
      source: source,
      createdAt: DateTime(2024),
    );

void main() {
  // -------------------------------------------------------------------------
  // WordClassChip
  // -------------------------------------------------------------------------
  group('WordClassChip', () {
    testWidgets('renders n with slate color', (tester) async {
      await tester.pumpWidget(wrap(const WordClassChip(wordClass: WordClass.n)));
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border?.top.color.withValues(alpha: 1),
          AppColors.wcNomina.withValues(alpha: 1));
    });

    testWidgets('renders ki with teal color', (tester) async {
      await tester.pumpWidget(wrap(const WordClassChip(wordClass: WordClass.ki)));
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border?.top.color.withValues(alpha: 1),
          AppColors.wcKiasan.withValues(alpha: 1));
    });

    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(wrap(const WordClassChip(wordClass: WordClass.pb)));
      expect(find.text('pb'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // SourceBadge
  // -------------------------------------------------------------------------
  group('SourceBadge', () {
    testWidgets('renders AI chip for ai_generated source', (tester) async {
      await tester.pumpWidget(
        wrap(const SourceBadge(source: ContentSource.ai_generated)),
      );
      expect(find.text('AI'), findsOneWidget);
    });

    testWidgets('renders Komunitas chip for contributed source', (tester) async {
      await tester.pumpWidget(
        wrap(const SourceBadge(source: ContentSource.contributed)),
      );
      expect(find.text('Komunitas'), findsOneWidget);
    });

    testWidgets('renders nothing for seeded source', (tester) async {
      await tester.pumpWidget(
        wrap(const SourceBadge(source: ContentSource.seeded)),
      );
      expect(find.byType(SizedBox), findsWidgets);
      expect(find.text('AI'), findsNothing);
      expect(find.text('Komunitas'), findsNothing);
    });
  });

  // -------------------------------------------------------------------------
  // WordCard
  // -------------------------------------------------------------------------
  group('WordCard', () {
    testWidgets('shows homonym superscript when homonymNumber is 2',
        (tester) async {
      await tester.pumpWidget(
        wrap(WordCard(word: makeWord(homonymNumber: 2))),
      );
      // RichText with superscript '2'
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('does not show superscript when homonymNumber is 1',
        (tester) async {
      await tester.pumpWidget(
        wrap(WordCard(word: makeWord())),
      );
      expect(find.text('1'), findsNothing);
    });

    testWidgets('shows primary meaning', (tester) async {
      await tester.pumpWidget(wrap(WordCard(word: makeWord())));
      expect(find.text('ayah'), findsOneWidget);
    });

    testWidgets('shows source badge for ai_generated', (tester) async {
      await tester.pumpWidget(
        wrap(WordCard(word: makeWord(source: ContentSource.ai_generated))),
      );
      expect(find.text('AI'), findsOneWidget);
    });
  });
}
