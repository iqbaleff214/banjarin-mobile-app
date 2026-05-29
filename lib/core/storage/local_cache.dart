abstract class LocalCache {
  Future<void> put<T>(String key, T value, {Duration? ttl});
  Future<T?> get<T>(String key);
  Future<void> invalidate(String key);
  Future<void> clear();
}
