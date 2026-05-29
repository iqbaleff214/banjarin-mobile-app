import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/moderation_stats.dart';
import '../repositories/admin_repository.dart';

class GetModerationStats implements UseCase<ModerationStats, NoParams> {
  final AdminRepository _repository;
  GetModerationStats(this._repository);

  @override
  Future<Either<Failure, ModerationStats>> call(NoParams params) =>
      _repository.getModerationStats();
}
