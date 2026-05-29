import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/paginated_result.dart';
import '../../../community/domain/entities/comment.dart';
import '../../../community/domain/entities/contribution.dart';
import '../../../dictionary/domain/entities/content_source.dart';
import '../../../dictionary/domain/entities/word.dart';
import '../../../dictionary/domain/entities/word_class.dart';
import '../../../dictionary/domain/entities/word_summary.dart';
import '../../../identity/domain/entities/user.dart';
import '../../../identity/domain/entities/user_role.dart';
import '../entities/moderation_stats.dart';

// ---------------------------------------------------------------------------
// Word params
// ---------------------------------------------------------------------------

class GetAdminWordsParams {
  final String? query;
  final WordStatus? status;
  final WordClass? wordClass;
  final ContentSource? source;
  final int page;
  final int perPage;

  const GetAdminWordsParams({
    this.query,
    this.status,
    this.wordClass,
    this.source,
    this.page = 1,
    this.perPage = 20,
  });
}

class CreateWordParams {
  final String banjar;
  final String? banjarSyllabified;
  final WordClass wordClass;
  final int homonymNumber;
  final bool isRoot;
  final String? rootWordId;
  final List<Map<String, dynamic>> definitions;
  final List<Map<String, dynamic>> examples;

  const CreateWordParams({
    required this.banjar,
    this.banjarSyllabified,
    required this.wordClass,
    this.homonymNumber = 1,
    this.isRoot = true,
    this.rootWordId,
    required this.definitions,
    this.examples = const [],
  });
}

class UpdateWordParams extends CreateWordParams {
  final String wordId;

  const UpdateWordParams({
    required this.wordId,
    required super.banjar,
    super.banjarSyllabified,
    required super.wordClass,
    super.homonymNumber,
    super.isRoot,
    super.rootWordId,
    required super.definitions,
    super.examples,
  });
}

// ---------------------------------------------------------------------------
// User params
// ---------------------------------------------------------------------------

class GetAdminUsersParams {
  final String? query;
  final UserRole? role;
  final bool? isActive;
  final int page;
  final int perPage;

  const GetAdminUsersParams({
    this.query,
    this.role,
    this.isActive,
    this.page = 1,
    this.perPage = 20,
  });
}

// ---------------------------------------------------------------------------
// Moderation params
// ---------------------------------------------------------------------------

class GetModerationQueueParams {
  final ContributionType? type;
  final int page;
  final int perPage;

  const GetModerationQueueParams({
    this.type,
    this.page = 1,
    this.perPage = 20,
  });
}

// ---------------------------------------------------------------------------
// AdminRepository
// ---------------------------------------------------------------------------

abstract class AdminRepository {
  // Words
  Future<Either<Failure, PaginatedResult<WordSummary>>> getAdminWords(
    GetAdminWordsParams params,
  );
  Future<Either<Failure, Word>> createWord(CreateWordParams params);
  Future<Either<Failure, Word>> updateWord(UpdateWordParams params);
  Future<Either<Failure, void>> deleteWord({required String wordId});

  // Users
  Future<Either<Failure, PaginatedResult<User>>> getAdminUsers(
    GetAdminUsersParams params,
  );
  Future<Either<Failure, User>> getUserDetail({required String userId});
  Future<Either<Failure, User>> banUser({
    required String userId,
    required String reason,
  });
  Future<Either<Failure, User>> unbanUser({required String userId});
  Future<Either<Failure, User>> changeUserRole({
    required String userId,
    required UserRole role,
  });

  // Moderation
  Future<Either<Failure, PaginatedResult<Contribution>>> getModerationQueue(
    GetModerationQueueParams params,
  );
  Future<Either<Failure, PaginatedResult<Comment>>> getFlaggedComments({
    int page = 1,
    int perPage = 20,
  });
  Future<Either<Failure, ModerationStats>> getModerationStats();
  Future<Either<Failure, Contribution>> approveContribution({
    required String contributionId,
    String? note,
  });
  Future<Either<Failure, Contribution>> rejectContribution({
    required String contributionId,
    required String note,
  });
}
