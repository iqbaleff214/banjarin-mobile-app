import 'package:dio/dio.dart';

import '../../../../core/usecase/paginated_result.dart';
import '../../domain/entities/contribution.dart';
import '../models/contribution_model.dart';

abstract class ContributionRemoteDataSource {
  Future<ContributionModel> submit({
    required ContributionType type,
    String? targetWordId,
    required Map<String, dynamic> payload,
  });

  Future<PaginatedResult<ContributionModel>> getContributions({
    ContributionStatus? status,
    ContributionType? type,
    int page = 1,
    int perPage = 20,
  });

  Future<ContributionModel> getContributionDetail({
    required String contributionId,
  });

  Future<ContributionModel> withdraw({required String contributionId});
}

class ContributionRemoteDataSourceImpl implements ContributionRemoteDataSource {
  final Dio _dio;

  ContributionRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<ContributionModel> submit({
    required ContributionType type,
    String? targetWordId,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _dio.post(
      '/contributions',
      data: {
        'type': type.name,
        'target_word_id': targetWordId,
        'payload': payload,
      },
    );
    return ContributionModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<PaginatedResult<ContributionModel>> getContributions({
    ContributionStatus? status,
    ContributionType? type,
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _dio.get(
      '/contributions',
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (status != null) 'status': status.name,
        if (type != null) 'type': type.name,
      },
    );
    final data = response.data as Map<String, dynamic>;
    final items = (data['data'] as List<dynamic>)
        .map((e) => ContributionModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = data['meta'] as Map<String, dynamic>;
    return PaginatedResult(
      items: items,
      page: meta['page'] as int,
      perPage: meta['per_page'] as int,
      total: meta['total'] as int,
    );
  }

  @override
  Future<ContributionModel> getContributionDetail({
    required String contributionId,
  }) async {
    final response = await _dio.get('/contributions/$contributionId');
    return ContributionModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<ContributionModel> withdraw({required String contributionId}) async {
    final response = await _dio.patch(
      '/contributions/$contributionId/withdraw',
    );
    return ContributionModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}
