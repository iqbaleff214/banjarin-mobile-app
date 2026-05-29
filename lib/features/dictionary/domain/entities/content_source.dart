enum ContentSource {
  seeded,
  contributed,
  // ignore: constant_identifier_names
  ai_generated;

  bool get isAiGenerated => this == ContentSource.ai_generated;
  bool get isContributed => this == ContentSource.contributed;
  bool get isSeeded => this == ContentSource.seeded;

  static ContentSource fromString(String value) => switch (value) {
        'ai_generated' => ContentSource.ai_generated,
        'contributed' => ContentSource.contributed,
        _ => ContentSource.seeded,
      };
}
