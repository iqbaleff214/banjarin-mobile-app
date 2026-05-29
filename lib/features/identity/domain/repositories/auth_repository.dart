import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/token_pair.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, TokenPair>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout({
    required String refreshToken,
  });

  Future<Either<Failure, TokenPair>> refreshToken({
    required String refreshToken,
  });

  Future<Either<Failure, User>> getProfile();

  Future<Either<Failure, User>> updateProfile({
    required String name,
  });

  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  });

  Future<Either<Failure, void>> forgotPassword({
    required String email,
  });

  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String password,
    required String passwordConfirmation,
  });

  Future<Either<Failure, void>> verifyEmail({
    required String token,
  });
}
