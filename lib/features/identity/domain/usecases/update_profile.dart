import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileParams {
  final String name;

  const UpdateProfileParams({required this.name});
}

class UpdateProfile implements UseCase<User, UpdateProfileParams> {
  final AuthRepository _repository;

  UpdateProfile(this._repository);

  @override
  Future<Either<Failure, User>> call(UpdateProfileParams params) async {
    if (params.name.trim().length < 2) {
      return Left(ValidationFailure(
        fieldErrors: {'name': ['Nama minimal 2 karakter.']},
      ));
    }
    return _repository.updateProfile(name: params.name.trim());
  }
}
