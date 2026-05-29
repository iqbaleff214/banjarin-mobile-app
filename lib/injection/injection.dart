import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';

import '../core/network/dio_client.dart';
import '../core/network/token_interceptor.dart';
import '../core/storage/hive_local_cache.dart';
import '../core/storage/local_cache.dart';
import '../core/storage/secure_token_storage.dart';
import '../core/storage/token_storage.dart';
import '../features/identity/data/datasources/auth_remote_data_source.dart';
import '../features/identity/data/repositories/auth_repository_impl.dart';
import '../features/identity/domain/repositories/auth_repository.dart';
import '../features/identity/domain/usecases/change_password.dart';
import '../features/identity/domain/usecases/forgot_password.dart';
import '../features/identity/domain/usecases/get_profile.dart';
import '../features/identity/domain/usecases/login.dart';
import '../features/identity/domain/usecases/logout.dart';
import '../features/identity/domain/usecases/refresh_token.dart';
import '../features/identity/domain/usecases/register.dart';
import '../features/identity/domain/usecases/reset_password.dart';
import '../features/identity/domain/usecases/update_profile.dart';
import '../features/identity/domain/usecases/verify_email.dart';
import '../features/identity/presentation/bloc/auth_bloc.dart';
import '../features/identity/presentation/bloc/profile_bloc.dart';
import '../features/dictionary/data/datasources/word_local_data_source.dart';
import '../features/dictionary/data/datasources/word_remote_data_source.dart';
import '../features/dictionary/data/repositories/word_repository_impl.dart';
import '../features/dictionary/domain/repositories/word_repository.dart';
import '../features/dictionary/domain/usecases/get_definitions.dart';
import '../features/dictionary/domain/usecases/get_examples.dart';
import '../features/dictionary/domain/usecases/get_related_words.dart';
import '../features/dictionary/domain/usecases/get_word_detail.dart';
import '../features/dictionary/domain/usecases/get_word_list.dart';
import '../features/dictionary/domain/usecases/search_words.dart';
import '../features/dictionary/presentation/bloc/search_bloc.dart';
import '../features/dictionary/presentation/bloc/word_detail_bloc.dart';
import '../features/dictionary/presentation/bloc/word_list_bloc.dart';
import '../features/community/data/datasources/bookmark_local_data_source.dart';
import '../features/community/data/datasources/bookmark_remote_data_source.dart';
import '../features/community/data/datasources/comment_remote_data_source.dart';
import '../features/community/data/datasources/vote_remote_data_source.dart';
import '../features/community/data/repositories/bookmark_repository_impl.dart';
import '../features/community/data/repositories/comment_repository_impl.dart';
import '../features/community/data/repositories/vote_repository_impl.dart';
import '../features/community/domain/repositories/bookmark_repository.dart';
import '../features/community/domain/repositories/comment_repository.dart';
import '../features/community/domain/repositories/vote_repository.dart';
import '../features/community/domain/usecases/add_bookmark.dart';
import '../features/community/domain/usecases/cast_vote.dart';
import '../features/community/domain/usecases/delete_comment.dart';
import '../features/community/domain/usecases/edit_comment.dart';
import '../features/community/domain/usecases/flag_comment.dart';
import '../features/community/domain/usecases/get_bookmarks.dart';
import '../features/community/domain/usecases/get_comments.dart';
import '../features/community/domain/usecases/post_comment.dart';
import '../features/community/domain/usecases/remove_bookmark.dart';
import '../features/community/domain/usecases/remove_vote.dart';
import '../features/community/presentation/bloc/bookmark_bloc.dart';
import '../features/community/presentation/bloc/comment_bloc.dart';
import '../features/community/presentation/bloc/vote_bloc.dart';
import '../features/ai/data/datasources/ai_remote_data_source.dart';
import '../features/ai/data/repositories/ai_repository_impl.dart';
import '../features/ai/domain/repositories/ai_repository.dart';
import '../features/ai/domain/usecases/translate_banjar.dart';
import '../features/ai/presentation/bloc/translate_bloc.dart';
import '../features/admin/data/datasources/admin_remote_data_source.dart';
import '../features/admin/data/repositories/admin_repository_impl.dart';
import '../features/admin/domain/repositories/admin_repository.dart';
import '../features/admin/domain/usecases/approve_contribution.dart';
import '../features/admin/domain/usecases/ban_user.dart' as ban_uc;
import '../features/admin/domain/usecases/change_user_role.dart';
import '../features/admin/domain/usecases/create_word.dart' as admin_cw;
import '../features/admin/domain/usecases/delete_word.dart' as admin_dw;
import '../features/admin/domain/usecases/get_admin_users.dart';
import '../features/admin/domain/usecases/get_admin_words.dart';
import '../features/admin/domain/usecases/get_flagged_comments.dart';
import '../features/admin/domain/usecases/get_moderation_queue.dart';
import '../features/admin/domain/usecases/get_moderation_stats.dart';
import '../features/admin/domain/usecases/reject_contribution.dart' as admin_rc;
import '../features/admin/domain/usecases/unban_user.dart';
import '../features/admin/domain/usecases/update_word.dart';
import '../features/admin/presentation/bloc/admin_word_bloc.dart';
import '../features/admin/presentation/bloc/moderation_bloc.dart';
import '../features/admin/presentation/bloc/user_mgmt_bloc.dart';
import '../features/community/data/datasources/contribution_remote_data_source.dart';
import '../features/community/data/repositories/contribution_repository_impl.dart';
import '../features/community/domain/repositories/contribution_repository.dart';
import '../features/community/domain/usecases/get_contribution_detail.dart';
import '../features/community/domain/usecases/get_contributions.dart';
import '../features/community/domain/usecases/submit_contribution.dart';
import '../features/community/domain/usecases/withdraw_contribution.dart';
import '../features/community/presentation/bloc/contribution_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ---------------------------------------------------------------------------
  // Core — Storage
  // ---------------------------------------------------------------------------
  final hiveCache = await HiveLocalCache.create();
  sl.registerSingleton<LocalCache>(hiveCache);
  sl.registerSingleton<TokenStorage>(const SecureTokenStorage());

  // ---------------------------------------------------------------------------
  // Core — Network
  // ---------------------------------------------------------------------------
  final baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // Refresh-only Dio (no token interceptor to avoid infinite loop)
  final refreshDio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  final mainDio = DioClient.create()
    ..interceptors.add(
      TokenInterceptor(
        tokenStorage: sl<TokenStorage>(),
        refreshDio: refreshDio,
      ),
    );

  sl.registerSingleton<Dio>(mainDio);

  // ---------------------------------------------------------------------------
  // Identity — Data layer
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      tokenStorage: sl<TokenStorage>(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Identity — Use cases
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton(() => Login(sl<AuthRepository>()));
  sl.registerLazySingleton(() => Register(sl<AuthRepository>()));
  sl.registerLazySingleton(() => Logout(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RefreshToken(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetProfile(sl<AuthRepository>()));
  sl.registerLazySingleton(() => UpdateProfile(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ChangePassword(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ForgotPassword(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ResetPassword(sl<AuthRepository>()));
  sl.registerLazySingleton(() => VerifyEmail(sl<AuthRepository>()));

  // ---------------------------------------------------------------------------
  // Identity — Blocs
  // ---------------------------------------------------------------------------
  sl.registerFactory(
    () => AuthBloc(
      login: sl<Login>(),
      register: sl<Register>(),
      logout: sl<Logout>(),
      getProfile: sl<GetProfile>(),
      tokenStorage: sl<TokenStorage>(),
    ),
  );
  sl.registerFactory(
    () => ProfileBloc(
      getProfile: sl<GetProfile>(),
      updateProfile: sl<UpdateProfile>(),
      changePassword: sl<ChangePassword>(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Dictionary — Data layer
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<WordRemoteDataSource>(
    () => WordRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton(
    () => WordLocalDataSource(cache: sl<LocalCache>()),
  );
  sl.registerLazySingleton<WordRepository>(
    () => WordRepositoryImpl(
      remote: sl<WordRemoteDataSource>(),
      local: sl<WordLocalDataSource>(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Dictionary — Use cases
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton(() => GetWordList(sl<WordRepository>()));
  sl.registerLazySingleton(() => SearchWords(sl<WordRepository>()));
  sl.registerLazySingleton(() => GetWordDetail(sl<WordRepository>()));
  sl.registerLazySingleton(() => GetDefinitions(sl<WordRepository>()));
  sl.registerLazySingleton(() => GetExamples(sl<WordRepository>()));
  sl.registerLazySingleton(() => GetRelatedWords(sl<WordRepository>()));

  // ---------------------------------------------------------------------------
  // Dictionary — Blocs
  // ---------------------------------------------------------------------------
  sl.registerFactory(
    () => WordListBloc(getWordList: sl<GetWordList>()),
  );
  sl.registerFactory(
    () => SearchBloc(searchWords: sl<SearchWords>()),
  );
  sl.registerFactory(
    () => WordDetailBloc(
      getWordDetail: sl<GetWordDetail>(),
      getDefinitions: sl<GetDefinitions>(),
      getExamples: sl<GetExamples>(),
      getRelatedWords: sl<GetRelatedWords>(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Community — Data layer
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<VoteRemoteDataSource>(
    () => VoteRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<VoteRepository>(
    () => VoteRepositoryImpl(remoteDataSource: sl<VoteRemoteDataSource>()),
  );

  sl.registerLazySingleton<BookmarkRemoteDataSource>(
    () => BookmarkRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton(
    () => BookmarkLocalDataSource(cache: sl<LocalCache>()),
  );
  sl.registerLazySingleton<BookmarkRepository>(
    () => BookmarkRepositoryImpl(
      remote: sl<BookmarkRemoteDataSource>(),
      local: sl<BookmarkLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<CommentRemoteDataSource>(
    () => CommentRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<CommentRepository>(
    () => CommentRepositoryImpl(remote: sl<CommentRemoteDataSource>()),
  );

  // ---------------------------------------------------------------------------
  // Community — Use cases
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton(() => CastVote(sl<VoteRepository>()));
  sl.registerLazySingleton(() => RemoveVote(sl<VoteRepository>()));
  sl.registerLazySingleton(() => GetBookmarks(sl<BookmarkRepository>()));
  sl.registerLazySingleton(() => AddBookmark(sl<BookmarkRepository>()));
  sl.registerLazySingleton(() => RemoveBookmark(sl<BookmarkRepository>()));
  sl.registerLazySingleton(() => GetComments(sl<CommentRepository>()));
  sl.registerLazySingleton(() => PostComment(sl<CommentRepository>()));
  sl.registerLazySingleton(() => EditComment(sl<CommentRepository>()));
  sl.registerLazySingleton(() => DeleteComment(sl<CommentRepository>()));
  sl.registerLazySingleton(() => FlagComment(sl<CommentRepository>()));

  // ---------------------------------------------------------------------------
  // Community — Blocs
  // ---------------------------------------------------------------------------
  sl.registerFactory(
    () => VoteBloc(castVote: sl<CastVote>(), removeVote: sl<RemoveVote>()),
  );
  sl.registerFactory(
    () => BookmarkBloc(
      getBookmarks: sl<GetBookmarks>(),
      addBookmark: sl<AddBookmark>(),
      removeBookmark: sl<RemoveBookmark>(),
    ),
  );
  sl.registerFactory(
    () => CommentBloc(
      getComments: sl<GetComments>(),
      postComment: sl<PostComment>(),
      editComment: sl<EditComment>(),
      deleteComment: sl<DeleteComment>(),
      flagComment: sl<FlagComment>(),
    ),
  );

  // ---------------------------------------------------------------------------
  // AI — Data layer
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<AIRemoteDataSource>(
    () => AIRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<AIRepository>(
    () => AIRepositoryImpl(remoteDataSource: sl<AIRemoteDataSource>()),
  );

  // ---------------------------------------------------------------------------
  // AI — Use cases
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton(() => TranslateBanjar(sl<AIRepository>()));

  // ---------------------------------------------------------------------------
  // AI — Blocs
  // ---------------------------------------------------------------------------
  sl.registerFactory(
    () => TranslateBloc(translateBanjar: sl<TranslateBanjar>()),
  );

  // ---------------------------------------------------------------------------
  // Admin — Data layer
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(remote: sl<AdminRemoteDataSource>()),
  );

  // ---------------------------------------------------------------------------
  // Admin — Use cases
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton(() => GetAdminWords(sl<AdminRepository>()));
  sl.registerLazySingleton(() => admin_cw.CreateWord(sl<AdminRepository>()));
  sl.registerLazySingleton(() => UpdateWord(sl<AdminRepository>()));
  sl.registerLazySingleton(() => admin_dw.DeleteWord(sl<AdminRepository>()));
  sl.registerLazySingleton(() => GetAdminUsers(sl<AdminRepository>()));
  sl.registerLazySingleton(() => ban_uc.BanUser(sl<AdminRepository>()));
  sl.registerLazySingleton(() => UnbanUser(sl<AdminRepository>()));
  sl.registerLazySingleton(() => ChangeUserRole(sl<AdminRepository>()));
  sl.registerLazySingleton(() => GetModerationQueue(sl<AdminRepository>()));
  sl.registerLazySingleton(() => GetFlaggedComments(sl<AdminRepository>()));
  sl.registerLazySingleton(() => GetModerationStats(sl<AdminRepository>()));
  sl.registerLazySingleton(() => ApproveContribution(sl<AdminRepository>()));
  sl.registerLazySingleton(() => admin_rc.RejectContribution(sl<AdminRepository>()));

  // ---------------------------------------------------------------------------
  // Admin — Blocs
  // ---------------------------------------------------------------------------
  sl.registerFactory(
    () => AdminWordBloc(
      getWords: sl<GetAdminWords>(),
      createWord: sl<admin_cw.CreateWord>(),
      updateWord: sl<UpdateWord>(),
      deleteWord: sl<admin_dw.DeleteWord>(),
    ),
  );
  sl.registerFactory(
    () => UserMgmtBloc(
      getUsers: sl<GetAdminUsers>(),
      banUser: sl<ban_uc.BanUser>(),
      unbanUser: sl<UnbanUser>(),
      changeRole: sl<ChangeUserRole>(),
    ),
  );
  sl.registerFactory(
    () => ModerationBloc(
      getQueue: sl<GetModerationQueue>(),
      getFlags: sl<GetFlaggedComments>(),
      getStats: sl<GetModerationStats>(),
      approve: sl<ApproveContribution>(),
      reject: sl<admin_rc.RejectContribution>(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Community — Contributions data layer
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<ContributionRemoteDataSource>(
    () => ContributionRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<ContributionRepository>(
    () => ContributionRepositoryImpl(remote: sl<ContributionRemoteDataSource>()),
  );

  // ---------------------------------------------------------------------------
  // Community — Contributions use cases
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton(
    () => SubmitContribution(sl<ContributionRepository>()),
  );
  sl.registerLazySingleton(
    () => GetContributions(sl<ContributionRepository>()),
  );
  sl.registerLazySingleton(
    () => GetContributionDetail(sl<ContributionRepository>()),
  );
  sl.registerLazySingleton(
    () => WithdrawContribution(sl<ContributionRepository>()),
  );

  // ---------------------------------------------------------------------------
  // Community — ContributionBloc
  // ---------------------------------------------------------------------------
  sl.registerFactory(
    () => ContributionBloc(
      submit: sl<SubmitContribution>(),
      getContributions: sl<GetContributions>(),
      withdraw: sl<WithdrawContribution>(),
    ),
  );
}
