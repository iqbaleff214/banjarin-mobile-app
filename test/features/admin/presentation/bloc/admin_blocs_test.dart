import 'package:banjarin/core/usecase/paginated_result.dart';
import 'package:banjarin/core/usecase/usecase.dart';
import 'package:banjarin/features/admin/domain/repositories/admin_repository.dart';
import 'package:banjarin/features/admin/domain/usecases/approve_contribution.dart';
import 'package:banjarin/features/admin/domain/usecases/ban_user.dart' as ban_uc;
import 'package:banjarin/features/admin/domain/usecases/change_user_role.dart';
import 'package:banjarin/features/admin/domain/usecases/create_word.dart';
import 'package:banjarin/features/admin/domain/usecases/delete_word.dart';
import 'package:banjarin/features/admin/domain/usecases/get_admin_users.dart';
import 'package:banjarin/features/admin/domain/usecases/get_admin_words.dart';
import 'package:banjarin/features/admin/domain/usecases/get_flagged_comments.dart';
import 'package:banjarin/features/admin/domain/usecases/get_moderation_queue.dart';
import 'package:banjarin/features/admin/domain/usecases/get_moderation_stats.dart';
import 'package:banjarin/features/admin/domain/usecases/reject_contribution.dart';
import 'package:banjarin/features/admin/domain/usecases/unban_user.dart';
import 'package:banjarin/features/admin/domain/usecases/update_word.dart';
import 'package:banjarin/features/admin/presentation/bloc/admin_word_bloc.dart';
import 'package:banjarin/features/admin/presentation/bloc/admin_word_event.dart';
import 'package:banjarin/features/admin/presentation/bloc/admin_word_state.dart';
import 'package:banjarin/features/admin/presentation/bloc/moderation_bloc.dart';
import 'package:banjarin/features/admin/presentation/bloc/moderation_event.dart';
import 'package:banjarin/features/admin/presentation/bloc/moderation_state.dart';
import 'package:banjarin/features/admin/presentation/bloc/user_mgmt_bloc.dart';
import 'package:banjarin/features/admin/presentation/bloc/user_mgmt_event.dart';
import 'package:banjarin/features/admin/presentation/bloc/user_mgmt_state.dart';
import 'package:banjarin/features/community/domain/entities/contribution.dart';
import 'package:banjarin/features/dictionary/domain/entities/content_source.dart';
import 'package:banjarin/features/dictionary/domain/entities/word_class.dart';
import 'package:banjarin/features/dictionary/domain/entities/word_summary.dart';
import 'package:banjarin/features/identity/domain/entities/user.dart';
import 'package:banjarin/features/identity/domain/entities/user_role.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAdminWords extends Mock implements GetAdminWords {}
class MockCreateWord extends Mock implements CreateWord {}
class MockUpdateWord extends Mock implements UpdateWord {}
class MockDeleteWord extends Mock implements DeleteWord {}
class MockGetAdminUsers extends Mock implements GetAdminUsers {}
class MockBanUser extends Mock implements ban_uc.BanUser {}
class MockUnbanUser extends Mock implements UnbanUser {}
class MockChangeUserRole extends Mock implements ChangeUserRole {}
class MockGetModerationQueue extends Mock implements GetModerationQueue {}
class MockGetFlaggedComments extends Mock implements GetFlaggedComments {}
class MockGetModerationStats extends Mock implements GetModerationStats {}
class MockApproveContribution extends Mock implements ApproveContribution {}
class MockRejectContribution extends Mock implements RejectContribution {}

