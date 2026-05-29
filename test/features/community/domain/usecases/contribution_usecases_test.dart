import 'package:banjarin/core/error/failures.dart';
import 'package:banjarin/core/usecase/paginated_result.dart';
import 'package:banjarin/features/community/domain/entities/contribution.dart';
import 'package:banjarin/features/community/domain/repositories/contribution_repository.dart';
import 'package:banjarin/features/community/domain/usecases/get_contributions.dart';
import 'package:banjarin/features/community/domain/usecases/submit_contribution.dart';
import 'package:banjarin/features/community/domain/usecases/withdraw_contribution.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockContributionRepository extends Mock
    implements ContributionRepository {}

void main() {
  late MockContributionRepository mockRepo;

  final tContribution = Contribution(
    id: 'c1',
    type: ContributionType.new_word,
    contributorId: 'u1',
    payload: const {'banjar': 'abah', 'word_class': 'n', 'definitions': [{'meaning': 'ayah'}]},
    status: ContributionStatus.pending,
    submittedAt: DateTime(2024),
  );

  setUp(() {
    mockRepo = MockContributionRepository();
    registerFallbackValue(ContributionType.new_word);
    registerFallbackValue(ContributionStatus.pending);
    registerFallbackValue(<String, dynamic>{});
  });

  // -------------------------------------------------------------------------
  // SubmitContribution
  // -------------------------------------------------------------------------
  group('SubmitContribution', () {
    late SubmitContribution submit;
    setUp(() => submit = SubmitContribution(mockRepo));

    test('new_definition without targetWordId returns ValidationFailure', () async {
      final result = await submit(const SubmitContributionParams(
        type: ContributionType.new_definition,
        targetWordId: null,
        payload: {'meaning': 'ayah'},
      ));
      expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
    });

    test('new_word without definitions returns ValidationFailure', () async {
      final result = await submit(const SubmitContributionParams(
        type: ContributionType.new_word,
        payload: {'banjar': 'abah', 'word_class': 'n', 'definitions': []},
      ));
      expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
    });

    test('new_definition meaning exceeds 2000 chars returns ValidationFailure',
        () async {
      final result = await submit(SubmitContributionParams(
        type: ContributionType.new_definition,
        targetWordId: 'w1',
        payload: {'meaning': 'x' * 2001},
      ));
      expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
    });

    test('new_word without banjar returns ValidationFailure', () async {
      final result = await submit(const SubmitContributionParams(
        type: ContributionType.new_word,
        payload: {'banjar': '', 'word_class': 'n', 'definitions': [{'meaning': 'a'}]},
      ));
      expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
    });

    test('valid new_word delegates to repository', () async {
      when(() => mockRepo.submit(
            type: any(named: 'type'),
            targetWordId: any(named: 'targetWordId'),
            payload: any(named: 'payload'),
          )).thenAnswer((_) async => Right(tContribution));

      final result = await submit(const SubmitContributionParams(
        type: ContributionType.new_word,
        payload: {
          'banjar': 'abah',
          'word_class': 'n',
          'definitions': [{'meaning': 'ayah'}],
        },
      ));
      expect(result.isRight(), isTrue);
    });

    test('new_example without banjarSentence returns ValidationFailure', () async {
      final result = await submit(const SubmitContributionParams(
        type: ContributionType.new_example,
        targetWordId: 'w1',
        payload: {'banjar_sentence': '', 'indonesian_translation': 'something'},
      ));
      expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
    });
  });

  // -------------------------------------------------------------------------
  // WithdrawContribution
  // -------------------------------------------------------------------------
  group('WithdrawContribution', () {
    late WithdrawContribution withdraw;
    setUp(() => withdraw = WithdrawContribution(mockRepo));

    test('when status is approved returns ConflictFailure', () async {
      final result = await withdraw(const WithdrawContributionParams(
        contributionId: 'c1',
        currentStatus: ContributionStatus.approved,
      ));
      expect(result.fold((f) => f, (_) => null), isA<ConflictFailure>());
    });

    test('when status is rejected returns ConflictFailure', () async {
      final result = await withdraw(const WithdrawContributionParams(
        contributionId: 'c1',
        currentStatus: ContributionStatus.rejected,
      ));
      expect(result.fold((f) => f, (_) => null), isA<ConflictFailure>());
    });

    test('when status is pending delegates to repository', () async {
      when(() => mockRepo.withdraw(contributionId: any(named: 'contributionId')))
          .thenAnswer((_) async => Right(tContribution.copyWith(
                status: ContributionStatus.withdrawn,
              )));

      final result = await withdraw(const WithdrawContributionParams(
        contributionId: 'c1',
        currentStatus: ContributionStatus.pending,
      ));
      expect(result.isRight(), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // GetContributions
  // -------------------------------------------------------------------------
  group('GetContributions', () {
    late GetContributions getContributions;
    setUp(() => getContributions = GetContributions(mockRepo));

    test('delegates to repository with status filter', () async {
      when(() => mockRepo.getContributions(
            status: any(named: 'status'),
            type: any(named: 'type'),
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          )).thenAnswer((_) async => Right(PaginatedResult(
            items: [tContribution],
            page: 1,
            perPage: 20,
            total: 1,
          )));

      final result = await getContributions(
        const GetContributionsParams(status: ContributionStatus.pending),
      );
      expect(result.isRight(), isTrue);
      verify(() => mockRepo.getContributions(
            status: ContributionStatus.pending,
            type: null,
            page: 1,
            perPage: 20,
          )).called(1);
    });
  });
}
