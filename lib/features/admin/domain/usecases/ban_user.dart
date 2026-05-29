import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../identity/domain/entities/user.dart';
import '../repositories/admin_repository.dart';

class BanUserParams {
  final String userId;
  final String reason;
  const BanUserParams({required this.userId, required this.reason});
}

class BanUser implements UseCase<User, BanUserParams> {
  final AdminRepository _repository;
  BanUser(this._repository);

  @override
  Future<Either<Failure, User>> call(BanUserParams params) async {
    if (params.reason.trim().isEmpty) {
      return Left(ValidationFailure(
        fieldErrors: {'reason': ['Alasan ban tidak boleh kosong.']},
      ));
    }
    return _repository.banUser(
      userId: params.userId,
      reason: params.reason.trim(),
    );
  }
}
