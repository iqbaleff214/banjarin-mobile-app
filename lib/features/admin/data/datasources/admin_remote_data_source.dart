import 'package:dio/dio.dart';

import '../../../../core/usecase/paginated_result.dart';
import '../../../community/data/models/comment_model.dart';
import '../../../community/data/models/contribution_model.dart';
import '../../../dictionary/data/models/word_model.dart';
import '../../../dictionary/data/models/word_summary_model.dart';
import '../../../identity/data/models/user_model.dart';
import '../../../identity/domain/entities/user_role.dart';
import '../../domain/repositories/admin_repository.dart';
import '../models/ai_request_model.dart';
import '../models/moderation_stats_model.dart';

abstract class AdminRemoteDataSource {
  // Words
  Future<PaginatedResult<WordSummaryModel>> getAdminWords(GetAdminWordsParams p);
  Future<WordModel> createWord(CreateWordParams params);
  Future<WordModel> updateWord(UpdateWordParams params);
  Future<void> deleteWord({required String wordId});

  // Users
  Future<PaginatedResult<UserModel>> getAdminUsers(GetAdminUsersParams p);
  Future<UserModel> getUserDetail({required String userId});
  Future<UserModel> banUser({required String userId, required String reason});
  Future<UserModel> unbanUser({required String userId});
  Future<UserModel> changeUserRole({required String userId, required UserRole role});

  // Moderation
  Future<PaginatedResult<ContributionModel>> getModerationQueue(
      GetModerationQueueParams p);
  Future<PaginatedResult<CommentModel>> getFlaggedComments(
      {int page, int perPage});
  Future<ModerationStatsModel> getModerationStats();
  Future<ContributionModel> approveContribution(
      {required String contributionId, String? note});
  Future<ContributionModel> rejectContribution(
      {required String contributionId, required String note});

  // AI Enrichment
  Future<AIRequestModel> triggerEnrich({required String wordId});
  Future<AIRequestModel> triggerExample({required String wordId});
  Future<AIRequestModel> triggerRelated({required String wordId});
  Future<AIRequestModel> runQualityCheck({required String contributionId});
  Future<PaginatedResult<AIRequestModel>> getAIRequests(GetAIRequestsParams p);
  Future<AIRequestModel> getAIRequestDetail({required String requestId});
  Future<AIRequestModel> approveAIRequest({required String requestId});
  Future<AIRequestModel> rejectAIRequest({required String requestId});
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final Dio _dio;

  AdminRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  Map<String, dynamic> _buildWordInput(CreateWordParams p) => {
        'banjar': p.banjar,
        'banjar_syllabified': p.banjarSyllabified,
        'word_class': p.wordClass.name,
        'homonym_number': p.homonymNumber,
        'is_root': p.isRoot,
        'root_word_id': p.rootWordId,
        'definitions': p.definitions,
        'examples': p.examples,
      };

