class CacheConfig {
  CacheConfig._();

  // Word list first page
  static const wordListTtl = Duration(minutes: 5);

  // Word detail per ID
  static const wordDetailTtl = Duration(minutes: 10);

  // Bookmarks — sync on reconnect; treated as "indefinitely" locally
  static const bookmarksTtl = Duration(days: 365);

  // Recent searches — user preference, persisted long-term
  static const recentSearchesTtl = Duration(days: 365);

  // These are explicitly NEVER cached (stateless):
  //   - Search results
  //   - AI translation results
  //   - Contribution submissions
}
