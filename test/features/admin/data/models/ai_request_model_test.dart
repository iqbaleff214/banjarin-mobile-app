import 'package:banjarin/features/admin/data/models/ai_request_model.dart';
import 'package:banjarin/features/admin/domain/entities/ai_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AIRequestModel.fromJson', () {
    test('handles null parsedOutput', () {
      final json = {
        'id': 'r1',
        'type': 'enrich_definition',
        'target_word_id': 'w1',
        'target_contribution_id': null,
        'requested_by': 'admin1',
        'model': 'test-model',
        'prompt': null,
        'response': null,
        'parsed_output': null,
        'status': 'pending',
        'review_status': 'unreviewed',
        'reviewed_by': null,
        'reviewed_at': null,
        'created_at': '2024-01-01T00:00:00.000Z',
      };
      final model = AIRequestModel.fromJson(json);
      expect(model.parsedOutput, isNull);
      expect(model.id, 'r1');
      expect(model.type, AIRequestType.enrich_definition);
      expect(model.status, AIRequestStatus.pending);
      expect(model.reviewStatus, AIReviewStatus.unreviewed);
    });

    test('parses parsedOutput when present', () {
      final json = {
        'id': 'r2',
        'type': 'enrich_definition',
        'model': 'test',
        'status': 'completed',
        'review_status': 'unreviewed',
        'parsed_output': {
          'definitions': [
            {'meaning': 'ayah'}
          ]
        },
        'created_at': '2024-01-01T00:00:00.000Z',
      };
      final model = AIRequestModel.fromJson(json);
      expect(model.parsedOutput, isNotNull);
      expect(model.parsedOutput!['definitions'], isNotEmpty);
    });

    test('toEntity returns AIRequest', () {
      final json = {
        'id': 'r1',
        'type': 'suggest_example',
        'model': 'test',
        'status': 'completed',
        'review_status': 'approved',
        'parsed_output': null,
        'created_at': '2024-01-01T00:00:00.000Z',
      };
      final entity = AIRequestModel.fromJson(json).toEntity();
      expect(entity, isA<AIRequest>());
      expect(entity.type, AIRequestType.suggest_example);
      expect(entity.reviewStatus, AIReviewStatus.approved);
    });
  });
}
