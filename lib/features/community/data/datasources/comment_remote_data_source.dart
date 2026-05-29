import 'package:dio/dio.dart';

import '../../../../core/usecase/paginated_result.dart';
import '../models/comment_model.dart';

abstract class CommentRemoteDataSource {
  Future<PaginatedResult<CommentModel>> getComments({
    required String wordId,
    int page = 1,
    int perPage = 20,
  });

  Future<CommentModel> postComment({
    required String wordId,
    required String body,
  });

  Future<CommentModel> editComment({
    required String commentId,
    required String body,
  });

  Future<void> deleteComment({required String commentId});

  Future<CommentModel> flagComment({required String commentId});
}

class CommentRemoteDataSourceImpl implements CommentRemoteDataSource {
  final Dio _dio;

  CommentRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<PaginatedResult<CommentModel>> getComments({
    required String wordId,
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _dio.get(
      '/words/$wordId/comments',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    final data = response.data as Map<String, dynamic>;
    final items = (data['data'] as List<dynamic>)
        .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
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
  Future<CommentModel> postComment({
    required String wordId,
    required String body,
  }) async {
    final response = await _dio.post(
      '/words/$wordId/comments',
      data: {'body': body},
    );
    return CommentModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<CommentModel> editComment({
    required String commentId,
    required String body,
  }) async {
    final response = await _dio.patch(
      '/comments/$commentId',
      data: {'body': body},
    );
    return CommentModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteComment({required String commentId}) async {
    await _dio.delete('/comments/$commentId');
  }

  @override
  Future<CommentModel> flagComment({required String commentId}) async {
    final response = await _dio.post('/comments/$commentId/flag');
    return CommentModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
