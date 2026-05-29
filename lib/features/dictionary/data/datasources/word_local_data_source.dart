import '../../../../core/storage/local_cache.dart';

class WordLocalDataSource {
  static const _wordListKey = 'word_list_p1';
  static const _wordListTtl = Duration(minutes: 5);
  static const _wordDetailTtl = Duration(minutes: 10);

  final LocalCache _cache;

  WordLocalDataSource({required LocalCache cache}) : _cache = cache;

  String _detailKey(String wordId) => 'word_detail_$wordId';

  Future<List<Map<String, dynamic>>?> getCachedWordList() async {
    final raw = await _cache.get<List<dynamic>>(_wordListKey);
    if (raw == null) return null;
    return raw.cast<Map<String, dynamic>>();
  }

  Future<void> cacheWordList(List<Map<String, dynamic>> words) {
    return _cache.put(_wordListKey, words, ttl: _wordListTtl);
  }

  Future<Map<String, dynamic>?> getCachedWord(String wordId) {
    return _cache.get<Map<String, dynamic>>(_detailKey(wordId));
  }

  Future<void> cacheWord(String wordId, Map<String, dynamic> word) {
    return _cache.put(_detailKey(wordId), word, ttl: _wordDetailTtl);
  }

  // Recent searches (long TTL — treat as persistent)
  static const _recentSearchesKey = 'recent_searches';
  static const _maxRecentSearches = 10;

  Future<List<String>> getRecentSearches() async {
    final raw = await _cache.get<List<dynamic>>(_recentSearchesKey);
    if (raw == null) return [];
    return raw.cast<String>();
  }

  Future<void> addRecentSearch(String query) async {
    final searches = await getRecentSearches();
    final updated = [
      query,
      ...searches.where((s) => s != query),
    ].take(_maxRecentSearches).toList();
    await _cache.put(
      _recentSearchesKey,
      updated,
      ttl: const Duration(days: 365),
    );
  }

  Future<void> clearRecentSearches() => _cache.invalidate(_recentSearchesKey);
}
