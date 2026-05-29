import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import 'local_cache.dart';

class HiveLocalCache implements LocalCache {
  static const _boxName = 'banjarin_cache';
  static const _defaultTtl = Duration(minutes: 10);

  final Box _box;

  HiveLocalCache(this._box);

  static Future<HiveLocalCache> create() async {
    final box = await Hive.openBox(_boxName);
    return HiveLocalCache(box);
  }

  String _expiryKey(String key) => '${key}__expiry';

  @override
  Future<void> put<T>(String key, T value, {Duration? ttl}) async {
    final effectiveTtl = ttl ?? _defaultTtl;
    final expiry =
        DateTime.now().add(effectiveTtl).millisecondsSinceEpoch;
    final encoded = jsonEncode(value);

    await Future.wait([
      _box.put(key, encoded),
      _box.put(_expiryKey(key), expiry),
    ]);
  }

  @override
  Future<T?> get<T>(String key) async {
    final expiryMs = _box.get(_expiryKey(key)) as int?;

    if (expiryMs == null) return null;

    if (DateTime.now().millisecondsSinceEpoch > expiryMs) {
      await invalidate(key);
      return null;
    }

    final encoded = _box.get(key) as String?;
    if (encoded == null) return null;

    return jsonDecode(encoded) as T?;
  }

  @override
  Future<void> invalidate(String key) async {
    await Future.wait([
      _box.delete(key),
      _box.delete(_expiryKey(key)),
    ]);
  }

  @override
  Future<void> clear() => _box.clear().then((_) {});
}
