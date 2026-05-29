enum SortWords {
  alphabetical,
  // ignore: constant_identifier_names
  most_voted,
  // ignore: constant_identifier_names
  recently_added;

  String get apiValue => name;

  static SortWords fromString(String value) {
    return SortWords.values.firstWhere(
      (s) => s.name == value,
      orElse: () => SortWords.alphabetical,
    );
  }
}
