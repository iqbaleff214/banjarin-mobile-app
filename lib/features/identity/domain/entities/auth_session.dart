import 'package:equatable/equatable.dart';

import 'token_pair.dart';
import 'user.dart';

class AuthSession extends Equatable {
  final User user;
  final TokenPair tokenPair;

  const AuthSession({
    required this.user,
    required this.tokenPair,
  });

  @override
  List<Object?> get props => [user, tokenPair];
}
