import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/word.dart';
import '../repositories/word_repository.dart';

class GetWordDetail implements UseCase<Word, WordIdParams> {
  final WordRepository _repository;

  GetWordDetail(this._repository);

  @override
  Future<Either<Failure, Word>> call(WordIdParams params) {
    return _repository.getWordDetail(params);
  }
}
