import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/admin_repository.dart';

class DeleteWordParams {
  final String wordId;
  const DeleteWordParams({required this.wordId});
}

class DeleteWord implements UseCase<void, DeleteWordParams> {
  final AdminRepository _repository;
  DeleteWord(this._repository);

  @override
  Future<Either<Failure, void>> call(DeleteWordParams params) =>
      _repository.deleteWord(wordId: params.wordId);
}
