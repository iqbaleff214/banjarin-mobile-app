import 'package:dio/dio.dart';

import '../../domain/entities/vote.dart';
import '../models/vote_model.dart';

abstract class VoteRemoteDataSource {
  Future<VoteModel> castVote({
    required String targetId,
    required VoteTargetType targetType,
    required VoteValue value,
  });

  Future<void> removeVote({
    required String targetId,
    required VoteTargetType targetType,
  });
}

class VoteRemoteDataSourceImpl implements VoteRemoteDataSource {
  final Dio _dio;

  VoteRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  String _path(String targetId, VoteTargetType type) =>
      type == VoteTargetType.word
          ? '/words/$targetId/votes'
          : '/definitions/$targetId/votes';

  @override
  Future<VoteModel> castVote({
    required String targetId,
    required VoteTargetType targetType,
    required VoteValue value,
  }) async {
    final response = await _dio.post(
      _path(targetId, targetType),
      data: {'value': value.name},
    );
    return VoteModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> removeVote({
    required String targetId,
    required VoteTargetType targetType,
  }) async {
    await _dio.delete(_path(targetId, targetType));
  }
}
