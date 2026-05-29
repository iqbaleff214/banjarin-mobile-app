import 'package:dio/dio.dart';

import '../models/token_pair_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<TokenPairModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> logout({required String refreshToken});

  Future<TokenPairModel> refreshToken({required String refreshToken});

  Future<UserModel> getProfile();

  Future<UserModel> updateProfile({required String name});

  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  });

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({
    required String token,
    required String password,
    required String passwordConfirmation,
  });

  Future<void> verifyEmail({required String token});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<TokenPairModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return TokenPairModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      },
    );
    return UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    await _dio.post(
      '/auth/logout',
      data: {'refresh_token': refreshToken},
    );
  }

  @override
  Future<TokenPairModel> refreshToken({required String refreshToken}) async {
    final response = await _dio.post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );
    return TokenPairModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel> getProfile() async {
    final response = await _dio.get('/auth/me');
    return UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel> updateProfile({required String name}) async {
    final response = await _dio.patch(
      '/auth/me',
      data: {'name': name},
    );
    return UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _dio.patch(
      '/auth/me/password',
      data: {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await _dio.post(
      '/auth/forgot-password',
      data: {'email': email},
    );
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _dio.post(
      '/auth/reset-password',
      data: {
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  @override
  Future<void> verifyEmail({required String token}) async {
    await _dio.post(
      '/auth/verify-email',
      data: {'token': token},
    );
  }
}
