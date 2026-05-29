import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/translation_result.dart';
import '../repositories/ai_repository.dart';

class TranslateBanjarParams {
  final String text;
  final String? context;
  final bool isAuthenticated;

  const TranslateBanjarParams({
    required this.text,
    this.context,
    required this.isAuthenticated,
  });
}

class TranslateBanjar implements UseCase<TranslationResult, TranslateBanjarParams> {
  final AIRepository _repository;

  TranslateBanjar(this._repository);

  @override
  Future<Either<Failure, TranslationResult>> call(
    TranslateBanjarParams params,
  ) async {
    if (!params.isAuthenticated) {
      return const Left(UnauthorizedFailure());
    }
    if (params.text.trim().isEmpty) {
      return Left(ValidationFailure(
        fieldErrors: {'text': ['Teks tidak boleh kosong.']},
      ));
    }
    if (params.text.length > 1000) {
      return Left(ValidationFailure(
        fieldErrors: {'text': ['Teks maksimal 1000 karakter.']},
      ));
    }
    return _repository.translate(
      text: params.text.trim(),
      context: params.context,
    );
  }
}
