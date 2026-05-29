import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/ai_request.dart';
import '../repositories/admin_repository.dart';

class ApproveAIRequestParams {
  final String requestId;
  final AIRequestType type;
  final AIReviewStatus reviewStatus;

  const ApproveAIRequestParams({
    required this.requestId,
    required this.type,
    required this.reviewStatus,
  });
}

class ApproveAIRequest implements UseCase<AIRequest, ApproveAIRequestParams> {
  final AdminRepository _repository;
  ApproveAIRequest(this._repository);

  @override
  Future<Either<Failure, AIRequest>> call(ApproveAIRequestParams params) async {
    if (params.type == AIRequestType.quality_check) {
      return const Left(ConflictFailure(
        'Quality check tidak dapat disetujui.',
      ));
    }
    if (params.reviewStatus == AIReviewStatus.approved ||
        params.reviewStatus == AIReviewStatus.rejected) {
      return const Left(ConflictFailure(
        'Permintaan ini sudah ditinjau.',
      ));
    }
    return _repository.approveAIRequest(requestId: params.requestId);
  }
}
