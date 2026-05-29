import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../error/exceptions.dart';

class DioClient {
  DioClient._();

  static Dio create() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(_ResponseInterceptor());

    return dio;
  }
}

class _ResponseInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const NetworkException('Network connection failed.'),
          type: err.type,
        ),
      );
      return;
    }

    final response = err.response;
    if (response != null) {
      try {
        final data = response.data as Map<String, dynamic>;
        final error = data['error'] as Map<String, dynamic>;
        final code = error['code'] as String;
        final message = error['message'] as String;
        final details = error['details'] as Map<String, dynamic>?;

        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            response: response,
            error: ServerException(
              code: code,
              message: message,
              details: details,
            ),
            type: err.type,
          ),
        );
        return;
      } catch (_) {}
    }

    handler.next(err);
  }
}