  PaginatedResult<T> _paginate<T>(
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>) mapper,
  ) {
    final items =
        (data['data'] as List<dynamic>).map((e) => mapper(e as Map<String, dynamic>)).toList();
    final meta = data['meta'] as Map<String, dynamic>;
    return PaginatedResult(
      items: items,
      page: meta['page'] as int,
      perPage: meta['per_page'] as int,
      total: meta['total'] as int,
    );
  }

  // -------------------------------------------------------------------------
  // Words
  // -------------------------------------------------------------------------
  @override
  Future<PaginatedResult<WordSummaryModel>> getAdminWords(
      GetAdminWordsParams p) async {
    final response = await _dio.get('/admin/words', queryParameters: {
      'page': p.page,
      'per_page': p.perPage,
      if (p.query != null) 'q': p.query,
      if (p.status != null) 'status': p.status!.name,
      if (p.wordClass != null) 'word_class': p.wordClass!.name,
      if (p.source != null) 'source': p.source!.name,
    });
    return _paginate(
        response.data as Map<String, dynamic>, WordSummaryModel.fromJson);
  }

  @override
  Future<WordModel> createWord(CreateWordParams params) async {
    final response = await _dio.post('/admin/words', data: _buildWordInput(params));
    return WordModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<WordModel> updateWord(UpdateWordParams params) async {
    final response = await _dio.patch(
        '/admin/words/${params.wordId}', data: _buildWordInput(params));
    return WordModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteWord({required String wordId}) async {
    await _dio.delete('/admin/words/$wordId');
  }

  // -------------------------------------------------------------------------
  // Users
  // -------------------------------------------------------------------------
  @override
  Future<PaginatedResult<UserModel>> getAdminUsers(GetAdminUsersParams p) async {
    final response = await _dio.get('/admin/users', queryParameters: {
      'page': p.page,
      'per_page': p.perPage,
      if (p.query != null) 'q': p.query,
      if (p.role != null) 'role': p.role!.name,
      if (p.isActive != null) 'is_active': p.isActive,
    });
    return _paginate(
        response.data as Map<String, dynamic>, UserModel.fromJson);
  }

  @override
  Future<UserModel> getUserDetail({required String userId}) async {
    final response = await _dio.get('/admin/users/$userId');
    return UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel> banUser({required String userId, required String reason}) async {
    final response = await _dio.patch(
        '/admin/users/$userId/ban', data: {'reason': reason});
    return UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel> unbanUser({required String userId}) async {
    final response = await _dio.patch('/admin/users/$userId/unban');
    return UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel> changeUserRole(
      {required String userId, required UserRole role}) async {
    final response = await _dio.patch(
        '/admin/users/$userId/role', data: {'role': role.name});
    return UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  // -------------------------------------------------------------------------
  // Moderation
  // -------------------------------------------------------------------------
  @override
  Future<PaginatedResult<ContributionModel>> getModerationQueue(
      GetModerationQueueParams p) async {
    final response = await _dio.get('/admin/moderation/queue', queryParameters: {
      'page': p.page,
      'per_page': p.perPage,
      if (p.type != null) 'type': p.type!.name,
    });
    return _paginate(
        response.data as Map<String, dynamic>, ContributionModel.fromJson);
  }

  @override
  Future<PaginatedResult<CommentModel>> getFlaggedComments(
      {int page = 1, int perPage = 20}) async {
    final response = await _dio.get('/admin/moderation/flags',
        queryParameters: {'page': page, 'per_page': perPage});
    return _paginate(
        response.data as Map<String, dynamic>, CommentModel.fromJson);
  }

  @override
  Future<ModerationStatsModel> getModerationStats() async {
    final response = await _dio.get('/admin/moderation/stats');
    return ModerationStatsModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<ContributionModel> approveContribution(
      {required String contributionId, String? note}) async {
    final response = await _dio.patch(
      '/contributions/$contributionId/approve',
      data: {'note': note},
    );
    return ContributionModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<ContributionModel> rejectContribution(
      {required String contributionId, required String note}) async {
    final response = await _dio.patch(
      '/contributions/$contributionId/reject',
      data: {'note': note},
    );
    return ContributionModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  // -------------------------------------------------------------------------
  // AI Enrichment
  // -------------------------------------------------------------------------

  AIRequestModel _parseAIRequest(Response response) =>
      AIRequestModel.fromJson(response.data['data'] as Map<String, dynamic>);

  @override
  Future<AIRequestModel> triggerEnrich({required String wordId}) async =>
      _parseAIRequest(await _dio.post('/admin/ai/enrich/$wordId'));

  @override
  Future<AIRequestModel> triggerExample({required String wordId}) async =>
      _parseAIRequest(await _dio.post('/admin/ai/example/$wordId'));

  @override
  Future<AIRequestModel> triggerRelated({required String wordId}) async =>
      _parseAIRequest(await _dio.post('/admin/ai/related/$wordId'));

  @override
  Future<AIRequestModel> runQualityCheck(
      {required String contributionId}) async =>
      _parseAIRequest(await _dio.post('/admin/ai/check/$contributionId'));

  @override
  Future<PaginatedResult<AIRequestModel>> getAIRequests(
      GetAIRequestsParams p) async {
    final response = await _dio.get('/admin/ai/requests', queryParameters: {
      'page': p.page,
      'per_page': p.perPage,
      if (p.type != null) 'type': p.type!.name,
      if (p.status != null) 'status': p.status!.name,
      if (p.reviewStatus != null) 'review_status': p.reviewStatus!.name,
    });
    return _paginate(
        response.data as Map<String, dynamic>, AIRequestModel.fromJson);
  }

  @override
  Future<AIRequestModel> getAIRequestDetail({required String requestId}) async =>
      _parseAIRequest(await _dio.get('/admin/ai/requests/$requestId'));

  @override
  Future<AIRequestModel> approveAIRequest({required String requestId}) async =>
      _parseAIRequest(
          await _dio.patch('/admin/ai/requests/$requestId/approve'));

  @override
  Future<AIRequestModel> rejectAIRequest({required String requestId}) async =>
      _parseAIRequest(await _dio.patch('/admin/ai/requests/$requestId/reject'));
}
