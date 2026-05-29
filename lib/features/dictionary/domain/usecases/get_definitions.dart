import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/definition.dart';
import '../repositories/word_repository.dart';

class GetDefinitions implements UseCase<List<Definition>, WordIdParams> {
  final WordRepository _repository;

  GetDefinitions(this._repository);

  @override
  Future<Either<Failure, List<Definition>>> call(WordIdParams params) {
    return _repository.getDefinitions(params);
  }
}
