import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../community/domain/entities/contribution.dart';
import '../repositories/admin_repository.dart';

class RejectContributionParams {
  final String contributionId;
  final String note;

  const RejectContributionParams({
    required this.contributionId,
    required this.note,
  });
}

class RejectContribution
    implements UseCase<Contribution, RejectContributionParams> {
  final AdminRepository _repository;
  RejectContribution(this._repository);

  @override
  Future<Either<Failure, Contribution>> call(
    RejectContributionParams params,
  ) async {
    if (params.note.trim().isEmpty) {
      return Left(ValidationFailure(
        fieldErrors: {'note': ['Catatan penolakan tidak boleh kosong.']},
      ));
    }
    return _repository.rejectContribution(
      contributionId: params.contributionId,
      note: params.note.trim(),
    );
  }
}
