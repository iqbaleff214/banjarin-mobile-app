import 'package:dio/dio.dart';

import '../../../../core/usecase/paginated_result.dart';
import '../models/bookmark_model.dart';

abstract class BookmarkRemoteDataSource {
  Future<PaginatedResult<BookmarkModel>> getBookmarks({
    int page = 1,
    int perPage = 20,
  });

  Future<BookmarkModel> addBookmark({required String wordId});

  Future<void> removeBookmark({required String wordId});
}

class BookmarkRemoteDataSourceImpl implements BookmarkRemoteDataSource {
  final Dio _dio;

  BookmarkRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<PaginatedResult<BookmarkModel>> getBookmarks({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _dio.get(
      '/bookmarks',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    final data = response.data as Map<String, dynamic>;
    final items = (data['data'] as List<dynamic>)
        .map((e) => BookmarkModel.fromJson(e as Map<String, dynamic>))
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
  Future<BookmarkModel> addBookmark({required String wordId}) async {
    final response = await _dio.post(
      '/bookmarks',
      data: {'word_id': wordId},
    );
    return BookmarkModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> removeBookmark({required String wordId}) async {
    await _dio.delete('/bookmarks/$wordId');
  }
}
