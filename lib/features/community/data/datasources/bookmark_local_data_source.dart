import '../../../../core/storage/local_cache.dart';

class BookmarkLocalDataSource {
  static const _bookmarksKey = 'bookmarks_p1';
  static const _bookmarksTtl = Duration(hours: 1);

  final LocalCache _cache;

  BookmarkLocalDataSource({required LocalCache cache}) : _cache = cache;

  Future<List<Map<String, dynamic>>?> getCachedBookmarks() async {
    final raw = await _cache.get<List<dynamic>>(_bookmarksKey);
    if (raw == null) return null;
    return raw.cast<Map<String, dynamic>>();
  }

  Future<void> cacheBookmarks(List<Map<String, dynamic>> bookmarks) {
    return _cache.put(_bookmarksKey, bookmarks, ttl: _bookmarksTtl);
  }

  Future<void> invalidate() => _cache.invalidate(_bookmarksKey);

  // Bookmarked word IDs set for O(1) lookup
  static const _bookmarkedIdsKey = 'bookmarked_ids';

  Future<Set<String>> getBookmarkedIds() async {
    final raw = await _cache.get<List<dynamic>>(_bookmarkedIdsKey);
    if (raw == null) return {};
    return raw.cast<String>().toSet();
  }

  Future<void> addBookmarkedId(String wordId) async {
    final ids = await getBookmarkedIds();
    ids.add(wordId);
    await _cache.put(
      _bookmarkedIdsKey,
      ids.toList(),
      ttl: const Duration(hours: 24),
    );
  }

  Future<void> removeBookmarkedId(String wordId) async {
    final ids = await getBookmarkedIds();
    ids.remove(wordId);
    await _cache.put(
      _bookmarkedIdsKey,
      ids.toList(),
      ttl: const Duration(hours: 24),
    );
  }
}
