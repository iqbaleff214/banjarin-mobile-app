import 'package:banjarin/features/dictionary/data/models/word_model.dart';
import 'package:banjarin/features/dictionary/domain/entities/content_source.dart';
import 'package:banjarin/features/dictionary/domain/entities/word.dart';
import 'package:banjarin/features/dictionary/domain/entities/word_class.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tJson = {
    'id': 'abc-123',
    'banjar': 'abah',
    'banjar_syllabified': 'a.bah',
    'dialect': 'hulu',
    'word_class': 'n',
    'homonym_number': 1,
    'is_root': true,
    'root_word_id': null,
    'definitions': [
      {
        'id': 'def-1',
        'meaning': 'ayah',
        'sort_order': 1,
        'source': 'seeded',
        'upvotes': 5,
        'downvotes': 0,
      }
    ],
    'examples': [],
    'related_words': [],
    'status': 'active',
    'source': 'seeded',
    'source_reference': null,
    'created_by': null,
    'created_at': '2024-01-01T00:00:00.000Z',
    'updated_at': '2024-01-01T00:00:00.000Z',
  };

  group('WordModel.fromJson', () {
    test('parses all fields correctly', () {
      final model = WordModel.fromJson(tJson);

      expect(model.id, 'abc-123');
      expect(model.banjar, 'abah');
      expect(model.banjarSyllabified, 'a.bah');
      expect(model.dialect, 'hulu');
      expect(model.wordClass, WordClass.n);
      expect(model.homonymNumber, 1);
      expect(model.isRoot, isTrue);
      expect(model.definitions.length, 1);
      expect(model.definitions.first.meaning, 'ayah');
      expect(model.definitions.first.upvotes, 5);
      expect(model.status, WordStatus.active);
      expect(model.source, ContentSource.seeded);
    });

    test('handles null banjarSyllabified', () {
      final json = Map<String, dynamic>.from(tJson)
        ..['banjar_syllabified'] = null;
      final model = WordModel.fromJson(json);
      expect(model.banjarSyllabified, isNull);
    });

    test('handles null rootWordId', () {
      final model = WordModel.fromJson(tJson);
      expect(model.rootWordId, isNull);
    });

    test('handles empty definitions list', () {
      final json = Map<String, dynamic>.from(tJson)..['definitions'] = [];
      final model = WordModel.fromJson(json);
      expect(model.definitions, isEmpty);
    });

    test('toEntity converts to Word correctly', () {
      final model = WordModel.fromJson(tJson);
      final entity = model.toEntity();

      expect(entity, isA<Word>());
      expect(entity.banjar, 'abah');
      expect(entity.banjarSyllabified, 'a.bah');
      expect(entity.definitions.first.upvotes, 5);
    });
  });
}
