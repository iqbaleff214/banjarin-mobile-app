import 'package:banjarin/features/dictionary/domain/entities/content_source.dart';
import 'package:banjarin/features/dictionary/domain/entities/word.dart';
import 'package:banjarin/features/dictionary/domain/entities/word_class.dart';
import 'package:banjarin/features/dictionary/domain/entities/word_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WordClass', () {
    test('n label returns Nomina', () {
      expect(WordClass.n.label, 'Nomina');
    });

    test('v label returns Verba', () {
      expect(WordClass.v.label, 'Verba');
    });

    test('a label returns Adjektiva', () {
      expect(WordClass.a.label, 'Adjektiva');
    });

    test('adv label returns Adverbia', () {
      expect(WordClass.adv.label, 'Adverbia');
    });

    test('p label returns Partikel', () {
      expect(WordClass.p.label, 'Partikel');
    });

    test('pb label returns Pribahasa', () {
      expect(WordClass.pb.label, 'Pribahasa');
    });

    test('ki label returns Kiasan', () {
      expect(WordClass.ki.label, 'Kiasan');
    });

    test('fromString parses valid value', () {
      expect(WordClass.fromString('v'), WordClass.v);
    });

    test('fromString defaults to n for unknown value', () {
      expect(WordClass.fromString('unknown'), WordClass.n);
    });
  });

  group('ContentSource', () {
    test('isAiGenerated returns true only for ai_generated', () {
      expect(ContentSource.ai_generated.isAiGenerated, isTrue);
      expect(ContentSource.contributed.isAiGenerated, isFalse);
      expect(ContentSource.seeded.isAiGenerated, isFalse);
    });

    test('isContributed returns true only for contributed', () {
      expect(ContentSource.contributed.isContributed, isTrue);
      expect(ContentSource.ai_generated.isContributed, isFalse);
      expect(ContentSource.seeded.isContributed, isFalse);
    });

    test('isSeeded returns true only for seeded', () {
      expect(ContentSource.seeded.isSeeded, isTrue);
    });

    test('fromString parses ai_generated', () {
      expect(ContentSource.fromString('ai_generated'), ContentSource.ai_generated);
    });

    test('fromString defaults to seeded for unknown value', () {
      expect(ContentSource.fromString('unknown'), ContentSource.seeded);
    });
  });

  group('WordSummary', () {
    WordSummary makeWord({int homonymNumber = 1}) => WordSummary(
          id: '1',
          banjar: 'abah',
          dialect: 'hulu',
          wordClass: WordClass.n,
          homonymNumber: homonymNumber,
          isRoot: true,
          primaryMeaning: 'ayah',
          source: ContentSource.seeded,
          createdAt: DateTime(2024),
        );

    test('isHomonym returns false when homonymNumber is 1', () {
      expect(makeWord().isHomonym, isFalse);
    });

    test('isHomonym returns true when homonymNumber is greater than 1', () {
      expect(makeWord(homonymNumber: 2).isHomonym, isTrue);
    });
  });

  group('Word', () {
    Word makeWord({int homonymNumber = 1}) => Word(
          id: '1',
          banjar: 'abah',
          dialect: 'hulu',
          wordClass: WordClass.n,
          homonymNumber: homonymNumber,
          isRoot: true,
          definitions: [],
          examples: [],
          relatedWordIds: [],
          status: WordStatus.active,
          source: ContentSource.seeded,
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        );

    test('isHomonym returns true when homonymNumber is greater than 1', () {
      expect(makeWord(homonymNumber: 2).isHomonym, isTrue);
    });

    test('isActive returns true when status is active', () {
      expect(makeWord().isActive, isTrue);
    });
  });
}
