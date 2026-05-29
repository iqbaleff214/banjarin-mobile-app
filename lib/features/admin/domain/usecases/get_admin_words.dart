import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/paginated_result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../dictionary/domain/entities/word_summary.dart';
import '../repositories/admin_repository.dart';

class GetAdminWords
    implements UseCase<PaginatedResult<WordSummary>, GetAdminWordsParams> {
  final AdminRepository _repository;
  GetAdminWords(this._repository);

  @override
  Future<Either<Failure, PaginatedResult<WordSummary>>> call(
    GetAdminWordsParams params,
  ) =>
      _repository.getAdminWords(params);
}
