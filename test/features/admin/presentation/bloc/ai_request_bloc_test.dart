import 'package:banjarin/core/error/failures.dart';
import 'package:banjarin/core/usecase/paginated_result.dart';
import 'package:banjarin/features/admin/domain/entities/ai_request.dart';
import 'package:banjarin/features/admin/domain/repositories/admin_repository.dart';
import 'package:banjarin/features/admin/domain/usecases/approve_ai_request.dart';
import 'package:banjarin/features/admin/domain/usecases/get_ai_request_detail.dart';
import 'package:banjarin/features/admin/domain/usecases/get_ai_requests.dart';
import 'package:banjarin/features/admin/domain/usecases/reject_ai_request.dart';
import 'package:banjarin/features/admin/domain/usecases/run_quality_check.dart';
import 'package:banjarin/features/admin/domain/usecases/trigger_ai_enrich.dart';
import 'package:banjarin/features/admin/domain/usecases/trigger_ai_example.dart';
import 'package:banjarin/features/admin/domain/usecases/trigger_ai_related.dart';
import 'package:banjarin/features/admin/presentation/bloc/ai_request_bloc.dart';
import 'package:banjarin/features/admin/presentation/bloc/ai_request_event.dart';
import 'package:banjarin/features/admin/presentation/bloc/ai_request_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockTriggerAIEnrich extends Mock implements TriggerAIEnrich {}
class MockTriggerAIExample extends Mock implements TriggerAIExample {}
class MockTriggerAIRelated extends Mock implements TriggerAIRelated {}
class MockRunQualityCheck extends Mock implements RunQualityCheck {}
class MockGetAIRequests extends Mock implements GetAIRequests {}
class MockGetAIRequestDetail extends Mock implements GetAIRequestDetail {}
class MockApproveAIRequest extends Mock implements ApproveAIRequest {}
class MockRejectAIRequest extends Mock implements RejectAIRequest {}

