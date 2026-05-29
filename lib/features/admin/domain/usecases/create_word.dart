import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../dictionary/domain/entities/word.dart';
import '../repositories/admin_repository.dart';

class CreateWord implements UseCase<Word, CreateWordParams> {
  final AdminRepository _repository;
  CreateWord(this._repository);

  @override
  Future<Either<Failure, Word>> call(CreateWordParams params) async {
    if (params.banjar.trim().isEmpty) {
      return Left(ValidationFailure(
        fieldErrors: {'banjar': ['Kata Banjar tidak boleh kosong.']},
      ));
    }
    if (params.definitions.isEmpty) {
      return Left(ValidationFailure(
        fieldErrors: {'definitions': ['Minimal 1 definisi diperlukan.']},
      ));
    }
    return _repository.createWord(params);
  }
}
