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
}
