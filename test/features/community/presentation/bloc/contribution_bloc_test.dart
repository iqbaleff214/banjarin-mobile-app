import 'package:banjarin/core/error/failures.dart';
import 'package:banjarin/core/usecase/paginated_result.dart';
import 'package:banjarin/features/community/domain/entities/contribution.dart';
import 'package:banjarin/features/community/domain/usecases/get_contributions.dart';
import 'package:banjarin/features/community/domain/usecases/submit_contribution.dart';
import 'package:banjarin/features/community/domain/usecases/withdraw_contribution.dart';
import 'package:banjarin/features/community/presentation/bloc/contribution_bloc.dart';
import 'package:banjarin/features/community/presentation/bloc/contribution_event.dart';
import 'package:banjarin/features/community/presentation/bloc/contribution_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockSubmitContribution extends Mock implements SubmitContribution {}
class MockGetContributions extends Mock implements GetContributions {}
class MockWithdrawContribution extends Mock implements WithdrawContribution {}

void main() {
  late MockSubmitContribution mockSubmit;
  late MockGetContributions mockGet;
  late MockWithdrawContribution mockWithdraw;

  final tContribution = Contribution(
    id: 'c1',
    type: ContributionType.new_word,
    contributorId: 'u1',
    payload: const {'banjar': 'abah', 'word_class': 'n', 'definitions': [{'meaning': 'ayah'}]},
    status: ContributionStatus.pending,
    submittedAt: DateTime(2024),
  );

  setUp(() {
    mockSubmit = MockSubmitContribution();
    mockGet = MockGetContributions();
    mockWithdraw = MockWithdrawContribution();

    registerFallbackValue(const SubmitContributionParams(
      type: ContributionType.new_word,
      payload: {},
    ));
    registerFallbackValue(const GetContributionsParams());
    registerFallbackValue(const WithdrawContributionParams(
      contributionId: '',
      currentStatus: ContributionStatus.pending,
    ));
  });

  ContributionBloc makeBloc() => ContributionBloc(
        submit: mockSubmit,
        getContributions: mockGet,
        withdraw: mockWithdraw,
      );

  group('ContributionBloc', () {
    blocTest<ContributionBloc, ContributionState>(
      'SubmitContribution emits [Submitting, Submitted]',
      build: () {
        when(() => mockSubmit(any()))
            .thenAnswer((_) async => Right(tContribution));
        return makeBloc();
      },
      act: (bloc) => bloc.add(const SubmitContributionEvent(
        type: ContributionType.new_word,
        payload: {'banjar': 'abah', 'word_class': 'n', 'definitions': [{'meaning': 'ayah'}]},
      )),
      expect: () => [isA<ContributionSubmitting>(), isA<ContributionSubmitted>()],
      verify: (bloc) {
        expect((bloc.state as ContributionSubmitted).contribution.id, 'c1');
      },
    );

    blocTest<ContributionBloc, ContributionState>(
      'SubmitContribution on RateLimitedFailure emits ContributionError',
      build: () {
        when(() => mockSubmit(any())).thenAnswer(
          (_) async => const Left(RateLimitedFailure(retryAfterSeconds: 60)),
        );
        return makeBloc();
      },
      act: (bloc) => bloc.add(const SubmitContributionEvent(
        type: ContributionType.new_word,
        payload: {},
      )),
      expect: () => [isA<ContributionSubmitting>(), isA<ContributionError>()],
      verify: (bloc) {
        expect(
          (bloc.state as ContributionError).failure,
          isA<RateLimitedFailure>(),
        );
      },
    );

    blocTest<ContributionBloc, ContributionState>(
      'LoadContributions emits [Loading, Loaded]',
      build: () {
        when(() => mockGet(any())).thenAnswer((_) async => Right(PaginatedResult(
          items: [tContribution], page: 1, perPage: 20, total: 1,
        )));
        return makeBloc();
      },
      act: (bloc) => bloc.add(const LoadContributions()),
      expect: () => [isA<ContributionLoading>(), isA<ContributionLoaded>()],
      verify: (bloc) {
        expect((bloc.state as ContributionLoaded).contributions.length, 1);
      },
    );

    blocTest<ContributionBloc, ContributionState>(
      'WithdrawContribution emits [Withdrawing, Withdrawn] and removes from list',
      build: () {
        when(() => mockWithdraw(any())).thenAnswer((_) async => Right(
              tContribution.copyWith(status: ContributionStatus.withdrawn),
            ));
        return makeBloc();
      },
      seed: () => ContributionLoaded(
        contributions: [tContribution],
        hasMore: false,
        currentPage: 1,
      ),
      act: (bloc) => bloc.add(const WithdrawContributionEvent(
        contributionId: 'c1',
        currentStatus: ContributionStatus.pending,
      )),
      expect: () => [isA<ContributionWithdrawing>(), isA<ContributionWithdrawn>()],
      verify: (bloc) {
        final withdrawn = bloc.state as ContributionWithdrawn;
        expect(withdrawn.contributions, isEmpty);
        expect(withdrawn.withdrawnId, 'c1');
      },
    );

    blocTest<ContributionBloc, ContributionState>(
      'WithdrawContribution on ConflictFailure emits ContributionError',
      build: () {
        when(() => mockWithdraw(any()))
            .thenAnswer((_) async => const Left(ConflictFailure()));
        return makeBloc();
      },
      seed: () => ContributionLoaded(
        contributions: [tContribution],
        hasMore: false,
        currentPage: 1,
      ),
      act: (bloc) => bloc.add(const WithdrawContributionEvent(
        contributionId: 'c1',
        currentStatus: ContributionStatus.approved, // use approved to trigger client-side conflict
      )),
      expect: () => [isA<ContributionWithdrawing>(), isA<ContributionError>()],
    );
  });
}
