enum WordClass {
  n,
  v,
  a,
  adv,
  p,
  pb,
  ki;

  String get label => switch (this) {
        WordClass.n => 'Nomina',
        WordClass.v => 'Verba',
        WordClass.a => 'Adjektiva',
        WordClass.adv => 'Adverbia',
        WordClass.p => 'Partikel',
        WordClass.pb => 'Pribahasa',
        WordClass.ki => 'Kiasan',
      };

  static WordClass fromString(String value) {
    return WordClass.values.firstWhere(
      (c) => c.name == value,
      orElse: () => WordClass.n,
    );
  }
}