void main() {
  // Fixtures
  final tWord = WordSummary(
    id: 'w1', banjar: 'abah', dialect: 'hulu',
    wordClass: WordClass.n, homonymNumber: 1, isRoot: true,
    primaryMeaning: 'ayah', source: ContentSource.seeded,
    createdAt: DateTime(2024),
  );
  final tUser = User(
    id: 'u1', name: 'Ahmad', email: 'a@b.com',
    role: UserRole.user, isActive: true, createdAt: DateTime(2024),
  );
  final tContrib = Contribution(
    id: 'c1', type: ContributionType.new_word, contributorId: 'u1',
    payload: const {}, status: ContributionStatus.pending,
    submittedAt: DateTime(2024),
  );

  setUp(() {
    registerFallbackValue(const GetAdminWordsParams());
    registerFallbackValue(const GetAdminUsersParams());
    registerFallbackValue(const GetModerationQueueParams());
    registerFallbackValue(const GetFlaggedCommentsParams());
    registerFallbackValue(const NoParams());
    registerFallbackValue(const DeleteWordParams(wordId: ''));
    registerFallbackValue(ban_uc.BanUserParams(userId: '', reason: ''));
    registerFallbackValue(const UnbanUserParams(userId: ''));
    registerFallbackValue(const ChangeUserRoleParams(userId: '', newRole: UserRole.user));
    registerFallbackValue(const ApproveContributionParams(contributionId: ''));
    registerFallbackValue(const RejectContributionParams(contributionId: '', note: ''));
    registerFallbackValue(const CreateWordParams(
      banjar: '', wordClass: WordClass.n, definitions: [],
    ));
    registerFallbackValue(UserRole.user);
  });

  // -------------------------------------------------------------------------
  // AdminWordBloc
  // -------------------------------------------------------------------------
  group('AdminWordBloc', () {
    late MockGetAdminWords mockGet;
    late MockCreateWord mockCreate;
    late MockUpdateWord mockUpdate;
    late MockDeleteWord mockDelete;

    setUp(() {
      mockGet = MockGetAdminWords();
      mockCreate = MockCreateWord();
      mockUpdate = MockUpdateWord();
      mockDelete = MockDeleteWord();
    });

    AdminWordBloc makeBloc() => AdminWordBloc(
          getWords: mockGet,
          createWord: mockCreate,
          updateWord: mockUpdate,
          deleteWord: mockDelete,
        );

    blocTest<AdminWordBloc, AdminWordState>(
      'LoadAdminWords emits [Loading, Loaded]',
      build: () {
        when(() => mockGet(any())).thenAnswer((_) async => Right(PaginatedResult(
          items: [tWord], page: 1, perPage: 20, total: 1,
        )));
        return makeBloc();
      },
      act: (bloc) => bloc.add(const LoadAdminWords()),
      expect: () => [isA<AdminWordLoading>(), isA<AdminWordLoaded>()],
      verify: (bloc) {
        expect((bloc.state as AdminWordLoaded).words.first.banjar, 'abah');
      },
    );

    blocTest<AdminWordBloc, AdminWordState>(
      'DeleteWord emits [Deleting, Deleted] and removes from list',
      build: () {
        when(() => mockDelete(any()))
            .thenAnswer((_) async => const Right(null));
        return makeBloc();
      },
      seed: () => AdminWordLoaded(words: [tWord], hasMore: false, currentPage: 1),
      act: (bloc) => bloc.add(const DeleteWordEvent('w1')),
      expect: () => [isA<AdminWordDeleting>(), isA<AdminWordDeleted>()],
      verify: (bloc) {
        expect((bloc.state as AdminWordDeleted).words, isEmpty);
        expect((bloc.state as AdminWordDeleted).deletedId, 'w1');
      },
    );
  });

  // -------------------------------------------------------------------------
  // UserMgmtBloc
  // -------------------------------------------------------------------------
  group('UserMgmtBloc', () {
    late MockGetAdminUsers mockGet;
    late MockBanUser mockBan;
    late MockUnbanUser mockUnban;
    late MockChangeUserRole mockChange;

    setUp(() {
      mockGet = MockGetAdminUsers();
      mockBan = MockBanUser();
      mockUnban = MockUnbanUser();
      mockChange = MockChangeUserRole();
    });

    UserMgmtBloc makeBloc() => UserMgmtBloc(
          getUsers: mockGet,
          banUser: mockBan,
          unbanUser: mockUnban,
          changeRole: mockChange,
        );

    blocTest<UserMgmtBloc, UserMgmtState>(
      'BanUser emits [Banning, Banned] and updates user in list',
      build: () {
        when(() => mockBan(any())).thenAnswer((_) async =>
            Right(tUser.copyWith(isActive: false)));
        return makeBloc();
      },
      seed: () => UserMgmtLoaded(users: [tUser], hasMore: false, currentPage: 1),
      act: (bloc) => bloc.add(const BanUserEvent(userId: 'u1', reason: 'Spam')),
      expect: () => [isA<Banning>(), isA<Banned>()],
      verify: (bloc) {
        final banned = bloc.state as Banned;
        expect(banned.users.first.isActive, isFalse);
      },
    );

    blocTest<UserMgmtBloc, UserMgmtState>(
      'ChangeRole emits [ChangingRole, RoleChanged]',
      build: () {
        when(() => mockChange(any())).thenAnswer((_) async =>
            Right(tUser.copyWith(role: UserRole.admin)));
        return makeBloc();
      },
      seed: () => UserMgmtLoaded(users: [tUser], hasMore: false, currentPage: 1),
      act: (bloc) => bloc.add(const ChangeUserRoleEvent(
        userId: 'u1', newRole: UserRole.admin,
      )),
      expect: () => [isA<ChangingRole>(), isA<RoleChanged>()],
    );
  });

  // -------------------------------------------------------------------------
  // ModerationBloc
  // -------------------------------------------------------------------------
  group('ModerationBloc', () {
    late MockGetModerationQueue mockQueue;
    late MockGetFlaggedComments mockFlags;
    late MockGetModerationStats mockStats;
    late MockApproveContribution mockApprove;
    late MockRejectContribution mockReject;

    setUp(() {
      mockQueue = MockGetModerationQueue();
      mockFlags = MockGetFlaggedComments();
      mockStats = MockGetModerationStats();
      mockApprove = MockApproveContribution();
      mockReject = MockRejectContribution();
    });

    ModerationBloc makeBloc() => ModerationBloc(
          getQueue: mockQueue,
          getFlags: mockFlags,
          getStats: mockStats,
          approve: mockApprove,
          reject: mockReject,
        );

    blocTest<ModerationBloc, ModerationState>(
      'LoadModerationQueue emits [Loading, Loaded]',
      build: () {
        when(() => mockQueue(any())).thenAnswer((_) async => Right(PaginatedResult(
          items: [tContrib], page: 1, perPage: 20, total: 1,
        )));
        return makeBloc();
      },
      act: (bloc) => bloc.add(const LoadModerationQueue()),
      expect: () => [isA<ModerationLoading>(), isA<ModerationLoaded>()],
      verify: (bloc) {
        expect((bloc.state as ModerationLoaded).queue.first.id, 'c1');
      },
    );

    blocTest<ModerationBloc, ModerationState>(
      'ApproveContribution emits [Approving, Approved] and removes from queue',
      build: () {
        when(() => mockApprove(any())).thenAnswer((_) async => Right(tContrib));
        return makeBloc();
      },
      seed: () => ModerationLoaded(queue: [tContrib]),
      act: (bloc) => bloc.add(const ApproveContributionEvent(contributionId: 'c1')),
      expect: () => [isA<ModerationApproving>(), isA<ModerationApproved>()],
      verify: (bloc) {
        expect((bloc.state as ModerationApproved).queue, isEmpty);
        expect((bloc.state as ModerationApproved).approvedId, 'c1');
      },
    );

    blocTest<ModerationBloc, ModerationState>(
      'RejectContribution emits [Rejecting, Rejected] and removes from queue',
      build: () {
        when(() => mockReject(any())).thenAnswer((_) async => Right(tContrib));
        return makeBloc();
      },
      seed: () => ModerationLoaded(queue: [tContrib]),
      act: (bloc) => bloc.add(const RejectContributionEvent(
        contributionId: 'c1', note: 'Wrong',
      )),
      expect: () => [isA<ModerationRejecting>(), isA<ModerationRejected>()],
      verify: (bloc) {
        expect((bloc.state as ModerationRejected).queue, isEmpty);
      },
    );
  });
}
