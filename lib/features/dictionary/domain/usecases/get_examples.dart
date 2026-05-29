import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/example.dart';
import '../repositories/word_repository.dart';

class GetExamples implements UseCase<List<Example>, WordIdParams> {
  final WordRepository _repository;

  GetExamples(this._repository);

  @override
  Future<Either<Failure, List<Example>>> call(WordIdParams params) {
    return _repository.getExamples(params);
  }
}
