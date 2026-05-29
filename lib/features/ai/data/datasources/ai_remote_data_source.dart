import 'package:dio/dio.dart';

import '../models/translation_result_model.dart';

abstract class AIRemoteDataSource {
  Future<TranslationResultModel> translate({
    required String text,
    String? context,
  });
}

class AIRemoteDataSourceImpl implements AIRemoteDataSource {
  final Dio _dio;

  AIRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<TranslationResultModel> translate({
    required String text,
    String? context,
  }) async {
    final response = await _dio.post(
      '/ai/translate',
      data: {
        'text': text,
        'context': context,
      },
    );
    return TranslationResultModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}
