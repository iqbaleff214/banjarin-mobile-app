import 'package:banjarin/core/error/failures.dart';
import 'package:banjarin/features/admin/domain/entities/ai_request.dart';
import 'package:banjarin/features/admin/domain/repositories/admin_repository.dart';
import 'package:banjarin/features/admin/domain/usecases/approve_ai_request.dart';
import 'package:banjarin/features/admin/domain/usecases/reject_ai_request.dart';
import 'package:banjarin/features/admin/domain/usecases/run_quality_check.dart';
import 'package:banjarin/features/admin/domain/usecases/trigger_ai_enrich.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminRepository extends Mock implements AdminRepository {}

void main() {
  late MockAdminRepository mockRepo;

  final tRequest = AIRequest(
    id: 'r1',
    type: AIRequestType.enrich_definition,
    model: 'test-model',
    status: AIRequestStatus.pending,
    reviewStatus: AIReviewStatus.unreviewed,
    createdAt: DateTime(2024),
  );

  setUp(() {
    mockRepo = MockAdminRepository();
    registerFallbackValue(const GetAIRequestsParams());
    registerFallbackValue(AIRequestType.enrich_definition);
    registerFallbackValue(AIReviewStatus.unreviewed);
  });

  // -------------------------------------------------------------------------
  // TriggerAIEnrich
  // -------------------------------------------------------------------------
  group('TriggerAIEnrich', () {
    late TriggerAIEnrich trigger;
    setUp(() => trigger = TriggerAIEnrich(mockRepo));

    test('delegates to repository with wordId', () async {
      when(() => mockRepo.triggerEnrich(wordId: any(named: 'wordId')))
          .thenAnswer((_) async => Right(tRequest));

      final result = await trigger(const TriggerAIEnrichParams(wordId: 'w1'));
      expect(result.isRight(), isTrue);
      verify(() => mockRepo.triggerEnrich(wordId: 'w1')).called(1);
    });
  });

  // -------------------------------------------------------------------------
  // RunQualityCheck
  // -------------------------------------------------------------------------
  group('RunQualityCheck', () {
    late RunQualityCheck runCheck;
    setUp(() => runCheck = RunQualityCheck(mockRepo));

    test('delegates to repository with contributionId', () async {
      when(() => mockRepo.runQualityCheck(
            contributionId: any(named: 'contributionId'),
          )).thenAnswer((_) async => Right(tRequest.copyWith(
            reviewStatus: AIReviewStatus.unreviewed,
          )));

      final result = await runCheck(
          const RunQualityCheckParams(contributionId: 'c1'));
      expect(result.isRight(), isTrue);
      verify(() => mockRepo.runQualityCheck(contributionId: 'c1')).called(1);
    });
  });

  // -------------------------------------------------------------------------
  // ApproveAIRequest
  // -------------------------------------------------------------------------
  group('ApproveAIRequest', () {
    late ApproveAIRequest approve;
    setUp(() => approve = ApproveAIRequest(mockRepo));

    test('when type is quality_check returns ConflictFailure', () async {
      final result = await approve(const ApproveAIRequestParams(
        requestId: 'r1',
        type: AIRequestType.quality_check,
        reviewStatus: AIReviewStatus.unreviewed,
      ));
      expect(result.fold((f) => f, (_) => null), isA<ConflictFailure>());
    });

    test('when reviewStatus is approved returns ConflictFailure', () async {
      final result = await approve(const ApproveAIRequestParams(
        requestId: 'r1',
        type: AIRequestType.enrich_definition,
        reviewStatus: AIReviewStatus.approved,
      ));
      expect(result.fold((f) => f, (_) => null), isA<ConflictFailure>());
    });

    test('when reviewStatus is rejected returns ConflictFailure', () async {
      final result = await approve(const ApproveAIRequestParams(
        requestId: 'r1',
        type: AIRequestType.enrich_definition,
        reviewStatus: AIReviewStatus.rejected,
      ));
      expect(result.fold((f) => f, (_) => null), isA<ConflictFailure>());
    });

    test('when valid delegates to repository', () async {
      when(() => mockRepo.approveAIRequest(requestId: any(named: 'requestId')))
          .thenAnswer((_) async => Right(
              tRequest.copyWith(reviewStatus: AIReviewStatus.approved)));

      final result = await approve(const ApproveAIRequestParams(
        requestId: 'r1',
        type: AIRequestType.enrich_definition,
        reviewStatus: AIReviewStatus.unreviewed,
      ));
      expect(result.isRight(), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // RejectAIRequest
  // -------------------------------------------------------------------------
  group('RejectAIRequest', () {
    late RejectAIRequest reject;
    setUp(() => reject = RejectAIRequest(mockRepo));

    test('delegates to repository', () async {
      when(() => mockRepo.rejectAIRequest(requestId: any(named: 'requestId')))
          .thenAnswer((_) async => Right(
              tRequest.copyWith(reviewStatus: AIReviewStatus.rejected)));

      final result = await reject(const RejectAIRequestParams(requestId: 'r1'));
      expect(result.isRight(), isTrue);
    });
  });
}