void main() {
  late MockTriggerAIEnrich mockEnrich;
  late MockTriggerAIExample mockExample;
  late MockTriggerAIRelated mockRelated;
  late MockRunQualityCheck mockCheck;
  late MockGetAIRequests mockGet;
  late MockApproveAIRequest mockApprove;
  late MockRejectAIRequest mockReject;

  final tRequest = AIRequest(
    id: 'r1',
    type: AIRequestType.enrich_definition,
    model: 'test',
    status: AIRequestStatus.pending,
    reviewStatus: AIReviewStatus.unreviewed,
    createdAt: DateTime(2024),
  );

  setUp(() {
    mockEnrich = MockTriggerAIEnrich();
    mockExample = MockTriggerAIExample();
    mockRelated = MockTriggerAIRelated();
    mockCheck = MockRunQualityCheck();
    mockGet = MockGetAIRequests();
    mockApprove = MockApproveAIRequest();
    mockReject = MockRejectAIRequest();

    registerFallbackValue(const TriggerAIEnrichParams(wordId: ''));
    registerFallbackValue(const TriggerAIExampleParams(wordId: ''));
    registerFallbackValue(const TriggerAIRelatedParams(wordId: ''));
    registerFallbackValue(const RunQualityCheckParams(contributionId: ''));
    registerFallbackValue(const GetAIRequestsParams());
    registerFallbackValue(const ApproveAIRequestParams(
      requestId: '', type: AIRequestType.enrich_definition,
      reviewStatus: AIReviewStatus.unreviewed,
    ));
    registerFallbackValue(const RejectAIRequestParams(requestId: ''));
  });

  AIRequestBloc makeBloc() => AIRequestBloc(
        triggerEnrich: mockEnrich,
        triggerExample: mockExample,
        triggerRelated: mockRelated,
        runCheck: mockCheck,
        getRequests: mockGet,
        approve: mockApprove,
        reject: mockReject,
      );

  group('AIRequestBloc', () {
    blocTest<AIRequestBloc, AIRequestState>(
      'TriggerEnrich emits [Triggering, Triggered] with pending AIRequest',
      build: () {
        when(() => mockEnrich(any())).thenAnswer((_) async => Right(tRequest));
        return makeBloc();
      },
      act: (bloc) => bloc.add(const TriggerAIEvent(
        type: AIRequestType.enrich_definition,
        wordId: 'w1',
      )),
      expect: () => [isA<Triggering>(), isA<Triggered>()],
      verify: (bloc) {
        expect((bloc.state as Triggered).aiRequest.status, AIRequestStatus.pending);
      },
    );

    blocTest<AIRequestBloc, AIRequestState>(
      'TriggerEnrich on RateLimitedFailure emits AIRequestError',
      build: () {
        when(() => mockEnrich(any())).thenAnswer(
          (_) async => const Left(RateLimitedFailure(retryAfterSeconds: 3600)),
        );
        return makeBloc();
      },
      act: (bloc) => bloc.add(const TriggerAIEvent(
        type: AIRequestType.enrich_definition,
        wordId: 'w1',
      )),
      expect: () => [isA<Triggering>(), isA<AIRequestError>()],
      verify: (bloc) {
        expect(
          (bloc.state as AIRequestError).failure,
          isA<RateLimitedFailure>(),
        );
      },
    );

    blocTest<AIRequestBloc, AIRequestState>(
      'LoadRequests emits [Loading, Loaded]',
      build: () {
        when(() => mockGet(any())).thenAnswer((_) async => Right(PaginatedResult(
          items: [tRequest], page: 1, perPage: 20, total: 1,
        )));
        return makeBloc();
      },
      act: (bloc) => bloc.add(const LoadAIRequests()),
      expect: () => [isA<AIRequestLoading>(), isA<AIRequestLoaded>()],
      verify: (bloc) {
        expect((bloc.state as AIRequestLoaded).requests.first.id, 'r1');
      },
    );

    blocTest<AIRequestBloc, AIRequestState>(
      'ApproveRequest emits [Reviewing, Reviewed] and updates list',
      build: () {
        when(() => mockApprove(any())).thenAnswer((_) async =>
            Right(tRequest.copyWith(reviewStatus: AIReviewStatus.approved)));
        return makeBloc();
      },
      seed: () => AIRequestLoaded(requests: [tRequest], hasMore: false, currentPage: 1),
      act: (bloc) => bloc.add(const ApproveAIRequestEvent(
        requestId: 'r1',
        type: AIRequestType.enrich_definition,
        reviewStatus: AIReviewStatus.unreviewed,
      )),
      expect: () => [isA<Reviewing>(), isA<Reviewed>()],
      verify: (bloc) {
        final reviewed = bloc.state as Reviewed;
        expect(reviewed.reviewedId, 'r1');
        expect(reviewed.requests.first.reviewStatus, AIReviewStatus.approved);
      },
    );

    blocTest<AIRequestBloc, AIRequestState>(
      'ApproveRequest on ConflictFailure emits AIRequestError',
      build: () {
        when(() => mockApprove(any()))
            .thenAnswer((_) async => const Left(ConflictFailure()));
        return makeBloc();
      },
      seed: () => AIRequestLoaded(requests: [tRequest], hasMore: false, currentPage: 1),
      act: (bloc) => bloc.add(const ApproveAIRequestEvent(
        requestId: 'r1',
        type: AIRequestType.quality_check, // will cause ConflictFailure in use case
        reviewStatus: AIReviewStatus.unreviewed,
      )),
      expect: () => [isA<Reviewing>(), isA<AIRequestError>()],
    );

    blocTest<AIRequestBloc, AIRequestState>(
      'RejectRequest emits [Reviewing, Reviewed]',
      build: () {
        when(() => mockReject(any())).thenAnswer((_) async =>
            Right(tRequest.copyWith(reviewStatus: AIReviewStatus.rejected)));
        return makeBloc();
      },
      seed: () => AIRequestLoaded(requests: [tRequest], hasMore: false, currentPage: 1),
      act: (bloc) => bloc.add(const RejectAIRequestEvent('r1')),
      expect: () => [isA<Reviewing>(), isA<Reviewed>()],
    );
  });
}
