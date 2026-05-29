import 'package:get_it/get_it.dart';

import '../core/storage/hive_local_cache.dart';
import '../core/storage/local_cache.dart';
import '../core/storage/secure_token_storage.dart';
import '../core/storage/token_storage.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Storage
  final hiveCache = await HiveLocalCache.create();
  sl.registerSingleton<LocalCache>(hiveCache);
  sl.registerSingleton<TokenStorage>(const SecureTokenStorage());
}
