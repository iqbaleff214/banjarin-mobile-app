import 'package:banjarin/core/error/failures.dart';
import 'package:banjarin/core/usecase/usecase.dart';
import 'package:banjarin/features/admin/domain/entities/moderation_stats.dart';
import 'package:banjarin/features/admin/domain/repositories/admin_repository.dart';
import 'package:banjarin/features/admin/domain/usecases/approve_contribution.dart';
import 'package:banjarin/features/admin/domain/usecases/ban_user.dart';
import 'package:banjarin/features/admin/domain/usecases/change_user_role.dart';
import 'package:banjarin/features/admin/domain/usecases/create_word.dart';
import 'package:banjarin/features/admin/domain/usecases/delete_word.dart';
import 'package:banjarin/features/admin/domain/usecases/get_moderation_stats.dart';
import 'package:banjarin/features/admin/domain/usecases/reject_contribution.dart';
import 'package:banjarin/features/community/domain/entities/contribution.dart';
import 'package:banjarin/features/dictionary/domain/entities/content_source.dart';
import 'package:banjarin/features/dictionary/domain/entities/word.dart';
import 'package:banjarin/features/dictionary/domain/entities/word_class.dart';
import 'package:banjarin/features/identity/domain/entities/user.dart';
import 'package:banjarin/features/identity/domain/entities/user_role.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminRepository extends Mock implements AdminRepository {}

void main() {
  late MockAdminRepository mockRepo;

  final tWord = Word(
    id: 'w1', banjar: 'abah', dialect: 'hulu',
    wordClass: WordClass.n, homonymNumber: 1, isRoot: true,
    definitions: [], examples: [], relatedWordIds: [],
    status: WordStatus.active, source: ContentSource.seeded,
    createdAt: DateTime(2024), updatedAt: DateTime(2024),
  );

  final tUser = User(
    id: 'u1', name: 'Ahmad', email: 'a@b.com',
    role: UserRole.user, isActive: true, createdAt: DateTime(2024),
  );

  final tContribution = Contribution(
    id: 'c1', type: ContributionType.new_word, contributorId: 'u1',
    payload: const {}, status: ContributionStatus.pending,
    submittedAt: DateTime(2024),
  );

  final tStats = const ModerationStats(
    pendingContributions: 5, flaggedComments: 2,
    approvedThisWeek: 10, rejectedThisWeek: 3,
  );

  setUp(() {
    mockRepo = MockAdminRepository();
    registerFallbackValue(const CreateWordParams(
      banjar: '', wordClass: WordClass.n,
      definitions: [], homonymNumber: 1, isRoot: true,
    ));
    registerFallbackValue(const GetAdminWordsParams());
    registerFallbackValue(const GetAdminUsersParams());
    registerFallbackValue(const GetModerationQueueParams());
    registerFallbackValue(UserRole.user);
    registerFallbackValue(<String, dynamic>{});
  });

  // -------------------------------------------------------------------------
  // CreateWord
  // -------------------------------------------------------------------------
  group('CreateWord', () {
    late CreateWord createWord;
    setUp(() => createWord = CreateWord(mockRepo));

    test('when banjar is empty returns ValidationFailure', () async {
      final result = await createWord(const CreateWordParams(
        banjar: '', wordClass: WordClass.n, definitions: [{'meaning': 'a'}],
      ));
      expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
    });

    test('when definitions list is empty returns ValidationFailure', () async {
      final result = await createWord(const CreateWordParams(
        banjar: 'abah', wordClass: WordClass.n, definitions: [],
      ));
      expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
    });

    test('when valid delegates to repository', () async {
      when(() => mockRepo.createWord(any())).thenAnswer((_) async => Right(tWord));
      final result = await createWord(const CreateWordParams(
        banjar: 'abah', wordClass: WordClass.n,
        definitions: [{'meaning': 'ayah'}],
      ));
      expect(result.isRight(), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // DeleteWord
  // -------------------------------------------------------------------------
  group('DeleteWord', () {
    late DeleteWord deleteWord;
    setUp(() => deleteWord = DeleteWord(mockRepo));

    test('delegates to repository with word id', () async {
      when(() => mockRepo.deleteWord(wordId: any(named: 'wordId')))
          .thenAnswer((_) async => const Right(null));
      final result = await deleteWord(const DeleteWordParams(wordId: 'w1'));
      expect(result.isRight(), isTrue);
      verify(() => mockRepo.deleteWord(wordId: 'w1')).called(1);
    });
  });

  // -------------------------------------------------------------------------
  // BanUser
  // -------------------------------------------------------------------------
  group('BanUser', () {
    late BanUser banUser;
    setUp(() => banUser = BanUser(mockRepo));

    test('when reason is empty returns ValidationFailure', () async {
      final result = await banUser(const BanUserParams(userId: 'u1', reason: ''));
      expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
    });

    test('when reason present delegates to repository', () async {
      when(() => mockRepo.banUser(
            userId: any(named: 'userId'),
            reason: any(named: 'reason'),
          )).thenAnswer((_) async => Right(tUser.copyWith(isActive: false)));
      final result = await banUser(
          const BanUserParams(userId: 'u1', reason: 'Spam'));
      expect(result.isRight(), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // ChangeUserRole
  // -------------------------------------------------------------------------
  group('ChangeUserRole', () {
    late ChangeUserRole changeRole;
    setUp(() => changeRole = ChangeUserRole(mockRepo));

    test('delegates to repository with new role', () async {
      when(() => mockRepo.changeUserRole(
            userId: any(named: 'userId'),
            role: any(named: 'role'),
          )).thenAnswer((_) async =>
          Right(tUser.copyWith(role: UserRole.admin)));
      final result = await changeRole(
          const ChangeUserRoleParams(userId: 'u1', newRole: UserRole.admin));
      expect(result.isRight(), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // RejectContribution
  // -------------------------------------------------------------------------
  group('RejectContribution', () {
    late RejectContribution rejectContrib;
    setUp(() => rejectContrib = RejectContribution(mockRepo));

    test('when note is empty returns ValidationFailure', () async {
      final result = await rejectContrib(
          const RejectContributionParams(contributionId: 'c1', note: ''));
      expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
    });

    test('when note present delegates to repository', () async {
      when(() => mockRepo.rejectContribution(
            contributionId: any(named: 'contributionId'),
            note: any(named: 'note'),
          )).thenAnswer((_) async => Right(tContribution));
      final result = await rejectContrib(const RejectContributionParams(
          contributionId: 'c1', note: 'Definisi salah'));
      expect(result.isRight(), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // ApproveContribution
  // -------------------------------------------------------------------------
  group('ApproveContribution', () {
    late ApproveContribution approve;
    setUp(() => approve = ApproveContribution(mockRepo));

    test('delegates to repository', () async {
      when(() => mockRepo.approveContribution(
            contributionId: any(named: 'contributionId'),
            note: any(named: 'note'),
          )).thenAnswer((_) async => Right(tContribution));
      final result = await approve(
          const ApproveContributionParams(contributionId: 'c1'));
      expect(result.isRight(), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // GetModerationStats
  // -------------------------------------------------------------------------
  group('GetModerationStats', () {
    late GetModerationStats getStats;
    setUp(() => getStats = GetModerationStats(mockRepo));

    test('delegates to repository', () async {
      when(() => mockRepo.getModerationStats())
          .thenAnswer((_) async => Right(tStats));
      final result = await getStats(const NoParams());
      expect(result.isRight(), isTrue);
      expect(result.fold((_) => null, (s) => s.pendingContributions), 5);
    });
  });
}
