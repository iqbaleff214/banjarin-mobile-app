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
}
