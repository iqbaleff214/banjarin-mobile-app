import '../../domain/entities/token_pair.dart';

class TokenPairModel {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  const TokenPairModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory TokenPairModel.fromJson(Map<String, dynamic> json) {
    return TokenPairModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: json['expires_in'] as int? ?? 900,
    );
  }

  TokenPair toEntity() {
    return TokenPair(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: expiresIn,
    );
  }
}
