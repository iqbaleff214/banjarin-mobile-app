import 'package:banjarin/core/error/failures.dart';
import 'package:banjarin/features/community/domain/entities/vote.dart';
import 'package:banjarin/features/community/domain/usecases/cast_vote.dart';
import 'package:banjarin/features/community/domain/usecases/remove_vote.dart';
import 'package:banjarin/features/community/presentation/bloc/vote_bloc.dart';
import 'package:banjarin/features/community/presentation/bloc/vote_event.dart';
import 'package:banjarin/features/community/presentation/bloc/vote_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockCastVote extends Mock implements CastVote {}
class MockRemoveVote extends Mock implements RemoveVote {}

void main() {
  late MockCastVote mockCastVote;
  late MockRemoveVote mockRemoveVote;

  final tVote = Vote(
    id: '1', userId: 'u1',
    targetType: VoteTargetType.word, targetId: 'w1',
    value: VoteValue.up, createdAt: DateTime(2024),
  );

  setUp(() {
    mockCastVote = MockCastVote();
    mockRemoveVote = MockRemoveVote();
    registerFallbackValue(CastVoteParams(
      targetId: '', targetType: VoteTargetType.word,
      value: VoteValue.up, isAuthenticated: true,
    ));
    registerFallbackValue(RemoveVoteParams(
      targetId: '', targetType: VoteTargetType.word, isAuthenticated: true,
    ));
  });

  VoteBloc makeBloc() =>
      VoteBloc(castVote: mockCastVote, removeVote: mockRemoveVote);

  group('VoteBloc', () {
    blocTest<VoteBloc, VoteState>(
      'CastVote up emits [Voting, VoteUpdated(up)]',
      build: () {
        when(() => mockCastVote(any())).thenAnswer((_) async => Right(tVote));
        return makeBloc();
      },
      act: (bloc) => bloc.add(const CastVoteEvent(
        targetId: 'w1',
        targetType: VoteTargetType.word,
        value: VoteValue.up,
        isAuthenticated: true,
      )),
      expect: () => [
        isA<Voting>().having((s) => s.currentVote, 'vote', VoteValue.up),
        isA<VoteUpdated>().having((s) => s.currentVote, 'vote', VoteValue.up),
      ],
    );

    blocTest<VoteBloc, VoteState>(
      'CastVote up when already up emits [Voting(none), VoteUpdated(none)] (remove)',
      build: () {
        when(() => mockRemoveVote(any())).thenAnswer((_) async => const Right(null));
        return makeBloc();
      },
      seed: () => const VoteUpdated(currentVote: VoteValue.up, upvotes: 1, downvotes: 0),
      act: (bloc) => bloc.add(const CastVoteEvent(
        targetId: 'w1',
        targetType: VoteTargetType.word,
        value: VoteValue.up,
        isAuthenticated: true,
      )),
      expect: () => [
        isA<Voting>().having((s) => s.currentVote, 'vote', isNull),
        isA<VoteUpdated>().having((s) => s.currentVote, 'vote', isNull),
      ],
    );

    blocTest<VoteBloc, VoteState>(
      'CastVote on failure reverts to previous vote state',
      build: () {
        when(() => mockCastVote(any()))
            .thenAnswer((_) async => const Left(NetworkFailure()));
        return makeBloc();
      },
      seed: () => const VoteUpdated(currentVote: null, upvotes: 2, downvotes: 1),
      act: (bloc) => bloc.add(const CastVoteEvent(
        targetId: 'w1',
        targetType: VoteTargetType.word,
        value: VoteValue.up,
        isAuthenticated: true,
      )),
      expect: () => [
        isA<Voting>(),
        isA<VoteError>()
            .having((s) => s.currentVote, 'reverted vote', isNull)
            .having((s) => s.upvotes, 'upvotes', 2),
      ],
    );

    blocTest<VoteBloc, VoteState>(
      'CastVote when unauthenticated emits VoteError with UnauthorizedFailure',
      build: () => makeBloc(),
      act: (bloc) => bloc.add(const CastVoteEvent(
        targetId: 'w1',
        targetType: VoteTargetType.word,
        value: VoteValue.up,
        isAuthenticated: false,
      )),
      expect: () => [
        isA<VoteError>().having(
          (s) => s.failure,
          'failure',
          isA<UnauthorizedFailure>(),
        ),
      ],
    );
  });
}
