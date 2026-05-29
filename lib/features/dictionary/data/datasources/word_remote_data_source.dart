import 'package:dio/dio.dart';

import '../../../../core/usecase/paginated_result.dart';
import '../../domain/repositories/word_repository.dart';
import '../models/definition_model.dart';
import '../models/example_model.dart';
import '../models/word_model.dart';
import '../models/word_summary_model.dart';

abstract class WordRemoteDataSource {
  Future<PaginatedResult<WordSummaryModel>> getWordList(WordListParams params);
  Future<PaginatedResult<WordSummaryModel>> searchWords(SearchParams params);
  Future<WordModel> getWordDetail(String wordId);
  Future<List<DefinitionModel>> getDefinitions(String wordId);
  Future<List<ExampleModel>> getExamples(String wordId);
  Future<List<WordSummaryModel>> getRelatedWords(String wordId);
}

class WordRemoteDataSourceImpl implements WordRemoteDataSource {
  final Dio _dio;

  WordRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<PaginatedResult<WordSummaryModel>> getWordList(
    WordListParams params,
  ) async {
    final response = await _dio.get(
      '/words',
      queryParameters: {
        'page': params.page,
        'per_page': params.perPage,
        if (params.wordClass != null) 'word_class': params.wordClass!.name,
        if (params.isRoot != null) 'is_root': params.isRoot,
        if (params.source != null) 'source': params.source!.name,
        'sort': params.sort.apiValue,
      },
    );
    final data = response.data as Map<String, dynamic>;
    final items = (data['data'] as List<dynamic>)
        .map((e) => WordSummaryModel.fromJson(e as Map<String, dynamic>))
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
  Future<PaginatedResult<WordSummaryModel>> searchWords(
    SearchParams params,
  ) async {
    final response = await _dio.get(
      '/words/search',
      queryParameters: {
        'q': params.query,
        'page': params.page,
        'per_page': params.perPage,
        'sort': params.sort.apiValue,
      },
    );
    final data = response.data as Map<String, dynamic>;
    final items = (data['data'] as List<dynamic>)
        .map((e) => WordSummaryModel.fromJson(e as Map<String, dynamic>))
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
  Future<WordModel> getWordDetail(String wordId) async {
    final response = await _dio.get('/words/$wordId');
    return WordModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<List<DefinitionModel>> getDefinitions(String wordId) async {
    final response = await _dio.get('/words/$wordId/definitions');
    return (response.data['data'] as List<dynamic>)
        .map((e) => DefinitionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ExampleModel>> getExamples(String wordId) async {
    final response = await _dio.get('/words/$wordId/examples');
    return (response.data['data'] as List<dynamic>)
        .map((e) => ExampleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<WordSummaryModel>> getRelatedWords(String wordId) async {
    final response = await _dio.get('/words/$wordId/related');
    return (response.data['data'] as List<dynamic>)
        .map((e) => WordSummaryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
