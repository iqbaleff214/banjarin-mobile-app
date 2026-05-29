enum ConfidenceLevel {
  high,
  medium,
  low;

  static ConfidenceLevel fromString(String value) => switch (value) {
        'medium' => ConfidenceLevel.medium,
        'low' => ConfidenceLevel.low,
        _ => ConfidenceLevel.high,
      };
}
